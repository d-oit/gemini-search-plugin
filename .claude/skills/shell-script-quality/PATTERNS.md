# Common Shell Script Patterns

Best practice patterns and anti-patterns for shell scripting.

## Script Header Template

```bash
#!/bin/bash
set -euo pipefail

# Script metadata
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

# Enable debug mode
[[ "${DEBUG:-}" == "true" ]] && set -x
```

## Error Handling

### Basic Error Handler
```bash
error_exit() {
    echo "ERROR: $1" >&2
    exit "${2:-1}"
}

# Usage
[[ -f "$config" ]] || error_exit "Config not found: $config" 2
```

### Trap Error Handler
```bash
cleanup() {
    local exit_code=$?
    [[ -f "$TEMP_FILE" ]] && rm -f "$TEMP_FILE"
    exit "$exit_code"
}

trap cleanup EXIT ERR
trap 'error_exit "Script interrupted" 130' INT TERM
```

### Validation Pattern
```bash
validate_inputs() {
    [[ $# -lt 1 ]] && {
        echo "Usage: $0 <input>" >&2
        return 1
    }
    
    [[ -f "$1" ]] || {
        echo "ERROR: File not found: $1" >&2
        return 1
    }
    
    return 0
}

main() {
    validate_inputs "$@" || exit 1
    # Process...
}
```

## Logging Patterns

### Structured Logging
```bash
LOG_FILE="${LOG_FILE:-/tmp/${SCRIPT_NAME%.sh}.log}"
LOG_LEVEL="${LOG_LEVEL:-INFO}"

log() {
    local level="$1"; shift
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    printf "[%s] [%s] %s\n" "$timestamp" "$level" "$*" | tee -a "$LOG_FILE" >&2
}

log_debug() { [[ "$LOG_LEVEL" == "DEBUG" ]] && log "DEBUG" "$@"; }
log_info() { log "INFO" "$@"; }
log_warn() { log "WARN" "$@"; }
log_error() { log "ERROR" "$@"; }
```

### Progress Indicator
```bash
show_progress() {
    local current="$1" total="$2" message="${3:-Processing}"
    local percent=$((current * 100 / total))
    printf "\r%s: %d%% [%d/%d]" "$message" "$percent" "$current" "$total"
    [[ "$current" -eq "$total" ]] && echo
}
```

## Function Patterns

### Documented Functions
```bash
# Function: process_data
# Description: Processes input data and writes to output
# Arguments:
#   $1 - input_file (required, string)
#   $2 - output_file (optional, string, default: stdout)
# Returns:
#   0 - Success
#   1 - Invalid input
#   2 - Processing error
process_data() {
    local input_file="$1"
    local output_file="${2:-/dev/stdout}"
    
    [[ -z "$input_file" ]] && return 1
    [[ -f "$input_file" ]] || return 1
    
    cat "$input_file" > "$output_file" || return 2
    return 0
}
```

### Optional Arguments with Defaults
```bash
process() {
    local input="${1:?Input required}"
    local output="${2:-output.txt}"
    local verbose="${3:-false}"
    
    [[ "$verbose" == "true" ]] && echo "Processing $input -> $output"
    # Process...
}
```

## Claude Plugin Patterns

### Plugin Root Resolution
```bash
# Portable plugin root
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/..' && pwd)}"

# Use absolute paths
CONFIG_FILE="$PLUGIN_ROOT/config/settings.json"
DATA_DIR="$PLUGIN_ROOT/data"
```

### Hook Input Parsing
```bash
parse_hook_input() {
    local input="$(cat)"
    local tool="$(echo "$input" | jq -r '.tool')"
    local params="$(echo "$input" | jq -r '.params')"
    
    echo "Tool: $tool"
    echo "Params: $params"
}
```

### JSON Output
```bash
output_json() {
    local status="$1" message="$2"
    jq -n \
        --arg status "$status" \
        --arg message "$message" \
        '{status: $status, message: $message}'
}

# Usage
output_json "success" "Operation completed"
```

## Safe File Operations

### Temp File Handling
```bash
TEMP_FILE="$(mktemp)" || error_exit "Failed to create temp file"
trap 'rm -f "$TEMP_FILE"' EXIT

# Use temp file
echo "data" > "$TEMP_FILE"
```

### Safe File Updates
```bash
update_file() {
    local file="$1" content="$2"
    local backup="${file}.bak"
    
    # Backup
    [[ -f "$file" ]] && cp "$file" "$backup"
    
    # Update
    echo "$content" > "$file" || {
        [[ -f "$backup" ]] && mv "$backup" "$file"
        return 1
    }
    
    # Remove backup on success
    [[ -f "$backup" ]] && rm -f "$backup"
    return 0
}
```

## Command Validation

```bash
require_commands() {
    local missing=()
    for cmd in "$@"; do
        command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "ERROR: Missing required commands: ${missing[*]}" >&2
        return 1
    fi
    return 0
}

# Usage
require_commands curl jq git || exit 1
```

## Main Execution Guard

```bash
main() {
    # Main logic here
    echo "Running main function"
}

# Only run if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

## Anti-Patterns to Avoid

### ❌ Bad: Unquoted Variables
```bash
cp $file $dest  # Word splitting!
```

### ✅ Good: Quoted Variables
```bash
cp "$file" "$dest"
```

### ❌ Bad: Using $?
```bash
command
if [[ $? -ne 0 ]]; then
```

### ✅ Good: Direct Test
```bash
if ! command; then
```

### ❌ Bad: Masked Return Values
```bash
local result=$(failing_command)
```

### ✅ Good: Separate Declaration
```bash
local result
result=$(failing_command)
```

### ❌ Bad: Unsafe Loops
```bash
for file in $(ls *.txt); do
```

### ✅ Good: Glob Pattern
```bash
for file in *.txt; do
    [[ -f "$file" ]] || continue
```

## Performance Patterns

### Parallel Processing
```bash
process_parallel() {
    local max_jobs=4
    local job_count=0
    
    for file in *.txt; do
        process_file "$file" &
        ((job_count++))
        
        if [[ $job_count -ge $max_jobs ]]; then
            wait -n  # Wait for any job to finish
            ((job_count--))
        fi
    done
    
    wait  # Wait for remaining jobs
}
```

### Caching
```bash
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/myscript"
mkdir -p "$CACHE_DIR"

get_cached() {
    local key="$1" cache_file="$CACHE_DIR/$key"
    
    if [[ -f "$cache_file" ]]; then
        # Check if cache is fresh (< 1 hour)
        local age=$(( $(date +%s) - $(stat -f%m "$cache_file" 2>/dev/null || stat -c%Y "$cache_file") ))
        [[ $age -lt 3600 ]] && cat "$cache_file" && return 0
    fi
    
    return 1
}
```
