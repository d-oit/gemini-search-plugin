#!/bin/bash
# Production wrapper script for Gemini Search functionality with error handling and logging
# Uses Gemini CLI with grounded web server exclusively (not Claude's internal search)

# Set strict error handling
set -euo pipefail

# Configuration
CACHE_DIR="${CACHE_DIR:-/tmp/gemini-search-cache}"
CACHE_TTL="${CACHE_TTL:-3600}" # 1 hour in seconds
LOG_FILE="${LOG_FILE:-/tmp/gemini-search.log}"
ERROR_LOG_FILE="${ERROR_LOG_FILE:-/tmp/gemini-search-errors.log}"
MAX_RETRIES="${MAX_RETRIES:-3}"
RETRY_DELAY="${RETRY_DELAY:-1}" # seconds
ENABLE_LINK_VALIDATION="${ENABLE_LINK_VALIDATION:-true}" # Enable static link validation
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Logging function
log_message() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date -Iseconds)
    local log_entry="{\"timestamp\":\"$timestamp\",\"level\":\"$level\",\"message\":\"$message\"}"
    
    echo "$log_entry" >> "$LOG_FILE"
    # Also output to stderr for immediate visibility
    echo "$log_entry" >&2
}

# Error logging function
log_error() {
    local message="$1"
    local timestamp
    timestamp=$(date -Iseconds)
    local log_entry="{\"timestamp\":\"$timestamp\",\"level\":\"ERROR\",\"message\":\"$message\"}"
    
    echo "$log_entry" >> "$ERROR_LOG_FILE"
    echo "$log_entry" >&2
}

# Create cache and log directories if they don't exist
mkdir -p "$CACHE_DIR"
mkdir -p "$(dirname "$LOG_FILE")" "$(dirname "$ERROR_LOG_FILE")" 2>/dev/null || true

# Function to generate cache key from search query
generate_cache_key() {
    echo "$1" | md5sum | cut -d' ' -f1
}

# Function to check if cache is valid
is_cache_valid() {
    local cache_file="$1"
    local ttl="${2:-$CACHE_TTL}"
    
    if [[ -f "$cache_file" ]]; then
        # Use a platform-independent way to get modification time
        local cache_time
        if command -v stat >/dev/null 2>&1; then
            # Unix-like systems
            cache_time=$(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null || echo 0)
        else
            # Fallback: just check if file exists and is not empty
            cache_time=$(date +%s)
        fi

        if [[ $cache_time -eq 0 ]]; then
            # stat command failed, just check file exists
            [[ -s "$cache_file" ]]  # non-zero size
            return $?
        fi

        local current_time
        current_time=$(date +%s)
        local age=$((current_time - cache_time))
        
        [[ $age -lt $ttl ]]
    else
        return 1
    fi
}

# Function to extract text content from a webpage using Gemini grounded web server
extract_content_from_url() {
    local url="$1"
    local content=""

    log_message "INFO" "Extracting content from $url using Gemini grounded web server"

    # Check if Gemini CLI is available
    if ! command -v gemini >/dev/null 2>&1; then
        log_error "Gemini CLI not found. Please install Gemini CLI to use this plugin."
        echo "Error: Gemini CLI is required. Install from: npm install -g @google/gemini-cli"
        return 1
    fi

    # Use Gemini CLI in headless mode to extract and summarize content from URL
    # The --yolo flag auto-approves the google_web_search tool usage
    log_message "DEBUG" "Using Gemini CLI to extract content from: $url"

    local prompt="Extract and summarize the main content from this webpage: $url. Provide only the key information without additional commentary."

    # Execute Gemini CLI in headless mode with --yolo for auto-approval
    if content=$(gemini -p "/tool:googleSearch query:\"$prompt\" raw:true" --yolo --output-format json -m "gemini-2.5-flash" 2>/dev/null); then
        if [[ -n "$content" ]]; then
            echo "$content"
            log_message "INFO" "Successfully extracted content from $url using Gemini grounded web server"
            return 0
        fi
    fi

    log_error "Failed to fetch content from $url using Gemini CLI"
    echo "Error: Could not retrieve content from $url"
    return 1
}

# Function to validate search results and check for false positives
validate_search_result() {
    local title="$1"
    local url="$2"
    local snippet="$3"
    local query="$4"

    # Convert to lowercase for comparison
    local lower_title
    lower_title=$(echo "$title" | tr '[:upper:]' '[:lower:]')
    local lower_url
    lower_url=$(echo "$url" | tr '[:upper:]' '[:lower:]')
    local lower_snippet
    lower_snippet=$(echo "$snippet" | tr '[:upper:]' '[:lower:]')
    local lower_query
    lower_query=$(echo "$query" | tr '[:upper:]' '[:lower:]')

    log_message "DEBUG" "Validating result: $title against query: $query"

    # Check if query terms appear in the result
    local relevance_score=0
    local -a query_terms
    read -ra query_terms <<< "$lower_query"

    for term in "${query_terms[@]}"; do
        if [[ "$lower_title" == *"$term"* ]] || [[ "$lower_snippet" == *"$term"* ]] || [[ "$lower_url" == *"$term"* ]]; then
            ((relevance_score++)) || true
        fi
    done
    
    # Calculate relevance as percentage
    local total_terms=${#query_terms[@]}
    local relevance_percentage=0
    
    if [[ $total_terms -gt 0 ]]; then
        relevance_percentage=$((relevance_score * 100 / total_terms))
    fi
    
    # Additional validation checks
    local is_valid=true
    
    # Check for common false positive indicators
    if [[ "$lower_url" =~ (example\.com|test\.com|invalid\.com|localhost) ]]; then
        is_valid=false
        log_message "DEBUG" "Result failed validation: contains invalid domain"
    fi
    
    # Enhanced validation: Check if URL exists (static link check)
    local url_status="unknown"
    if [[ "$ENABLE_LINK_VALIDATION" == "true" ]] && [[ "$is_valid" == "true" ]] && [[ -x "$SCRIPT_DIR/validate-links.sh" ]]; then
        log_message "DEBUG" "Performing static link validation for: $url"

        # Source validation functions
        source "$SCRIPT_DIR/validate-links.sh"

        # Check if URL exists
        if check_url_exists "$url"; then
            url_status="accessible"
            log_message "DEBUG" "URL is accessible: $url"
        else
            url_status="inaccessible"
            is_valid=false
            log_message "DEBUG" "URL is not accessible: $url"
        fi
    fi

    # Return validation result
    if [[ $relevance_percentage -ge 50 ]] && [[ "$is_valid" == "true" ]]; then
        echo "VALID|$relevance_percentage|$url_status"  # Valid result with relevance score and URL status
        return 0
    else
        echo "INVALID|$relevance_percentage|$url_status"  # Invalid result with relevance score and URL status
        return 1
    fi
}

# Function to perform actual search using Gemini CLI with grounded web server
perform_search() {
    local query="$1"
    local attempt=1

    # Check if Gemini CLI is available
    if ! command -v gemini >/dev/null 2>&1; then
        log_error "Gemini CLI not found. Please install Gemini CLI to use this plugin."
        echo "Error: Gemini CLI is required. Install from: npm install -g @google/gemini-cli"
        return 1
    fi

    while [[ $attempt -le $MAX_RETRIES ]]; do
        log_message "INFO" "Attempt $attempt of $MAX_RETRIES for Gemini search: $query"

        # Execute Gemini CLI in headless mode with grounded web search
        # The --yolo flag auto-approves the google_web_search tool usage
        # The settings.json file restricts the CLI to only use google_web_search
        local result
        if result=$(gemini -p "/tool:googleSearch query:\"$query\" raw:true" --yolo --output-format json -m "gemini-2.5-flash" 2>/dev/null); then
            if [[ -n "$result" ]]; then
                log_message "INFO" "Gemini search successful on attempt $attempt"
                echo "$result"
                return 0
            fi
        fi

        local exit_code=$?
        log_error "Gemini CLI search failed on attempt $attempt: exit code $exit_code" "query: $query"

        if [[ $attempt -lt $MAX_RETRIES ]]; then
            local delay=$((RETRY_DELAY * attempt))
            log_message "INFO" "Waiting $delay seconds before retry"
            sleep $delay
        fi
        ((attempt++))
    done

    log_error "All $MAX_RETRIES attempts failed for query: $query"
    return 1
}

# Main search function with error handling and validation
search() {
    local query="$1"

    # Validate input
    if [[ -z "$query" ]]; then
        log_error "Empty query provided"
        echo "Error: Query cannot be empty" >&2
        return 1
    fi

    local cache_key
    cache_key=$(generate_cache_key "$query")
    local cache_file="$CACHE_DIR/$cache_key.json"
    
    # Check if result is cached
    if is_cache_valid "$cache_file"; then
        log_message "INFO" "Cache hit for query: $query"
        echo "CACHE_HIT"
        cat "$cache_file"
        log_message "INFO" "Served cached results for query: $query"
        return 0
    else
        log_message "INFO" "Cache miss for query: $query"
        echo "CACHE_MISS"
        
        # Perform the search with error handling
        local results
        if results=$(perform_search "$query"); then
            # Save results to cache
            echo "$results" > "$cache_file"
            echo "$results"
            log_message "INFO" "Saved new results to cache for query: $query"
        else
            # Return error message if search failed
            local error_msg="Search failed after $MAX_RETRIES attempts"
            echo "$error_msg" >&2
            log_error "$error_msg for query: $query"
            return 1
        fi
    fi
}

# Function to get analytics with error handling
get_stats() {
    if [[ -f "$LOG_FILE" ]]; then
        local total_searches=0
        local cache_hits=0
        local cache_misses=0
        local cache_hit_rate=0

        # Count total searches from log (grep -c returns 0 on no match)
        total_searches=$(grep -c "search" "$LOG_FILE" 2>/dev/null) || total_searches=0

        # Count cache hits and misses if analytics log has this data
        cache_hits=$(grep -c "cache_hit" "$LOG_FILE" 2>/dev/null) || cache_hits=0
        cache_misses=$((total_searches - cache_hits))
        
        if [[ $total_searches -gt 0 ]]; then
            cache_hit_rate=$((cache_hits * 100 / total_searches))
        fi

        echo "=== Cache Statistics ==="
        echo "Total searches: $total_searches"
        echo "Cache hits: $cache_hits"
        echo "Cache misses: $cache_misses"
        echo "Cache hit rate: ${cache_hit_rate}%"
        
        # Add more detailed analytics
        local log_size
        log_size=$(wc -c < "$LOG_FILE" 2>/dev/null || echo 0)
        echo "Log file size: $log_size bytes"
    else
        echo "No analytics data available"
        log_message "WARN" "Analytics log file not found: $LOG_FILE"
    fi
}

# Clear cache function with error handling
clear_cache() {
    if [[ -d "$CACHE_DIR" ]]; then
        local cache_size
        if command -v du >/dev/null 2>&1; then
            cache_size=$(du -sh "$CACHE_DIR" 2>/dev/null | cut -f1 || echo "unknown")
        else
            cache_size="unknown"
        fi
        
        # Clear the cache directory
        if rm -rf "${CACHE_DIR:?}"/* 2>/dev/null; then
            log_message "INFO" "Cache cleared. Previous size: $cache_size"
            echo "Cache cleared. Previous size: $cache_size"
        else
            log_error "Failed to clear cache directory: $CACHE_DIR"
            echo "Error: Failed to clear cache" >&2
            return 1
        fi
    else
        log_message "INFO" "Cache directory does not exist: $CACHE_DIR"
        echo "Cache directory does not exist: $CACHE_DIR"
    fi
}

# Parse command line arguments
case "${1:-}" in
    search)
        search "${2:-}"
        ;;
    stats)
        get_stats
        ;;
    clear-cache)
        clear_cache
        ;;
    extract-content)
        extract_content_from_url "${2:-}"
        ;;
    validate-result)
        validate_search_result "${2:-}" "${3:-}" "${4:-}" "${5:-}"
        ;;
    *)
        log_message "INFO" "Usage: $0 {search|stats|clear-cache|extract-content|validate-result} [args...]"
        echo "Usage: $0 {search|stats|clear-cache|extract-content|validate-result} [args...]" >&2
        exit 1
        ;;
esac