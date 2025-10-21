#!/bin/bash
# Template script for Claude Code plugin
# Replace this with your actual script logic

set -euo pipefail

# Configuration
SCRIPT_DIR="${CLAUDE_PLUGIN_ROOT}/scripts"
LOG_FILE="${LOG_FILE:-/tmp/my-plugin.log}"
ERROR_LOG="${ERROR_LOG:-/tmp/my-plugin-errors.log}"

# Logging functions
function log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

function error_log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $*" >> "$ERROR_LOG"
    echo "ERROR: $*" >&2
}

# Error handler
function error_handler() {
    local line_num=$1
    error_log "Script failed on line $line_num"
    exit 1
}

trap 'error_handler ${LINENO}' ERR

# Main function
function main() {
    local arg1="${1:-}"

    if [[ -z "$arg1" ]]; then
        error_log "Missing required argument"
        echo '{"status":"error","message":"Missing required argument"}' >&2
        exit 1
    fi

    log "Processing: $arg1"

    # Your logic here
    local result="processed: $arg1"

    # Return JSON for structured output
    echo "{\"status\":\"success\",\"result\":\"$result\"}"

    log "Successfully processed: $arg1"
}

# Entry point
main "$@"
