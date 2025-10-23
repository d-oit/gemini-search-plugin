#!/bin/bash
# Common logging functions for gemini-search plugin
# Sourced by multiple scripts to provide consistent logging

# Logging function
# Usage: log_message "LEVEL" "message" ["log_file"]
log_message() {
    local level="$1"
    local message="$2"
    local log_file="${3:-${LOG_FILE:-/tmp/gemini-search.log}}"
    local timestamp
    timestamp=$(date -Iseconds)
    local log_entry="{\"timestamp\":\"$timestamp\",\"level\":\"$level\",\"message\":\"$message\"}"

    echo "$log_entry" >> "$log_file"
    # Also output to stderr for immediate visibility
    echo "$log_entry" >&2
}

# Error logging function
# Usage: log_error "message" ["error_log_file"]
log_error() {
    local message="$1"
    local error_log="${2:-${ERROR_LOG_FILE:-/tmp/gemini-search-errors.log}}"
    local timestamp
    timestamp=$(date -Iseconds)
    local log_entry="{\"timestamp\":\"$timestamp\",\"level\":\"ERROR\",\"message\":\"$message\"}"

    echo "$log_entry" >> "$error_log"
    echo "$log_entry" >&2
}
