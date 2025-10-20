# Local Testing Guide

This guide explains how to test the Gemini Search Plugin locally before publishing.

## Prerequisites

1. **Claude Code** installed and running
2. **Gemini CLI** installed and authenticated:
   ```bash
   npm install -g @google/genai-cli
   gemini auth login
   ```
3. **jq** installed for JSON processing

## Local Testing Methods

### Method 1: Test Marketplace (Recommended)

This method allows you to test the plugin as if it were installed from a marketplace.

#### Step 1: Add Test Marketplace

Edit your global Claude Code settings at `~/.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "gemini-search-test": {
      "source": {
        "source": "directory",
        "path": "/absolute/path/to/gemini-search-plugin"
      }
    }
  }
}
```

Replace `/absolute/path/to/gemini-search-plugin` with the actual path to this repository.

**Windows Example:**
```json
"path": "D:/git/claude-code/claude-plugins/gemini-search"
```

**macOS/Linux Example:**
```json
"path": "/Users/username/dev/gemini-search-plugin"
```

#### Step 2: Restart Claude Code

Restart Claude Code to load the test marketplace.

#### Step 3: Install Plugin

In Claude Code, run:
```bash
/plugin add gemini-search@gemini-search-test
```

#### Step 4: Test Commands

Test all plugin commands:
```bash
/search "Claude Code plugin development"
/search-stats
/clear-cache
```

#### Step 5: Remove Test Installation

When done testing:
```bash
/plugin remove gemini-search
```

Then remove the marketplace from `~/.claude/settings.json`.

### Method 2: Direct Repository Testing

Test the plugin directly in a repository that includes it.

#### Step 1: Add Repository Settings

Create `.claude/settings.json` in your test project:

```json
{
  "extraKnownMarketplaces": {
    "local-test": {
      "source": {
        "source": "directory",
        "path": "/path/to/gemini-search-plugin"
      }
    }
  },
  "plugins": [
    {
      "name": "gemini-search",
      "source": "local-test"
    }
  ]
}
```

#### Step 2: Trust the Repository

When you open the folder in Claude Code, you'll be prompted to trust it. Accept the trust prompt.

#### Step 3: Plugin Auto-installs

The plugin will automatically install when you trust the folder.

## Testing Checklist

### Functionality Tests

- [ ] `/search` command works with basic query
- [ ] Search results are relevant and properly formatted
- [ ] Cache functionality works (run same query twice)
- [ ] `/search-stats` shows analytics
- [ ] `/clear-cache` clears cache successfully
- [ ] Error hook triggers on errors (test with invalid input)
- [ ] Pre-edit hook provides suggestions (test by editing files)

### Integration Tests

Run the automated test suite:

```bash
# From plugin directory
bash tests/run-integration-tests.sh
```

Expected output:
```
========================================
Gemini Search Plugin - Integration Tests
========================================

Running: JSON Validation
✓ PASSED: JSON Validation
Running: Script Permissions
✓ PASSED: Script Permissions
...
========================================
Test Summary
========================================
Tests Run:    10
Tests Passed: 10
Tests Failed: 0
```

### Manual Testing Scenarios

#### Test 1: Basic Search
```bash
/search "What is semantic versioning"
```
Expected: Returns search results with relevant content.

#### Test 2: Cache Hit
```bash
/search "What is semantic versioning"
# Run again immediately
/search "What is semantic versioning"
```
Expected: Second query should be faster (cache hit).

#### Test 3: Analytics
```bash
/search-stats
```
Expected: Shows statistics including cache hit rate.

#### Test 4: Cache Clear
```bash
/clear-cache
/search-stats
```
Expected: Cache statistics reset to zero.

#### Test 5: Error Handling
Trigger an error in your code and observe if the error hook suggests searches.

### Performance Tests

#### Cache Performance
```bash
# First run (cache miss)
time /search "Claude Code plugins"

# Second run (cache hit)
time /search "Claude Code plugins"
```
Expected: Second run should be significantly faster.

#### Token Savings
Check `/search-stats` after multiple cached queries to see estimated token savings.

## Debugging

### Enable Verbose Logging

Set environment variables before starting Claude Code:

```bash
export LOG_FILE="/tmp/gemini-search-debug.log"
export ERROR_LOG_FILE="/tmp/gemini-search-errors-debug.log"
```

### View Logs

```bash
# Main log
tail -f /tmp/gemini-search.log

# Error log
tail -f /tmp/gemini-search-errors.log

# Analytics log
tail -f /tmp/gemini-analytics/search-analytics.log
```

### Check Cache

```bash
# View cache directory
ls -lh /tmp/gemini-search-cache/

# View cache entry
cat /tmp/gemini-search-cache/[hash].json | jq .
```

## Common Issues

### Issue: Plugin Not Found

**Problem**: `/plugin add` says plugin not found.

**Solution**:
1. Verify path in settings.json is absolute
2. Restart Claude Code
3. Check that `.claude-plugin/plugin.json` exists

### Issue: Commands Not Working

**Problem**: Slash commands don't appear or don't work.

**Solution**:
1. Verify `commands/` directory has `.md` files
2. Check file permissions (should be readable)
3. Restart Claude Code

### Issue: Hooks Not Triggering

**Problem**: Hooks don't fire on errors or edits.

**Solution**:
1. Verify `hooks/hooks.json` is valid JSON
2. Check script permissions (should be executable)
3. Review hook trigger patterns in hooks.json

### Issue: Gemini CLI Errors

**Problem**: "gemini command not found" or authentication errors.

**Solution**:
```bash
# Install Gemini CLI
npm install -g @google/genai-cli

# Authenticate
gemini auth login

# Test it works
gemini -p "test" --yolo
```

## Testing Different Scenarios

### Test on Different Platforms

- [ ] Windows
- [ ] macOS
- [ ] Linux

### Test with Different Shells

- [ ] bash
- [ ] zsh
- [ ] PowerShell (Windows)

### Test Edge Cases

- [ ] Empty search query
- [ ] Very long search query (>1000 chars)
- [ ] Special characters in query
- [ ] Network disconnection during search
- [ ] Gemini CLI unavailable

## Clean Up After Testing

1. Remove plugin:
   ```bash
   /plugin remove gemini-search
   ```

2. Remove test marketplace from `~/.claude/settings.json`

3. Clear cache and logs:
   ```bash
   rm -rf /tmp/gemini-search-cache
   rm -rf /tmp/gemini-analytics
   rm -f /tmp/gemini-search*.log
   ```

## Preparing for Production

After successful local testing:

1. ✅ All integration tests pass
2. ✅ All manual tests pass
3. ✅ Tested on target platforms
4. ✅ Documentation updated
5. ✅ CHANGES.md updated with new features
6. ✅ Version bumped appropriately

Then proceed with release:
```bash
bash scripts/prepare-release.sh 0.2.0
```

## Resources

- [Claude Code Plugins Documentation](https://docs.claude.com/en/docs/claude-code/plugins)
- [Plugin Marketplaces Guide](https://docs.claude.com/en/docs/claude-code/plugin-marketplaces)
- [Plugins Reference](https://docs.claude.com/en/docs/claude-code/plugins-reference)
