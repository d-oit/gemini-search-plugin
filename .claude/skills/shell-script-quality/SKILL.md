---
name: shell-script-quality
description: Lint and test shell scripts using ShellCheck and BATS following 2025 best practices. Use when working with bash/sh scripts that need quality assurance, testing, or linting.
---

# Shell Script Quality Assurance

This skill helps you implement comprehensive linting and testing for bash/sh scripts using industry-standard tools and best practices from 2025.

## When to Use This Skill

Invoke this skill when the user:
- Asks to lint or check shell scripts
- Wants to add tests for bash/sh scripts
- Needs help with ShellCheck or BATS
- Wants to improve shell script quality
- Asks about bash script best practices
- Needs CI/CD integration for shell scripts
- Wants to set up automated testing for shell scripts

## Core Tools

### 1. ShellCheck - Static Analysis & Linting

**What is ShellCheck?**
ShellCheck is a static analysis tool for shell scripts that finds bugs, syntax errors, and potential issues before they make it to production. It's comparable to flake8 in Python or Rubocop in Ruby.

**Installation:**
```bash
# macOS
brew install shellcheck

# Ubuntu/Debian
sudo apt-get install shellcheck

# Fedora/RHEL
sudo dnf install ShellCheck

# Windows (via WSL or Chocolatey)
choco install shellcheck
```

**Basic Usage:**
```bash
# Lint a single file
shellcheck script.sh

# Lint multiple files
shellcheck scripts/*.sh

# Lint with specific shell dialect
shellcheck -s bash script.sh
shellcheck -s sh script.sh

# Output in different formats
shellcheck -f json script.sh
shellcheck -f gcc script.sh  # For CI/CD
shellcheck -f checkstyle script.sh
```

### 2. BATS - Bash Automated Testing System

**What is BATS?**
BATS is a TAP-compliant testing framework for Bash 3.2+ that provides a simple way to verify that your shell scripts behave as expected.

**Installation:**
```bash
# macOS
brew install bats-core

# Ubuntu/Debian (via npm)
npm install -g bats

# Or clone from GitHub
git clone https://github.com/bats-core/bats-core.git
cd bats-core
sudo ./install.sh /usr/local

# Install helper libraries
npm install -g bats-support bats-assert
```

**Basic Usage:**
```bash
# Run tests
bats test/script.bats

# Run all tests in a directory
bats tests/

# Run with verbose output
bats -t tests/

# Run with TAP output
bats -T tests/
```

## Shell Script Best Practices

### 1. Script Header Template

Every shell script should start with:

```bash
#!/bin/bash
# Script: script-name.sh
# Description: Brief description of what this script does
# Usage: ./script-name.sh [arguments]

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Enable debug mode if DEBUG env var is set
[[ "${DEBUG:-}" == "true" ]] && set -x

# Script directory (portable way)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
```

### 2. Error Handling

```bash
# Custom error handler
error_exit() {
    echo "ERROR: $1" >&2
    exit "${2:-1}"
}

# Trap errors
trap 'error_exit "Script failed at line $LINENO"' ERR

# Usage
[[ -f "$config_file" ]] || error_exit "Config file not found: $config_file" 2
```

### 3. Function Best Practices

```bash
# Document functions with comments
# Arguments:
#   $1 - input_file (string)
#   $2 - output_file (string)
# Returns: 0 on success, 1 on failure
process_file() {
    local input_file="$1"
    local output_file="${2:-/dev/stdout}"

    # Validate arguments
    [[ -z "$input_file" ]] && {
        echo "ERROR: input_file is required" >&2
        return 1
    }

    # Function logic
    cat "$input_file" > "$output_file"
    return 0
}
```

### 4. Input Validation

```bash
# Check for required commands
require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        error_exit "Required command not found: $1"
    fi
}

require_command curl
require_command jq

# Validate arguments
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <argument>" >&2
    exit 1
fi
```

### 5. Logging

```bash
# Configuration
LOG_FILE="${LOG_FILE:-/tmp/${SCRIPT_NAME%.sh}.log}"
LOG_LEVEL="${LOG_LEVEL:-INFO}"  # DEBUG, INFO, WARN, ERROR

# Logging functions
log_debug() { [[ "$LOG_LEVEL" == "DEBUG" ]] && echo "[DEBUG] $*" | tee -a "$LOG_FILE" >&2; }
log_info()  { echo "[INFO] $*" | tee -a "$LOG_FILE" >&2; }
log_warn()  { echo "[WARN] $*" | tee -a "$LOG_FILE" >&2; }
log_error() { echo "[ERROR] $*" | tee -a "$LOG_FILE" >&2; }

# Usage
log_info "Script started"
log_debug "Processing file: $file"
log_error "Operation failed"
```

### 6. Portable Paths

```bash
# Use ${CLAUDE_PLUGIN_ROOT} for Claude Code plugins
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# Use absolute paths
CONFIG_FILE="$PLUGIN_ROOT/config/settings.json"
DATA_DIR="$PLUGIN_ROOT/data"

# Create temp files safely
TEMP_FILE=$(mktemp) || error_exit "Failed to create temp file"
trap 'rm -f "$TEMP_FILE"' EXIT
```

## Setting Up ShellCheck

### 1. Create .shellcheckrc Configuration

Create `.shellcheckrc` in your project root:

```bash
# .shellcheckrc - ShellCheck configuration

# Specify shell dialect (bash, sh, dash, ksh)
shell=bash

# Disable specific checks (use sparingly!)
# SC1090: Can't follow non-constant source
# SC2034: Variable appears unused
disable=SC1090

# Enable optional checks
enable=all

# Source additional paths (for libraries)
source-path=SCRIPTDIR
```

### 2. Common ShellCheck Fixes

**SC2086: Double quote to prevent globbing and word splitting**
```bash
# Bad
cp $file $dest

# Good
cp "$file" "$dest"
```

**SC2155: Declare and assign separately to avoid masking return values**
```bash
# Bad
local result=$(command_that_might_fail)

# Good
local result
result=$(command_that_might_fail)
```

**SC2181: Check exit code directly with if**
```bash
# Bad
command
if [[ $? -ne 0 ]]; then

# Good
if ! command; then
```

**SC2068: Double quote array expansions**
```bash
# Bad
for arg in $@; do

# Good
for arg in "$@"; do
```

### 3. Ignoring Specific Warnings

```bash
# Ignore on next line
# shellcheck disable=SC2086
cp $file $dest

# Ignore for entire file (place at top)
# shellcheck disable=SC2086

# Ignore with inline comment
cp $file $dest  # shellcheck disable=SC2086
```

## Setting Up BATS Tests

### 1. Test Directory Structure

```
project/
├── scripts/
│   ├── search.sh
│   ├── analytics.sh
│   └── validate.sh
├── tests/
│   ├── test_helper/
│   │   └── common.bash
│   ├── search.bats
│   ├── analytics.bats
│   └── validate.bats
└── .github/
    └── workflows/
        └── test.yml
```

### 2. Basic BATS Test Structure

Create `tests/example.bats`:

```bash
#!/usr/bin/env bats

# Load test helpers
load test_helper/common

# Setup runs before each test
setup() {
    # Create temp directory
    TEST_TEMP_DIR="$(mktemp -d)"

    # Set environment variables
    export LOG_FILE="$TEST_TEMP_DIR/test.log"

    # Source the script to test
    source "$BATS_TEST_DIRNAME/../scripts/example.sh"
}

# Teardown runs after each test
teardown() {
    # Clean up temp files
    [[ -d "$TEST_TEMP_DIR" ]] && rm -rf "$TEST_TEMP_DIR"
}

# Test 1: Function exists
@test "example_function exists" {
    declare -f example_function
}

# Test 2: Function returns success
@test "example_function succeeds with valid input" {
    run example_function "valid_input"

    [ "$status" -eq 0 ]
    [ -n "$output" ]
}

# Test 3: Function handles errors
@test "example_function fails with invalid input" {
    run example_function ""

    [ "$status" -ne 0 ]
    [[ "$output" =~ "ERROR" ]]
}

# Test 4: Output validation
@test "example_function produces expected output" {
    run example_function "test"

    [ "$status" -eq 0 ]
    [ "$output" = "Expected output for: test" ]
}

# Test 5: File operations
@test "example_function creates output file" {
    local output_file="$TEST_TEMP_DIR/output.txt"

    run example_function "test" "$output_file"

    [ "$status" -eq 0 ]
    [ -f "$output_file" ]
    [ -s "$output_file" ]  # File is not empty
}
```

### 3. Common BATS Assertions

```bash
# Status checks
[ "$status" -eq 0 ]      # Command succeeded
[ "$status" -ne 0 ]      # Command failed
[ "$status" -eq 1 ]      # Specific exit code

# Output checks
[ -n "$output" ]         # Output is not empty
[ -z "$output" ]         # Output is empty
[ "$output" = "text" ]   # Exact match
[[ "$output" =~ regex ]] # Regex match
[[ "$output" == *"substring"* ]]  # Contains substring

# File checks
[ -f "$file" ]           # File exists
[ -d "$dir" ]            # Directory exists
[ -s "$file" ]           # File is not empty
[ -x "$file" ]           # File is executable

# Line count
[ "${#lines[@]}" -eq 3 ] # Exactly 3 lines
[ "${lines[0]}" = "first line" ]  # First line matches
```

### 4. Test Helper Library

Create `tests/test_helper/common.bash`:

```bash
# Common test helper functions

# Setup test environment
setup_test_env() {
    export TEST_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
    export SCRIPT_DIR="$TEST_ROOT/scripts"
    export TEST_TEMP_DIR="$(mktemp -d)"
}

# Cleanup test environment
cleanup_test_env() {
    [[ -d "$TEST_TEMP_DIR" ]] && rm -rf "$TEST_TEMP_DIR"
}

# Assert command succeeds
assert_success() {
    if [ "$status" -ne 0 ]; then
        echo "Expected success but got status $status"
        echo "Output: $output"
        return 1
    fi
}

# Assert command fails
assert_failure() {
    if [ "$status" -eq 0 ]; then
        echo "Expected failure but got success"
        echo "Output: $output"
        return 1
    fi
}

# Assert output contains string
assert_output_contains() {
    local expected="$1"
    if [[ ! "$output" =~ $expected ]]; then
        echo "Expected output to contain: $expected"
        echo "Actual output: $output"
        return 1
    fi
}

# Create mock command
create_mock() {
    local cmd_name="$1"
    local cmd_output="$2"
    local cmd_exit_code="${3:-0}"

    cat > "$TEST_TEMP_DIR/$cmd_name" <<EOF
#!/bin/bash
echo "$cmd_output"
exit $cmd_exit_code
EOF
    chmod +x "$TEST_TEMP_DIR/$cmd_name"
    export PATH="$TEST_TEMP_DIR:$PATH"
}
```

### 5. Advanced BATS Patterns

**Testing scripts with arguments:**
```bash
@test "script accepts command-line arguments" {
    run bash "$SCRIPT_DIR/example.sh" arg1 arg2

    [ "$status" -eq 0 ]
    [[ "$output" =~ "arg1" ]]
    [[ "$output" =~ "arg2" ]]
}
```

**Testing with mock commands:**
```bash
@test "script uses curl correctly" {
    # Create mock curl
    create_mock "curl" '{"status":"ok"}' 0

    run bash "$SCRIPT_DIR/api-client.sh"

    [ "$status" -eq 0 ]
    [[ "$output" =~ "ok" ]]
}
```

**Testing environment variables:**
```bash
@test "script respects LOG_LEVEL env var" {
    LOG_LEVEL=DEBUG run bash "$SCRIPT_DIR/example.sh"

    [[ "$output" =~ "[DEBUG]" ]]
}
```

**Testing piped input:**
```bash
@test "script reads from stdin" {
    run bash "$SCRIPT_DIR/processor.sh" <<< "test input"

    [ "$status" -eq 0 ]
    [[ "$output" =~ "test input" ]]
}
```

## CI/CD Integration

### 1. GitHub Actions Workflow

Create `.github/workflows/shell-quality.yml`:

```yaml
name: Shell Script Quality

on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]

jobs:
  shellcheck:
    name: ShellCheck Linting
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Run ShellCheck
        uses: ludeeus/action-shellcheck@master
        with:
          scandir: './scripts'
          severity: warning
          format: gcc
          additional_files: 'hooks tests'

  bats:
    name: BATS Testing
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Install BATS
        run: |
          sudo apt-get update
          sudo apt-get install -y bats

      - name: Run BATS tests
        run: bats tests/

  combined:
    name: Combined Quality Check
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Install tools
        run: |
          sudo apt-get update
          sudo apt-get install -y shellcheck bats

      - name: Run ShellCheck
        run: |
          echo "=== Running ShellCheck ==="
          find scripts hooks tests -name "*.sh" -exec shellcheck {} +

      - name: Run BATS tests
        run: |
          echo "=== Running BATS tests ==="
          bats tests/

      - name: Check script permissions
        run: |
          echo "=== Checking script permissions ==="
          find scripts hooks -name "*.sh" ! -perm -111 -exec echo "Not executable: {}" \; -exec false {} +
```

### 2. GitLab CI Configuration

Create `.gitlab-ci.yml`:

```yaml
stages:
  - lint
  - test

shellcheck:
  stage: lint
  image: koalaman/shellcheck-alpine:stable
  script:
    - shellcheck scripts/*.sh hooks/*.sh tests/*.sh
  only:
    - merge_requests
    - main

bats:
  stage: test
  image: ubuntu:latest
  before_script:
    - apt-get update
    - apt-get install -y bats
  script:
    - bats tests/
  only:
    - merge_requests
    - main
```

### 3. Pre-commit Hooks

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash
# Pre-commit hook for shell scripts

set -euo pipefail

echo "Running pre-commit checks for shell scripts..."

# Find all staged shell scripts
staged_scripts=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(sh|bash)$' || true)

if [[ -z "$staged_scripts" ]]; then
    echo "No shell scripts to check."
    exit 0
fi

# Run ShellCheck
echo "=== Running ShellCheck ==="
shellcheck_failed=0
for script in $staged_scripts; do
    if ! shellcheck "$script"; then
        shellcheck_failed=1
    fi
done

if [[ $shellcheck_failed -eq 1 ]]; then
    echo "ShellCheck found issues. Please fix them before committing."
    exit 1
fi

# Run BATS tests if they exist
if [[ -d "tests" ]]; then
    echo "=== Running BATS tests ==="
    if ! bats tests/; then
        echo "BATS tests failed. Please fix them before committing."
        exit 1
    fi
fi

echo "All checks passed!"
exit 0
```

Make it executable:
```bash
chmod +x .git/hooks/pre-commit
```

## Complete Testing Workflow

### Step 1: Write the Script

Create `scripts/example.sh`:

```bash
#!/bin/bash
set -euo pipefail

# Function: Process input
# Arguments:
#   $1 - input (string)
# Returns: 0 on success, 1 on failure
process_input() {
    local input="$1"

    [[ -z "$input" ]] && {
        echo "ERROR: Input is required" >&2
        return 1
    }

    echo "Processed: $input"
    return 0
}

# Main function
main() {
    if [[ $# -lt 1 ]]; then
        echo "Usage: $0 <input>" >&2
        exit 1
    fi

    process_input "$1"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

### Step 2: Lint with ShellCheck

```bash
# Run ShellCheck
shellcheck scripts/example.sh

# Fix any issues reported
```

### Step 3: Write BATS Tests

Create `tests/example.bats`:

```bash
#!/usr/bin/env bats

setup() {
    source "$BATS_TEST_DIRNAME/../scripts/example.sh"
}

@test "process_input succeeds with valid input" {
    run process_input "test"
    [ "$status" -eq 0 ]
    [ "$output" = "Processed: test" ]
}

@test "process_input fails with empty input" {
    run process_input ""
    [ "$status" -eq 1 ]
    [[ "$output" =~ "ERROR" ]]
}

@test "main function shows usage without args" {
    run main
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Usage:" ]]
}

@test "main function processes valid input" {
    run main "test"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Processed: test" ]]
}
```

### Step 4: Run Tests

```bash
# Run BATS tests
bats tests/example.bats

# Run all tests
bats tests/

# Run with verbose output
bats -t tests/
```

### Step 5: Check Coverage

For coverage analysis, use `kcov`:

```bash
# Install kcov
sudo apt-get install kcov

# Run tests with coverage
kcov coverage bats tests/

# View coverage report
open coverage/index.html
```

## Common Patterns for Claude Code Plugins

### 1. Testing Scripts That Use ${CLAUDE_PLUGIN_ROOT}

```bash
# In tests/search.bats
@test "search script uses CLAUDE_PLUGIN_ROOT" {
    export CLAUDE_PLUGIN_ROOT="$BATS_TEST_DIRNAME/.."

    run bash "$CLAUDE_PLUGIN_ROOT/scripts/search.sh" "query"

    [ "$status" -eq 0 ]
}
```

### 2. Testing Hooks

```bash
# In tests/hooks.bats
@test "pre-edit-search hook provides suggestions" {
    # Create mock input
    local hook_input='{"tool":"Edit","params":{"file_path":"test.txt"}}'

    # Run hook
    run bash "$BATS_TEST_DIRNAME/../hooks/pre-edit-search.sh" <<< "$hook_input"

    [ "$status" -eq 0 ]
    [[ "$output" =~ "suggestion" ]]
}
```

### 3. Testing Scripts with JSON Output

```bash
# In tests/analytics.bats
@test "analytics script returns valid JSON" {
    run bash "$SCRIPT_DIR/analytics.sh"

    [ "$status" -eq 0 ]

    # Validate JSON
    echo "$output" | jq empty
}
```

### 4. Testing Scripts with External Dependencies

```bash
# In tests/api-client.bats
@test "api client handles curl errors gracefully" {
    # Create failing mock curl
    create_mock "curl" "curl: (6) Could not resolve host" 6

    run bash "$SCRIPT_DIR/api-client.sh"

    [ "$status" -ne 0 ]
    [[ "$output" =~ "ERROR" ]]
}
```

## Troubleshooting

### ShellCheck Issues

**Issue: SC1090 warnings about sourcing files**
```bash
# Solution: Add shellcheck directive
# shellcheck source=scripts/common.sh
source "$SCRIPT_DIR/common.sh"
```

**Issue: False positives for variables**
```bash
# Solution: Use shellcheck directive or export variables
# shellcheck disable=SC2034
UNUSED_VAR="value"
```

### BATS Issues

**Issue: Tests pass individually but fail together**
```bash
# Solution: Ensure proper cleanup in teardown()
teardown() {
    # Reset environment
    unset MY_VAR
    rm -rf "$TEST_TEMP_DIR"
}
```

**Issue: Can't source script with main execution block**
```bash
# Solution: Guard main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

## Quick Reference

### ShellCheck Quick Commands

```bash
# Lint all scripts
find . -name "*.sh" -exec shellcheck {} +

# Lint with specific format
shellcheck -f json scripts/*.sh > shellcheck-report.json

# Lint ignoring specific warnings
shellcheck -e SC2086,SC2181 script.sh
```

### BATS Quick Commands

```bash
# Run all tests
bats tests/

# Run specific test file
bats tests/example.bats

# Run with TAP output
bats -t tests/

# Run with timing information
bats -T tests/

# Run and count tests
bats -c tests/
```

### Combined Quality Check Script

Create `scripts/check-quality.sh`:

```bash
#!/bin/bash
set -euo pipefail

echo "=== Shell Script Quality Check ==="

# Run ShellCheck
echo ""
echo "Running ShellCheck..."
find scripts hooks tests -name "*.sh" -exec shellcheck {} +
echo "✓ ShellCheck passed"

# Run BATS tests
echo ""
echo "Running BATS tests..."
bats tests/
echo "✓ BATS tests passed"

# Check executable permissions
echo ""
echo "Checking script permissions..."
find scripts hooks -name "*.sh" ! -perm -111 -exec echo "WARNING: Not executable: {}" \;
echo "✓ Permission check complete"

echo ""
echo "=== All quality checks passed! ==="
```

## Next Steps

After setting up linting and testing:

1. Run checks locally before committing
2. Integrate into CI/CD pipeline
3. Set up pre-commit hooks
4. Document testing patterns in TESTING.md
5. Track test coverage over time
6. Add more tests as scripts evolve
7. Review and update .shellcheckrc as needed
8. Keep BATS tests maintainable and focused

## Resources

- **ShellCheck**: https://www.shellcheck.net/
- **ShellCheck GitHub**: https://github.com/koalaman/shellcheck
- **BATS**: https://github.com/bats-core/bats-core
- **BATS Tutorial**: https://bats-core.readthedocs.io/
- **Google Shell Style Guide**: https://google.github.io/styleguide/shellguide.html
- **Bash Best Practices**: https://bertvv.github.io/cheat-sheets/Bash.html
