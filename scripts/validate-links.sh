#!/bin/bash
set -euo pipefail

# Static Link Validation Script
# Validates URLs and checks if they exist and are accessible

# Configuration
TIMEOUT_SECONDS="${TIMEOUT_SECONDS:-10}"
USER_AGENT="Mozilla/5.0 (compatible; ClaudeCodeBot/1.0)"
MAX_REDIRECTS="${MAX_REDIRECTS:-5}"

# Function: Check if URL exists and is accessible
# Arguments:
#   $1 - url (string)
# Returns: 0 if valid, 1 if invalid
check_url_exists() {
    local url="$1"

    # Use curl with HEAD request to check if URL exists
    if command -v curl >/dev/null 2>&1; then
        local http_code
        http_code=$(curl -A "$USER_AGENT" \
            --silent \
            --head \
            --location \
            --max-redirs "$MAX_REDIRECTS" \
            --max-time "$TIMEOUT_SECONDS" \
            --write-out "%{http_code}" \
            --output /dev/null \
            "$url" 2>/dev/null || echo "000")

        # Check HTTP status code
        if [[ "$http_code" -ge 200 ]] && [[ "$http_code" -lt 400 ]]; then
            return 0  # Valid URL
        else
            echo "HTTP $http_code" >&2
            return 1  # Invalid URL
        fi
    elif command -v wget >/dev/null 2>&1; then
        # Fallback to wget
        if wget --spider \
            --user-agent="$USER_AGENT" \
            --timeout="$TIMEOUT_SECONDS" \
            --max-redirect="$MAX_REDIRECTS" \
            --quiet \
            "$url" 2>/dev/null; then
            return 0  # Valid URL
        else
            return 1  # Invalid URL
        fi
    else
        # Neither curl nor wget available, use Gemini CLI as fallback
        echo "SKIP: No HTTP client available" >&2
        return 2  # Cannot validate
    fi
}

# Function: Validate URL format
# Arguments:
#   $1 - url (string)
# Returns: 0 if valid format, 1 if invalid
validate_url_format() {
    local url="$1"

    # Check if URL has valid format
    if [[ "$url" =~ ^https?://[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*(/.*)?$ ]]; then
        return 0  # Valid format
    else
        echo "Invalid URL format" >&2
        return 1  # Invalid format
    fi
}

# Function: Check URL against blacklist
# Arguments:
#   $1 - url (string)
# Returns: 0 if not blacklisted, 1 if blacklisted
check_url_blacklist() {
    local url="$1"
    local lower_url
    lower_url=$(echo "$url" | tr '[:upper:]' '[:lower:]')

    # Blacklisted domains
    local blacklist=(
        "example.com"
        "test.com"
        "invalid.com"
        "localhost"
        "127.0.0.1"
        "0.0.0.0"
        "::1"
        "*.local"
    )

    for domain in "${blacklist[@]}"; do
        if [[ "$lower_url" == *"$domain"* ]]; then
            echo "Blacklisted domain: $domain" >&2
            return 1  # Blacklisted
        fi
    done

    return 0  # Not blacklisted
}

# Function: Check search relevance to result
# Arguments:
#   $1 - query (string)
#   $2 - title (string)
#   $3 - snippet (string)
#   $4 - url (string)
# Returns: relevance score 0-100
calculate_relevance_score() {
    local query="$1"
    local title="$2"
    local snippet="$3"
    local url="$4"

    # Convert to lowercase
    local lower_query
    lower_query=$(echo "$query" | tr '[:upper:]' '[:lower:]')
    local lower_title
    lower_title=$(echo "$title" | tr '[:upper:]' '[:lower:]')
    local lower_snippet
    lower_snippet=$(echo "$snippet" | tr '[:upper:]' '[:lower:]')
    local lower_url
    lower_url=$(echo "$url" | tr '[:upper:]' '[:lower:]')

    # Split query into terms
    local -a query_terms
    read -ra query_terms <<< "$lower_query"
    local total_terms=${#query_terms[@]}
    local matched_terms=0

    # Count matched terms
    for term in "${query_terms[@]}"; do
        # Skip very short terms (likely stop words)
        if [[ ${#term} -lt 3 ]]; then
            continue
        fi

        # Check if term appears in title, snippet, or URL
        if [[ "$lower_title" == *"$term"* ]] || \
           [[ "$lower_snippet" == *"$term"* ]] || \
           [[ "$lower_url" == *"$term"* ]]; then
            ((matched_terms++))
        fi
    done

    # Calculate relevance percentage
    local relevance=0
    if [[ $total_terms -gt 0 ]]; then
        relevance=$((matched_terms * 100 / total_terms))
    fi

    echo "$relevance"
}

# Function: Enhanced validation combining all checks
# Arguments:
#   $1 - query (string)
#   $2 - title (string)
#   $3 - url (string)
#   $4 - snippet (string)
# Returns: JSON validation result
validate_search_result() {
    local query="$1"
    local title="$2"
    local url="$3"
    local snippet="$4"

    local validation_result="{"
    local is_valid=true
    local failure_reasons=()

    # 1. Validate URL format
    if ! validate_url_format "$url"; then
        is_valid=false
        failure_reasons+=("invalid_url_format")
    fi

    # 2. Check URL blacklist
    if ! check_url_blacklist "$url"; then
        is_valid=false
        failure_reasons+=("blacklisted_domain")
    fi

    # 3. Check if URL exists (static check)
    local url_status="unknown"
    if [[ "$is_valid" == "true" ]]; then
        if check_url_exists "$url"; then
            url_status="accessible"
        else
            url_status="inaccessible"
            is_valid=false
            failure_reasons+=("url_not_accessible")
        fi
    fi

    # 4. Calculate relevance score
    local relevance_score
    relevance_score=$(calculate_relevance_score "$query" "$title" "$snippet" "$url")

    # 5. Check relevance threshold
    local relevance_threshold=50
    if [[ $relevance_score -lt $relevance_threshold ]]; then
        is_valid=false
        failure_reasons+=("low_relevance")
    fi

    # Build JSON result
    validation_result+="\"valid\": $is_valid,"
    validation_result+="\"url\": \"$url\","
    validation_result+="\"url_status\": \"$url_status\","
    validation_result+="\"relevance_score\": $relevance_score,"
    validation_result+="\"relevance_threshold\": $relevance_threshold,"

    # Add failure reasons if any
    if [[ ${#failure_reasons[@]} -gt 0 ]]; then
        validation_result+="\"failure_reasons\": ["
        for ((i=0; i<${#failure_reasons[@]}; i++)); do
            validation_result+="\"${failure_reasons[$i]}\""
            if [[ $i -lt $((${#failure_reasons[@]} - 1)) ]]; then
                validation_result+=","
            fi
        done
        validation_result+="]"
    else
        validation_result+="\"failure_reasons\": []"
    fi

    validation_result+="}"

    echo "$validation_result"
}

# Main function for command-line usage
main() {
    if [[ $# -lt 4 ]]; then
        echo "Usage: $0 <query> <title> <url> <snippet>"
        echo ""
        echo "Example:"
        echo "  $0 \"Claude Code plugins\" \"Plugin Guide\" \"https://docs.claude.com/plugins\" \"Guide to plugins\""
        exit 1
    fi

    local query="$1"
    local title="$2"
    local url="$3"
    local snippet="$4"

    # Perform validation
    local result
    result=$(validate_search_result "$query" "$title" "$url" "$snippet")

    # Output result
    echo "$result"

    # Return appropriate exit code
    if echo "$result" | grep -q '"valid": true'; then
        exit 0
    else
        exit 1
    fi
}

# Run main if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
