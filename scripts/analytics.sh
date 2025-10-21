#!/bin/bash
# Enhanced analytics tracking script for Gemini Search plugin with error handling and logging

# Configuration
ANALYTICS_DIR="${ANALYTICS_DIR:-/tmp/gemini-analytics}"
LOG_FILE="${ANALYTICS_DIR}/search-analytics.log"
AGGREGATE_FILE="${ANALYTICS_DIR}/search-aggregates.json"
ERROR_LOG_FILE="${ANALYTICS_DIR}/search-analytics-errors.log"

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

# Ensure analytics directory exists
mkdir -p "$ANALYTICS_DIR" 2>/dev/null || {
    log_error "Failed to create analytics directory: $ANALYTICS_DIR"
    exit 1
}

# Check if jq is available
if ! command -v jq >/dev/null 2>&1; then
    log_error "jq command not available. Please install jq for JSON processing."
    exit 1
fi

# Function to track a search event with error handling
track_search_event() {
    local event_type="$1"
    local query="$2"
    local engine="${3:-default}"
    local response_time="${4:-0}"

    local timestamp
    timestamp=$(date -Iseconds)
    local event_json="{\"timestamp\":\"$timestamp\",\"event_type\":\"$event_type\",\"query\":\"$query\",\"engine\":\"$engine\",\"response_time_ms\":$response_time}"
    
    if echo "$event_json" >> "$LOG_FILE" 2>/dev/null; then
        log_message "INFO" "Tracked search event: $event_type for query: $query"
    else
        log_error "Failed to write search event to log file: $LOG_FILE"
        return 1
    fi
}

# Function to update aggregate statistics with error handling
update_aggregates() {
    # Initialize aggregates file if it doesn't exist
    if [[ ! -f "$AGGREGATE_FILE" ]]; then
        if echo '{"total_searches":0,"cache_hits":0,"cache_misses":0,"search_engines_used":{},"top_queries":{}}' > "$AGGREGATE_FILE" 2>/dev/null; then
            log_message "INFO" "Initialized aggregate statistics file"
        else
            log_error "Failed to initialize aggregate statistics file: $AGGREGATE_FILE"
            return 1
        fi
    fi
    
    # Increment total searches
    increment_counter "total_searches" || return 1
}

# Function to increment a counter in the aggregates file with error handling
increment_counter() {
    local counter_name="$1"
    
    if [[ ! -f "$AGGREGATE_FILE" ]]; then
        log_error "Aggregate file does not exist: $AGGREGATE_FILE"
        return 1
    fi
    
    local current_value
    if ! current_value=$(jq -r ".${counter_name}" "$AGGREGATE_FILE" 2>/dev/null) || [[ "$current_value" == "null" ]]; then
        log_error "Failed to read counter $counter_name from $AGGREGATE_FILE"
        return 1
    fi
    
    local new_value=$((current_value + 1))
    
    # Update the specific counter with atomic write
    if jq --argjson value "$new_value" ".${counter_name} = \$value" "$AGGREGATE_FILE" > "${AGGREGATE_FILE}.tmp" 2>/dev/null; then
        if mv "${AGGREGATE_FILE}.tmp" "$AGGREGATE_FILE" 2>/dev/null; then
            log_message "INFO" "Incremented counter $counter_name to $new_value"
        else
            log_error "Failed to move temporary aggregate file"
            rm -f "${AGGREGATE_FILE}.tmp" 2>/dev/null
            return 1
        fi
    else
        log_error "Failed to update counter $counter_name in $AGGREGATE_FILE"
        rm -f "${AGGREGATE_FILE}.tmp" 2>/dev/null
        return 1
    fi
}

# Function to record cache hit/miss with error handling
record_cache_event() {
    local event_type="$1"  # "hit" or "miss"
    
    if [[ "$event_type" != "hit" && "$event_type" != "miss" ]]; then
        log_error "Invalid cache event type: $event_type. Expected 'hit' or 'miss'."
        return 1
    fi
    
    if increment_counter "cache_${event_type}s"; then
        log_message "INFO" "Recorded cache ${event_type}"
        return 0
    else
        log_error "Failed to record cache ${event_type}"
        return 1
    fi
}

# Function to track search engine usage with error handling
track_engine_usage() {
    local engine="$1"
    
    if [[ -z "$engine" ]]; then
        log_error "Empty engine name provided"
        return 1
    fi
    
    if [[ ! -f "$AGGREGATE_FILE" ]]; then
        log_error "Aggregate file does not exist: $AGGREGATE_FILE"
        return 1
    fi
    
    # Get current engine usage map
    local current_engines
    if ! current_engines=$(jq -r '.search_engines_used' "$AGGREGATE_FILE" 2>/dev/null) || [[ "$current_engines" == "null" ]]; then
        log_error "Failed to read search engines from $AGGREGATE_FILE"
        return 1
    fi

    # Get current count for this engine
    local current_count
    if ! current_count=$(echo "$current_engines" | jq -r ".${engine} // 0" 2>/dev/null) || [[ "$current_count" == "null" ]]; then
        current_count=0
    fi
    
    local new_count=$((current_count + 1))
    
    # Update the engine usage with atomic write
    if jq --arg engine "$engine" --argjson count "$new_count" '.search_engines_used[$engine] = $count' "$AGGREGATE_FILE" > "${AGGREGATE_FILE}.tmp" 2>/dev/null; then
        if mv "${AGGREGATE_FILE}.tmp" "$AGGREGATE_FILE" 2>/dev/null; then
            log_message "INFO" "Updated engine $engine usage to $new_count"
        else
            log_error "Failed to move temporary aggregate file during engine tracking"
            rm -f "${AGGREGATE_FILE}.tmp" 2>/dev/null
            return 1
        fi
    else
        log_error "Failed to update engine $engine usage in $AGGREGATE_FILE"
        rm -f "${AGGREGATE_FILE}.tmp" 2>/dev/null
        return 1
    fi
}

# Function to track top queries with error handling
track_top_query() {
    local query="$1"
    
    if [[ -z "$query" ]]; then
        log_error "Empty query provided for tracking"
        return 1
    fi
    
    if [[ ! -f "$AGGREGATE_FILE" ]]; then
        log_error "Aggregate file does not exist: $AGGREGATE_FILE"
        return 1
    fi
    
    # Get current top queries map
    local current_queries
    if ! current_queries=$(jq -r '.top_queries' "$AGGREGATE_FILE" 2>/dev/null) || [[ "$current_queries" == "null" ]]; then
        log_error "Failed to read top queries from $AGGREGATE_FILE"
        return 1
    fi

    # Get current count for this query
    local current_count
    if ! current_count=$(echo "$current_queries" | jq -r ".[\"$query\"] // 0" 2>/dev/null) || [[ "$current_count" == "null" ]]; then
        current_count=0
    fi
    
    local new_count=$((current_count + 1))

    # Update the query count with atomic write
    if jq --arg query "$query" --argjson count "$new_count" '.top_queries[$query] = $count' "$AGGREGATE_FILE" > "${AGGREGATE_FILE}.tmp" 2>/dev/null; then
        if mv "${AGGREGATE_FILE}.tmp" "$AGGREGATE_FILE" 2>/dev/null; then
            log_message "INFO" "Updated query '$query' count to $new_count"
        else
            log_error "Failed to move temporary aggregate file during query tracking"
            rm -f "${AGGREGATE_FILE}.tmp" 2>/dev/null
            return 1
        fi
    else
        log_error "Failed to update query '$query' count in $AGGREGATE_FILE"
        rm -f "${AGGREGATE_FILE}.tmp" 2>/dev/null
        return 1
    fi
    
    # Sort and limit top queries to 10 most popular
    maintain_top_queries || log_error "Failed to maintain top queries"
}

# Function to maintain only top 10 queries
maintain_top_queries() {
    if [[ ! -f "$AGGREGATE_FILE" ]]; then
        log_error "Aggregate file does not exist: $AGGREGATE_FILE"
        return 1
    fi
    
    # Extract queries and counts, sort by count, keep top 10
    local top_queries_json
    if ! top_queries_json=$(jq -r '.top_queries | to_entries | sort_by(.value) | reverse | limit(10; .) | from_entries' "$AGGREGATE_FILE" 2>/dev/null) || [[ "$top_queries_json" == "null" ]]; then
        log_error "Failed to extract and sort top queries from $AGGREGATE_FILE"
        return 1
    fi
    
    # Update the file with only top 10 queries using atomic write
    if jq --argjson top_queries "$top_queries_json" '.top_queries = $top_queries' "$AGGREGATE_FILE" > "${AGGREGATE_FILE}.tmp" 2>/dev/null; then
        if mv "${AGGREGATE_FILE}.tmp" "$AGGREGATE_FILE" 2>/dev/null; then
            log_message "INFO" "Maintained top 10 queries in aggregate file"
        else
            log_error "Failed to move temporary aggregate file during top queries maintenance"
            rm -f "${AGGREGATE_FILE}.tmp" 2>/dev/null
            return 1
        fi
    else
        log_error "Failed to update top queries in $AGGREGATE_FILE"
        rm -f "${AGGREGATE_FILE}.tmp" 2>/dev/null
        return 1
    fi
}

# Function to calculate token savings estimate
calculate_token_savings() {
    local cache_hit_rate=0
    local total_searches
    local cache_hits
    
    if [[ ! -f "$AGGREGATE_FILE" ]]; then
        echo "0"
        return 0
    fi
    
    total_searches=$(jq -r '.total_searches' "$AGGREGATE_FILE" 2>/dev/null || echo 0)
    cache_hits=$(jq -r '.cache_hits' "$AGGREGATE_FILE" 2>/dev/null || echo 0)
    
    if ! [[ "$total_searches" =~ ^[0-9]+$ ]] || ! [[ "$cache_hits" =~ ^[0-9]+$ ]]; then
        log_error "Invalid data in aggregate file: total_searches=$total_searches, cache_hits=$cache_hits"
        echo "0"
        return 0
    fi
    
    if [[ $total_searches -gt 0 ]]; then
        cache_hit_rate=$((cache_hits * 100 / total_searches))
    fi
    
    # Estimate 39% token savings based on cache hit rate
    local estimated_savings=$((cache_hit_rate * 39 / 100))
    
    echo "$estimated_savings"
}

# Function to get formatted analytics report with error handling
get_analytics_report() {
    if [[ ! -f "$AGGREGATE_FILE" ]]; then
        echo "No analytics data available - aggregate file not found"
        log_message "WARN" "Analytics aggregate file not found: $AGGREGATE_FILE"
        return 1
    fi
    
    local total_searches
    local cache_hits 
    local cache_misses
    local cache_hit_rate=0
    
    total_searches=$(jq -r '.total_searches' "$AGGREGATE_FILE" 2>/dev/null || echo 0)
    cache_hits=$(jq -r '.cache_hits' "$AGGREGATE_FILE" 2>/dev/null || echo 0)
    cache_misses=$(jq -r '.cache_misses' "$AGGREGATE_FILE" 2>/dev/null || echo 0)
    
    if ! [[ "$total_searches" =~ ^[0-9]+$ ]] || ! [[ "$cache_hits" =~ ^[0-9]+$ ]] || ! [[ "$cache_misses" =~ ^[0-9]+$ ]]; then
        log_error "Invalid numeric data in aggregate file"
        echo "Error: Invalid analytics data"
        return 1
    fi
    
    if [[ $total_searches -gt 0 ]]; then
        cache_hit_rate=$((cache_hits * 100 / total_searches))
    fi
    
    local estimated_savings
    estimated_savings=$(calculate_token_savings)
    
    local engine_usage
    local top_queries
    
    engine_usage=$(jq -r '.search_engines_used' "$AGGREGATE_FILE" 2>/dev/null || echo "{}")
    top_queries=$(jq -r '.top_queries' "$AGGREGATE_FILE" 2>/dev/null || echo "{}")
    
    echo "=== Gemini Search Analytics Report ==="
    echo "Total Searches: $total_searches"
    echo "Cache Hits: $cache_hits"
    echo "Cache Misses: $cache_misses"
    echo "Cache Hit Rate: ${cache_hit_rate}%"
    echo "Estimated Token Savings: ${estimated_savings}%"
    echo ""
    echo "Search Engine Usage: $engine_usage"
    echo ""
    echo "Top Queries: $top_queries"
    echo "====================================="
    
    log_message "INFO" "Generated analytics report"
}

# Function to validate and clean analytics data
validate_analytics_data() {
    if [[ ! -f "$AGGREGATE_FILE" ]]; then
        log_message "INFO" "No aggregate file to validate"
        return 0
    fi
    
    # Validate JSON structure
    if jq empty "$AGGREGATE_FILE" 2>/dev/null; then
        log_message "INFO" "Analytics data validation passed"
    else
        log_error "Analytics data validation failed - invalid JSON in $AGGREGATE_FILE"
        return 1
    fi
}

# Parse command line arguments
case "${1:-}" in
    init)
        # Initialize analytics files
        if [[ ! -f "$AGGREGATE_FILE" ]]; then
            if echo '{"total_searches":0,"cache_hits":0,"cache_misses":0,"search_engines_used":{},"top_queries":{}}' > "$AGGREGATE_FILE" 2>/dev/null; then
                log_message "INFO" "Initialized aggregate statistics file"
                echo "Analytics initialized successfully"
            else
                log_error "Failed to initialize aggregate statistics file: $AGGREGATE_FILE"
                exit 1
            fi
        else
            log_message "INFO" "Analytics already initialized"
            echo "Analytics already initialized"
        fi
        ;;
    track-search)
        if track_search_event "${2:-}" "${3:-}" "${4:-}" "${5:-}"; then
            update_aggregates
            track_engine_usage "${4:-default}"
            track_top_query "${3:-unknown}"
        else
            log_error "Failed to track search event"
            exit 1
        fi
        ;;
    record-cache-event)
        if ! record_cache_event "${2:-}"; then
            log_error "Failed to record cache event"
            exit 1
        fi
        ;;
    report)
        if ! get_analytics_report; then
            log_error "Failed to generate analytics report"
            exit 1
        fi
        ;;
    reset)
        if rm -f "$LOG_FILE" "$AGGREGATE_FILE" 2>/dev/null; then
            log_message "INFO" "Analytics data reset"
            echo "Analytics data reset"
        else
            log_error "Failed to reset analytics data"
            exit 1
        fi
        ;;
    validate)
        if validate_analytics_data; then
            echo "Analytics data validation successful"
        else
            log_error "Analytics data validation failed"
            exit 1
        fi
        ;;
    *)
        log_message "INFO" "Usage: $0 {init|track-search|record-cache-event|report|reset|validate} [args...]"
        echo "Usage: $0 {init|track-search|record-cache-event|report|reset|validate} [args...]" >&2
        echo "  init"
        echo "  track-search event_type query engine response_time"
        echo "  record-cache-event hit|miss"
        echo "  report"
        echo "  reset"
        echo "  validate"
        exit 1
        ;;
esac