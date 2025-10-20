# Search Result Validation

The Gemini Search Plugin includes comprehensive validation to ensure search results are relevant, accurate, and accessible.

## Validation Layers

### 1. False Positive Detection

**Purpose**: Filter out irrelevant search results

**How it works**:
- Calculates relevance score by matching query terms against result title, snippet, and URL
- Minimum relevance threshold: 50%
- Returns results with relevance scores

**Example**:
```bash
Query: "Claude Code plugins"
Result: "Plugin Development Guide - Claude Code Documentation"
Relevance: 100% (all terms matched)
Status: VALID
```

### 2. Static Link Validation

**Purpose**: Verify URLs exist and are accessible

**How it works**:
- Sends HTTP HEAD request to check URL accessibility
- Validates HTTP status codes (200-399 = valid)
- Supports redirects (max 5 by default)
- Times out after 10 seconds
- Falls back gracefully if no HTTP client available

**Tools used** (in order of preference):
1. `curl` (primary)
2. `wget` (fallback)
3. Skip validation (if neither available)

**Example**:
```bash
URL: https://docs.claude.com/plugins
Status: HTTP 200
Result: accessible ✓
```

### 3. URL Format Validation

**Purpose**: Ensure URLs have valid structure

**Checks**:
- Protocol: Must be `http://` or `https://`
- Domain: Valid domain name format
- Path: Optional, any valid path

**Examples**:
```bash
✓ https://docs.claude.com/plugins
✓ http://example.org/page
✗ not-a-url
✗ ftp://example.com
```

### 4. Domain Blacklist

**Purpose**: Filter out test and invalid domains

**Blacklisted domains**:
- `example.com`
- `test.com`
- `invalid.com`
- `localhost`
- `127.0.0.1`
- `0.0.0.0`
- `::1`
- `*.local`

**Example**:
```bash
URL: https://example.com/test
Status: INVALID (blacklisted domain)
```

## Configuration

### Enable/Disable Validation

```bash
# Enable static link validation (default)
export ENABLE_LINK_VALIDATION=true

# Disable static link validation (faster, less accurate)
export ENABLE_LINK_VALIDATION=false
```

### Timeout Configuration

```bash
# HTTP request timeout in seconds (default: 10)
export TIMEOUT_SECONDS=10

# Maximum HTTP redirects to follow (default: 5)
export MAX_REDIRECTS=5
```

### Relevance Threshold

Currently hardcoded to 50%. To modify, edit `scripts/search-wrapper.sh`:

```bash
# Line 175
if [[ $relevance_percentage -ge 50 ]] && [[ "$is_valid" == "true" ]]; then
```

## Validation Output Format

Results include validation metadata:

```
VALID|85|accessible
```

Format: `STATUS|RELEVANCE_SCORE|URL_STATUS`

- **STATUS**: `VALID` or `INVALID`
- **RELEVANCE_SCORE**: 0-100 percentage
- **URL_STATUS**: `accessible`, `inaccessible`, or `unknown`

## Performance Considerations

### With Link Validation Enabled

**Pros**:
- ✅ Filters out broken links
- ✅ Higher quality results
- ✅ Better user experience

**Cons**:
- ⏱️ Slower (adds ~1-2s per result)
- 🌐 Requires network access
- 💾 Not cached

**Best for**: Production use, critical searches

### With Link Validation Disabled

**Pros**:
- ⚡ Faster results
- 📡 Works offline
- 💨 Lower latency

**Cons**:
- ❌ May return broken links
- ⚠️ Lower quality assurance

**Best for**: Development, testing, offline use

## Testing Validation

### Unit Tests

Run validation tests:

```bash
bash tests/test-link-validation.sh
```

### Manual Testing

Test individual validation functions:

```bash
# Source the validation script
source scripts/validate-links.sh

# Test URL format
validate_url_format "https://docs.claude.com/plugins"
echo $?  # 0 = valid, 1 = invalid

# Test URL exists
check_url_exists "https://docs.claude.com/plugins"
echo $?  # 0 = exists, 1 = doesn't exist

# Test blacklist
check_url_blacklist "https://example.com/test"
echo $?  # 0 = not blacklisted, 1 = blacklisted

# Calculate relevance
calculate_relevance_score "claude plugins" "Claude Plugin Guide" "Guide to plugins" "https://claude.com/plugins"
# Returns: 100
```

### Full Validation Test

```bash
bash scripts/validate-links.sh \
  "claude code plugins" \
  "Plugin Development Guide" \
  "https://docs.claude.com/plugins" \
  "Comprehensive guide to developing plugins for Claude Code"
```

Output:
```json
{
  "valid": true,
  "url": "https://docs.claude.com/plugins",
  "url_status": "accessible",
  "relevance_score": 100,
  "relevance_threshold": 50,
  "failure_reasons": []
}
```

## Debugging Validation Issues

### Enable Debug Logging

```bash
export LOG_FILE="/tmp/gemini-search-debug.log"

# Run search
/search "your query"

# View logs
tail -f /tmp/gemini-search-debug.log | grep "Validating\|accessible"
```

### Common Issues

#### Issue: All results marked INVALID

**Cause**: Link validation timing out

**Solution**:
```bash
# Increase timeout
export TIMEOUT_SECONDS=30

# Or disable link validation
export ENABLE_LINK_VALIDATION=false
```

#### Issue: Validation too slow

**Cause**: HTTP requests taking too long

**Solution**:
```bash
# Reduce timeout
export TIMEOUT_SECONDS=5

# Reduce max redirects
export MAX_REDIRECTS=2
```

#### Issue: "No HTTP client available"

**Cause**: Neither curl nor wget installed

**Solution**:
```bash
# Install curl (Ubuntu/Debian)
sudo apt-get install curl

# Install curl (macOS)
brew install curl

# Install curl (Windows/Chocolatey)
choco install curl
```

## Validation Statistics

View validation performance:

```bash
/search-stats
```

Shows:
- Total searches
- Cache hit rate
- Average relevance scores (future feature)
- URL accessibility rate (future feature)

## Future Enhancements

Planned validation improvements:

- [ ] SSL certificate validation
- [ ] Content-type checking (HTML only)
- [ ] Duplicate URL detection
- [ ] Custom blacklist configuration
- [ ] Whitelist support
- [ ] Validation result caching
- [ ] Async validation (parallel checks)
- [ ] Configurable relevance thresholds
- [ ] Machine learning relevance scoring

## Best Practices

### For Users

1. **Enable link validation in production**
   - Ensures high-quality results
   - Prevents dead links

2. **Disable link validation for development**
   - Faster iteration
   - Works offline

3. **Monitor validation logs**
   - Identify patterns
   - Tune thresholds

### For Developers

1. **Test with validation enabled and disabled**
   - Ensure both modes work
   - Handle graceful degradation

2. **Add validation tests**
   - Test new validation rules
   - Prevent regressions

3. **Document validation behavior**
   - Update VALIDATION.md
   - Add examples

## Related Documentation

- [README.md](../README.md) - Overview and features
- [TESTING.md](../TESTING.md) - Testing guide
- [DEPLOYMENT.md](../DEPLOYMENT.md) - Deployment procedures
- [scripts/validate-links.sh](../scripts/validate-links.sh) - Validation implementation
