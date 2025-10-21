# Tests for Gemini Search Plugin

## Test Structure

```
~/claude-plugins/gemini-search/tests/
├── test_search.md              # Test search functionality
├── test_cache.md               # Test caching system
├── test_analytics.md           # Test analytics tracking
├── test_hooks.md               # Test hook functionality
└── integration_tests.md        # Integration tests
```

## Test Scenarios

### Search Functionality Tests

- Verify search returns results for valid queries
- Test error handling for invalid queries
- Check results formatting
- Validate multi-engine search capability

### Cache System Tests

- Test cache hit/miss logic
- Validate TTL expiration
- Verify MD5 keying works correctly
- Check cache size limits

### Analytics Tests

- Verify analytics tracking works
- Test statistics aggregation
- Check report generation
- Validate data persistence

### Hook Tests

- Test pre-edit hook suggestions
- Verify error detection hook
- Check hook integration with commands
- Validate hook configuration

## Running Tests

Tests can be executed using the plugin's test framework.
