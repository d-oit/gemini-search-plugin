#!/bin/bash
set -euo pipefail

# Integration test suite for Gemini Search Plugin
# Usage: bash tests/run-integration-tests.sh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test results log
TEST_LOG="/tmp/gemini-test-results.log"
echo "Test Run: $(date)" > "$TEST_LOG"

# Function to log test results
log_test() {
    local test_name="$1"
    local status="$2"
    local message="$3"

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$status] $test_name: $message" >> "$TEST_LOG"
}

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"

    TESTS_RUN=$((TESTS_RUN + 1))
    echo -e "${YELLOW}Running:${NC} $test_name"

    if eval "$test_command" >> "$TEST_LOG" 2>&1; then
        echo -e "${GREEN}✓ PASSED${NC}: $test_name"
        log_test "$test_name" "PASS" "Test passed"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}: $test_name"
        log_test "$test_name" "FAIL" "Test failed"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Function to setup test environment
setup_test_env() {
    echo "Setting up test environment..."

    export CACHE_DIR="/tmp/gemini-test-cache"
    export ANALYTICS_DIR="/tmp/gemini-test-analytics"
    export LOG_FILE="/tmp/gemini-test.log"
    export ERROR_LOG_FILE="/tmp/gemini-test-errors.log"

    mkdir -p "$CACHE_DIR"
    mkdir -p "$ANALYTICS_DIR"

    # Create log files
    touch "$LOG_FILE"
    touch "$ERROR_LOG_FILE"

    echo "Test environment ready"
}

# Function to cleanup test environment
cleanup_test_env() {
    echo "Cleaning up test environment..."
    rm -rf /tmp/gemini-test-cache
    rm -rf /tmp/gemini-test-analytics
    rm -f /tmp/gemini-test.log
    rm -f /tmp/gemini-test-errors.log
}

# Test 1: Validate JSON files
test_json_validation() {
    jq empty .claude-plugin/plugin.json && \
    jq empty .claude-plugin/marketplace.json && \
    jq empty hooks/hooks.json
}

# Test 2: Check script executability
test_script_permissions() {
    [ -x scripts/search-wrapper.sh ] && \
    [ -x scripts/analytics.sh ] && \
    [ -x scripts/extract-content.sh ] && \
    [ -x hooks/error-search.sh ] && \
    [ -x hooks/pre-edit-search.sh ]
}

# Test 3: Analytics initialization
test_analytics_init() {
    bash scripts/analytics.sh init
    [ -f "$ANALYTICS_DIR/search-aggregates.json" ]
}

# Test 4: Analytics tracking
test_analytics_tracking() {
    bash scripts/analytics.sh track-search "test" "test query" "google" "100"
    total=$(jq -r '.total_searches' "$ANALYTICS_DIR/search-aggregates.json")
    [ "$total" -eq 1 ]
}

# Test 5: Cache operations
test_cache_operations() {
    local test_query="test cache query"
    local test_result="test cache result"
    local cache_key
    cache_key=$(echo "$test_query" | md5sum | cut -d' ' -f1)
    local cache_file="$CACHE_DIR/${cache_key}.json"

    # Create cache entry
    echo "$test_result" > "$cache_file"

    # Verify cache file exists
    [ -f "$cache_file" ]
}

# Test 6: Cache stats
test_cache_stats() {
    local output
    output=$(bash scripts/search-wrapper.sh stats 2>&1)
    echo "$output" | grep -q "Cache Statistics"
}

# Test 7: Error log creation
test_error_logging() {
    bash scripts/search-wrapper.sh search "" 2>&1 || true
    [ -f "$ERROR_LOG_FILE" ]
}

# Test 8: Analytics report generation
test_analytics_report() {
    local output
    output=$(bash scripts/analytics.sh report 2>&1)
    echo "$output" | grep -q "Search Analytics Report"
}

# Test 9: Cache clear functionality
test_cache_clear() {
    bash scripts/search-wrapper.sh clear-cache
    # Check if cache directory is empty
    [ -z "$(ls -A "$CACHE_DIR" 2>/dev/null)" ]
}

# Test 10: Validate environment variables
test_env_vars() {
    [ -n "$CACHE_DIR" ] && \
    [ -n "$ANALYTICS_DIR" ] && \
    [ -n "$LOG_FILE" ]
}

# Main test execution
main() {
    echo "========================================"
    echo "Gemini Search Plugin - Integration Tests"
    echo "========================================"
    echo ""

    # Setup
    setup_test_env

    # Run tests
    run_test "JSON Validation" "test_json_validation"
    run_test "Script Permissions" "test_script_permissions"
    run_test "Analytics Initialization" "test_analytics_init"
    run_test "Analytics Tracking" "test_analytics_tracking"
    run_test "Cache Operations" "test_cache_operations"
    run_test "Cache Statistics" "test_cache_stats"
    run_test "Error Logging" "test_error_logging"
    run_test "Analytics Report" "test_analytics_report"
    run_test "Cache Clear" "test_cache_clear"
    run_test "Environment Variables" "test_env_vars"

    # Cleanup
    cleanup_test_env

    # Summary
    echo ""
    echo "========================================"
    echo "Test Summary"
    echo "========================================"
    echo "Tests Run:    $TESTS_RUN"
    echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
    echo ""
    echo "Detailed log: $TEST_LOG"
    echo "========================================"

    # Exit with failure if any tests failed
    if [ $TESTS_FAILED -gt 0 ]; then
        exit 1
    fi
}

# Run main
main "$@"
