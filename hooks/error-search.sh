#!/bin/bash
# Error detection hook for Gemini Search - Claude Code compatible
# Handles errors and validates results after search operations

# Configuration
MAX_RETRIES="${MAX_RETRIES:-3}"
BACKOFF_BASE="${BACKOFF_BASE:-2}"
EXPONENTIAL_MAX_DELAY="${EXPONENTIAL_MAX_DELAY:-60}"  # Maximum delay in seconds

# Function to detect specific error types with more precision
detect_error_type() {
    local error_output="$1"
    
    # Convert to lowercase for pattern matching
    local lower_error
    lower_error=$(echo "$error_output" | tr '[:upper:]' '[:lower:]')
    
    case "$lower_error" in
        *"timed out"*|*"request timeout"*|*"connection timeout"*|*"timeout"*)
            echo "timeout"
            ;;
        *"page not found"*|*"404 error"*|*"404"*|*"not found"*)
            echo "not_found"
            ;;
        *"internal server error"*|*"bad gateway"*|*"service unavailable"*|*"500"*|*"502"*|*"503"*|*"504"*|*"server error"*)
            echo "server_error"
            ;;
        *"too many requests"*|*"rate limit"*|*"429"*|*"request limit"*|*"api limit"*)
            echo "rate_limit"
            ;;
        *"connection refused"*|*"host unreachable"*|*"dns error"*|*"could not resolve"*|*"network error"*)
            echo "network_error"
            ;;
        *"certificate"*|*"tls"*|*"handshake failed"*|*"ssl"*|*"security"*)
            echo "security_error"
            ;;
        *"access denied"*|*"unauthorized"*|*"403"*|*"401"*|*"forbidden"*)
            echo "access_error"
            ;;
        *"empty response"*|*"no content"*|*"no results"*)
            echo "no_content"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Function to validate search results for false positives
validate_search_results() {
    local results="$1"
    local query="$2"
    local source="$3"
    local min_relevance_score="${4:-50}"  # Minimum score to consider valid
    
    # Convert to lowercase for comparison
    local lower_results
    lower_results=$(echo "$results" | tr '[:upper:]' '[:lower:]')
    local lower_query
    lower_query=$(echo "$query" | tr '[:upper:]' '[:lower:]')
    
    # Split query into terms
    local relevance_score=0
    local query_terms
    IFS=' ' read -ra query_terms <<< "$lower_query"
    local total_terms=${#query_terms[@]}
    
    if [[ $total_terms -eq 0 ]]; then
        echo "VALID|100"  # If no query terms, consider it valid
        return 0
    fi
    
    # Check if query terms appear in the results
    for term in "${query_terms[@]}"; do
        if [[ "$lower_results" == *"$term"* ]]; then
            ((relevance_score++))
        fi
    done
    
    # Calculate relevance percentage
    local relevance_percentage=0
    if [[ $total_terms -gt 0 ]]; then
        relevance_percentage=$((relevance_score * 100 / total_terms))
    fi
    
    # Additional validation checks
    local is_valid=true
    
    # Check for common false positive indicators in source
    if [[ "$source" == *"example.com"* ]] || [[ "$source" == *"test.com"* ]] || [[ "$source" == *"invalid.com"* ]]; then
        is_valid=false
    fi
    
    # Check for minimum content quality
    local content_length=${#results}
    if [[ $content_length -lt 10 ]]; then  # Less than 10 characters
        is_valid=false
    fi
    
    # Blacklist of invalid content patterns
    if [[ "$results" == *"error"* ]] || [[ "$results" == *"failed"* ]] || [[ "$results" == *"invalid"* ]]; then
        is_valid=false
    fi
    
    # Return validation result
    if [[ $relevance_percentage -ge $min_relevance_score ]] && [[ "$is_valid" == "true" ]]; then
        echo "VALID|$relevance_percentage"
        return 0
    else
        echo "INVALID|$relevance_percentage"
        return 1
    fi
}

# Function to handle specific error types with more detailed responses
handle_error() {
    local error_type="$1"
    local original_query="$2"
    local search_engine="${3:-default}"
    
    case "$error_type" in
        "timeout")
            echo "# Gemini Search: Request timed out"
            echo "# Suggestion: Try rephrasing your query with more specific terms"
            ;;
        "not_found")
            echo "# Gemini Search: No results found for query '$original_query'"
            echo "# Suggestion: Try different keywords or broader search terms"
            ;;
        "server_error")
            echo "# Gemini Search: Service temporarily unavailable"
            echo "# This is likely a temporary issue. Please try again later."
            ;;
        "rate_limit")
            echo "# Gemini Search: Rate limit exceeded for $search_engine"
            echo "# Please wait before making more searches."
            ;;
        "network_error")
            echo "# Gemini Search: Network connectivity issue detected"
            echo "# Please check your internet connection."
            ;;
        "security_error")
            echo "# Gemini Search: Security or certificate error occurred"
            ;;
        "access_error")
            echo "# Gemini Search: Access denied to search service"
            ;;
        "no_content")
            echo "# Gemini Search: Search returned empty results for '$original_query'"
            echo "# Try broadening your search terms."
            ;;
        *)
            echo "# Gemini Search: Unexpected error occurred"
            echo "# Error type: $error_type"
            echo "# Query: $original_query"
            ;;
    esac
}

# Main hook execution - this is called by Claude Code when the hook is triggered
main() {
    # Get the input from stdin (Claude's output, error, or result)
    local input_data
    if [[ -t 0 ]]; then
        # No input from stdin, use environment or default
        input_data="${CLAUDE_CONTEXT:-${1:-}}"
    else
        # Read from stdin
        input_data=$(cat)
    fi
    
    # Determine if this is an error situation or a result validation situation
    local search_query="${1:-}"
    
    # If there's data that looks like search results, validate them
    if [[ -n "$input_data" && -n "$search_query" ]]; then
        local validation_result
        validation_result=$(validate_search_results "$input_data" "$search_query" "search" 40)
        local validation_status
        validation_status=$(echo "$validation_result" | cut -d'|' -f1)
        local relevance_score
        relevance_score=$(echo "$validation_result" | cut -d'|' -f2)
        
        if [[ "$validation_status" == "INVALID" ]]; then
            echo "# Gemini Search: Warning - Results may be irrelevant to query '$search_query' (relevance: $relevance_score%)"
            echo "# Consider trying a different query."
        fi
    elif [[ -n "$input_data" ]]; then
        # This might be an error message, try to detect and handle it
        local error_type
        error_type=$(detect_error_type "$input_data")
        if [[ "$error_type" != "unknown" ]]; then
            handle_error "$error_type" "$search_query"
        fi
    fi
}

# Execute the main function
main "$@"