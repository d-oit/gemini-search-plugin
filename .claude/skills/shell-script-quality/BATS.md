# BATS Testing Guide

Comprehensive BATS reference for shell script testing.

## Test Structure

```bash
#!/usr/bin/env bats

setup() {
    # Runs before each test
    TEST_TEMP_DIR="$(mktemp -d)"
    source "$BATS_TEST_DIRNAME/../scripts/example.sh"
}

teardown() {
    # Runs after each test
    [[ -d "$TEST_TEMP_DIR" ]] && rm -rf "$TEST_TEMP_DIR"
}

@test "function succeeds" {
    run example_function "valid"
    [ "$status" -eq 0 ]
    [ -n "$output" ]
}
```

## Core Assertions

| Type | Example | Purpose |
|------|---------|---------|
| Status | `[ "$status" -eq 0 ]` | Success |
| Status | `[ "$status" -ne 0 ]` | Failure |
| Output | `[ "$output" = "text" ]` | Exact match |
| Output | `[[ "$output" =~ regex ]]` | Regex match |
| Output | `[[ "$output" == *substring* ]]` | Contains |
| Lines | `[ "${#lines[@]}" -eq 3 ]` | Line count |
| File | `[ -f "$file" ]` | File exists |
| File | `[ -s "$file" ]` | File not empty |

## Common Patterns

### 1. Testing Functions

```bash
@test "process_file succeeds" {
    local file="$(mktemp)"
    echo "test data" > "$file"
    
    run process_file "$file"
    [ "$status" -eq 0 ]
    [ "$output" = "test data" ]
}
```

### 2. Error Handling

```bash
@test "process_file fails gracefully" {
    run process_file "/nonexistent"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "ERROR" ]]
}
```

### 3. Script Arguments

```bash
@test "script handles arguments" {
    run bash "$SCRIPT_DIR/example.sh" arg1 arg2
    [ "$status" -eq 0 ]
    [[ "$output" =~ "arg1" ]]
}
```

### 4. JSON Validation

```bash
@test "returns valid JSON" {
    run bash scripts/api.sh
    [ "$status" -eq 0 ]
    echo "$output" | jq empty
}
```

### 5. Mock External Commands

```bash
create_mock() {
    local cmd="$1" output="$2" code="${3:-0}"
    cat > "$TEST_TEMP_DIR/$cmd" <<EOF
#!/bin/bash
echo "$output"
exit $code
EOF
    chmod +x "$TEST_TEMP_DIR/$cmd"
    export PATH="$TEST_TEMP_DIR:$PATH"
}

@test "handles API failure" {
    create_mock "curl" "connection failed" 7
    run bash scripts/api.sh
    [ "$status" -ne 0 ]
}
```

## Test Helpers

**tests/test_helper/common.bash**:

```bash
setup_test_env() {
    export TEST_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
    export SCRIPT_DIR="$TEST_ROOT/scripts"
    export TEST_TEMP_DIR="$(mktemp -d)"
}

assert_success() {
    [ "$status" -eq 0 ] || {
        echo "Expected success, got $status"
        echo "Output: $output"
        return 1
    }
}

assert_output_contains() {
    [[ "$output" =~ $1 ]] || {
        echo "Expected: $1 in output"
        echo "Actual: $output"
        return 1
    }
}
```

## Advanced Patterns

### Environment Variables
```bash
@test "respects LOG_LEVEL" {
    LOG_LEVEL=DEBUG run bash scripts/logger.sh
    [[ "$output" =~ "[DEBUG]" ]]
}
```

### Piped Input
```bash
@test "reads from stdin" {
    run bash scripts/processor.sh <<< "test input"
    [[ "$output" =~ "test input" ]]
}
```

### Claude Plugin Testing
```bash
@test "uses CLAUDE_PLUGIN_ROOT" {
    export CLAUDE_PLUGIN_ROOT="$BATS_TEST_DIRNAME/.."
    run bash "$CLAUDE_PLUGIN_ROOT/scripts/search.sh" "query"
    [ "$status" -eq 0 ]
}
```

## Quick Commands

```bash
# Run all tests
bats tests/

# Verbose output
bats -t tests/

# TAP output
bats -T tests/

# Count tests
bats -c tests/

# Specific file
bats tests/example.bats
```

## Directory Structure

```
tests/
├── test_helper/
│   └── common.bash      # Shared helpers
├── example.bats         # Main tests
├── hooks.bats           # Hook tests
└── integration.bats     # Integration tests
```

## Coverage

```bash
# Install kcov
sudo apt-get install kcov

# Generate coverage
kcov coverage bats tests/
# View: coverage/index.html
```
