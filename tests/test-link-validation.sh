#!/bin/bash
set -euo pipefail

# Test script for link validation functionality

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Source the validation script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../scripts" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/validate-links.sh"

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="$3"

    TESTS_RUN=$((TESTS_RUN + 1))
    echo -e "${YELLOW}Running:${NC} $test_name"

    local result
    if eval "$test_command"; then
        result="pass"
    else
        result="fail"
    fi

    if [[ "$result" == "$expected_result" ]]; then
        echo -e "${GREEN}✓ PASSED${NC}: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}: $test_name (expected: $expected_result, got: $result)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

echo "========================================"
echo "Link Validation - Unit Tests"
echo "========================================"
echo ""

# Test 1: Valid URL format
run_test "Valid URL format (https)" \
    "validate_url_format 'https://docs.claude.com/plugins'" \
    "pass"

# Test 2: Invalid URL format
run_test "Invalid URL format" \
    "validate_url_format 'not-a-url'" \
    "fail"

# Test 3: Blacklisted domain
run_test "Blacklisted domain (example.com)" \
    "! check_url_blacklist 'https://example.com/test'" \
    "pass"

# Test 4: Non-blacklisted domain
run_test "Non-blacklisted domain" \
    "check_url_blacklist 'https://docs.claude.com/plugins'" \
    "pass"

# Test 5: Relevance calculation - perfect match
run_test "Relevance calculation - perfect match" \
    "[[ \$(calculate_relevance_score 'claude code' 'Claude Code Guide' 'Guide to Claude Code plugins' 'https://docs.claude.com/code') -ge 80 ]]" \
    "pass"

# Test 6: Relevance calculation - no match
run_test "Relevance calculation - no match" \
    "[[ \$(calculate_relevance_score 'python tutorial' 'JavaScript Guide' 'Learn JavaScript' 'https://js.example.com') -lt 20 ]]" \
    "pass"

# Test 7: URL exists check (should work for major sites)
if command -v curl >/dev/null 2>&1 || command -v wget >/dev/null 2>&1; then
    run_test "URL exists - valid URL" \
        "check_url_exists 'https://www.google.com'" \
        "pass"

    run_test "URL exists - invalid URL" \
        "! check_url_exists 'https://this-domain-definitely-does-not-exist-12345.com'" \
        "pass"
else
    echo -e "${YELLOW}⚠ SKIPPED${NC}: URL existence tests (no HTTP client available)"
fi

# Test 8: Full validation - valid result
run_test "Full validation - valid result" \
    "validate_search_result 'claude code plugins' 'Plugin Guide' 'https://docs.claude.com/plugins' 'Guide to creating plugins' | grep -q '\"valid\": true'" \
    "pass"

# Test 9: Full validation - blacklisted domain
run_test "Full validation - blacklisted domain" \
    "validate_search_result 'test query' 'Test Page' 'https://example.com/test' 'Test content' | grep -q '\"valid\": false'" \
    "pass"

# Test 10: Full validation - low relevance
run_test "Full validation - low relevance" \
    "validate_search_result 'python tutorial' 'JavaScript Guide' 'https://js.example.org' 'Learn JavaScript basics' | grep -q '\"valid\": false'" \
    "pass"

# Summary
echo ""
echo "========================================"
echo "Test Summary"
echo "========================================"
echo "Tests Run:    $TESTS_RUN"
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo "========================================"

# Exit with failure if any tests failed
if [ $TESTS_FAILED -gt 0 ]; then
    exit 1
fi
