#!/bin/bash
# Dynamic Content Extractor for Gemini Search Plugin
# Extracts and validates content from websites using Gemini grounded web server

# Set strict error handling
set -euo pipefail

# Configuration
TEMP_DIR="${TEMP_DIR:-/tmp/gemini-content-extractor}"
export LOG_FILE="${LOG_FILE:-/tmp/gemini-content-extractor.log}"
export ERROR_LOG_FILE="${ERROR_LOG_FILE:-/tmp/gemini-content-extractor-errors.log}"
TIMEOUT_SECONDS="${TIMEOUT_SECONDS:-15}"
MAX_CONTENT_SIZE="${MAX_CONTENT_SIZE:-100000}"  # 100KB limit
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common logging functions
# shellcheck source=scripts/common-logging.sh
source "${SCRIPT_DIR}/common-logging.sh"

# Create temp directory
mkdir -p "$TEMP_DIR"

# Function to validate URL
validate_url() {
    local url="$1"

    if [[ -z "$url" ]]; then
        log_error "Empty URL provided"
        return 1
    fi

    # Basic URL validation regex
    if [[ ! "$url" =~ ^https?://[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9](\.[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9])*(:[0-9]{1,5})?(/.*)?$ ]]; then
        log_error "Invalid URL format: $url"
        return 1
    fi
    
    return 0
}

# Function to extract clean text content using Gemini grounded web server
extract_text_content() {
    local url="$1"
    local query="${2:-}"

    log_message "INFO" "Extracting content from $url using Gemini grounded web server"

    # Check if Gemini CLI is available
    if ! command -v gemini >/dev/null 2>&1; then
        log_error "Gemini CLI not found for URL: $url"
        echo "Error: Gemini CLI is required. Install from: npm install -g @google/gemini-cli"
        return 1
    fi

    # Use Gemini CLI in headless mode to extract content
    # The --yolo flag auto-approves the google_web_search tool usage
    log_message "DEBUG" "Using Gemini CLI to extract content from: $url"

    local prompt
    if [[ -n "$query" ]]; then
        prompt="Extract content from this webpage related to '$query': $url. Provide the title and main content in a structured format."
    else
        prompt="Extract and summarize the main content from this webpage: $url. Provide the title and main content."
    fi

    # Execute Gemini CLI in headless mode with --yolo for auto-approval
    local content
    if content=$(gemini -p "/tool:googleSearch query:\"$prompt\" raw:true" --yolo --output-format json -m "gemini-2.5-flash" 2>/dev/null); then
        if [[ -n "$content" ]]; then
            echo "$content"
            log_message "INFO" "Successfully extracted content from $url using Gemini grounded web server"
            return 0
        fi
    fi

    log_error "Failed to extract content from $url using Gemini CLI"
    echo "Error: Could not retrieve content from $url"
    return 1
}

# Function to validate extracted content for relevance
validate_content_relevance() {
    local content="$1"
    local query="$2"
    local url="$3"

    # Convert to lowercase for matching
    local lower_content
    lower_content=$(echo "$content" | tr '[:upper:]' '[:lower:]')
    local lower_query
    lower_query=$(echo "$query" | tr '[:upper:]' '[:lower:]')
    local lower_url
    lower_url=$(echo "$url" | tr '[:upper:]' '[:lower:]')

    # Extract query terms
    local -a query_terms
    read -ra query_terms <<< "$lower_query"
    local total_terms=${#query_terms[@]}
    
    if [[ $total_terms -eq 0 ]]; then
        echo "VALID|100"
        return 0
    fi
    
    # Count matching terms
    local matching_terms=0
    for term in "${query_terms[@]}"; do
        if [[ "$lower_content" == *"$term"* ]] || [[ "$lower_url" == *"$term"* ]]; then
            ((matching_terms++))
        fi
    done
    
    # Calculate relevance percentage
    local relevance_percentage=0
    if [[ $total_terms -gt 0 ]]; then
        relevance_percentage=$((matching_terms * 100 / total_terms))
    fi
    
    # Additional validation checks
    local is_valid=true
    
    # Check for common non-content indicators
    if [[ "$lower_content" =~ (404|not found|error|forbidden|access denied|under construction|coming soon) ]]; then
        is_valid=false
    fi
    
    # Check content length
    local content_length=${#content}
    if [[ $content_length -lt 50 ]]; then
        is_valid=false
    fi
    
    # Return validation result
    if [[ $relevance_percentage -ge 30 ]] && [[ "$is_valid" == "true" ]]; then
        echo "VALID|$relevance_percentage"
        return 0
    else
        echo "INVALID|$relevance_percentage"
        return 1
    fi
}

# Function to extract content from a URL using Gemini grounded web server
extract_content_from_url() {
    local url="$1"
    local query="${2:-}"
    
    log_message "INFO" "Extracting content from $url with query '$query' using Gemini grounded web server"
    
    # Validate URL first
    if ! validate_url "$url"; then
        return 1
    fi
    
    # Extract content using the appropriate method
    local extracted_content
    extracted_content=$(extract_text_content "$url" "$query")
    
    # Validate the extracted content for relevance
    local validation_result
    validation_result=$(validate_content_relevance "$extracted_content" "$query" "$url")
    local validation_status
    validation_status=$(echo "$validation_result" | cut -d'|' -f1)
    local relevance_score
    relevance_score=$(echo "$validation_result" | cut -d'|' -f2)
    
    if [[ "$validation_status" == "VALID" ]]; then
        log_message "INFO" "Successfully extracted relevant content from $url using Gemini grounded web server (relevance: $relevance_score%)"
        echo "$extracted_content"
        echo "[Relevance Score: $relevance_score%]"
        return 0
    else
        log_message "WARN" "Extracted content may be irrelevant from $url (relevance: $relevance_score%)"
        echo "$extracted_content"
        echo "[Warning: Relevance Score: $relevance_score% - Content may not match query '$query']"
        return 0  # Return content even with warning
    fi
}

# Function to sanitize URL (remove fragments, normalize)
sanitize_url() {
    local url="$1"

    # Remove fragment identifiers (part after #)
    url="${url%%#*}"
    
    # Remove query parameters if needed (uncomment next line if needed)
    # url=$(echo "$url" | sed 's/\?.*$//')
    
    echo "$url"
}

# Main function to process a list of URLs
process_urls() {
    local query="$1"
    shift
    local urls=("$@")
    
    local results=()
    local valid_count=0
    
    for url in "${urls[@]}"; do
        local sanitized_url
        sanitized_url=$(sanitize_url "$url")
        
        log_message "INFO" "Processing URL: $sanitized_url"
        
        local content
        if content=$(extract_content_from_url "$sanitized_url" "$query"); then
            # Append URL to content to track source
            results+=("$sanitized_url\n$content\n---\n")
            ((valid_count++))
        else
            log_message "WARN" "Failed to extract content from $sanitized_url"
        fi
    done
    
    # Output all results
    for result in "${results[@]}"; do
        echo -e "$result"
    done
    
    log_message "INFO" "Processed ${#urls[@]} URLs, successfully extracted content from $valid_count using Gemini grounded web server"
}

# Parse command line arguments
case "${1:-}" in
    extract)
        if [[ -n "${3:-}" ]]; then
            # If a query is provided as the second argument
            extract_content_from_url "${2:-}" "${3:-}"
        else
            # If only URL is provided
            extract_content_from_url "${2:-}" ""
        fi
        ;;
    process-urls)
        if [[ $# -lt 3 ]]; then
            log_error "Usage: $0 process-urls query url1 [url2 ... urlN]"
            exit 1
        fi
        query="$2"
        shift 2
        process_urls "$query" "$@"
        ;;
    validate-content)
        validate_content_relevance "${2:-}" "${3:-}" "${4:-}"
        ;;
    sanitize-url)
        sanitize_url "${2:-}"
        ;;
    *)
        log_message "INFO" "Usage: $0 {extract|process-urls|validate-content|sanitize-url} [args...]"
        echo "Usage: $0 {extract|process-urls|validate-content|sanitize-url} [args...]" >&2
        echo "  extract url [query]        # Extract content from a single URL using Gemini grounded web server"
        echo "  process-urls query url1 [url2 ...]  # Process multiple URLs with a query"
        echo "  validate-content content query url   # Validate content relevance"
        echo "  sanitize-url url          # Sanitize URL (remove fragments)"
        exit 1
        ;;
esac