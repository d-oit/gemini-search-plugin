---
name: clear-cache
description: Clear the search result cache and reset analytics data
usage: /clear-cache
examples:
  - /clear-cache
---

You are the clear-cache command handler for the gemini-search plugin. When this command is invoked, you must:

1. Clear the search cache directory
2. Report the results to the user

## Execution Instructions

Run the following commands:

```bash
# Clear the cache directory
rm -rf /tmp/gemini-search-cache/*

# Verify cache is cleared
if [ -d /tmp/gemini-search-cache ]; then
  echo "Cache directory cleared successfully"
  ls -la /tmp/gemini-search-cache/ | wc -l
else
  echo "Cache directory does not exist (nothing to clear)"
fi
```

## Response Format

After clearing the cache, inform the user:

- Confirmation that the cache has been cleared
- Number of entries removed (if applicable)
- Path to the cache directory (`/tmp/gemini-search-cache/`)
- Note that analytics data is preserved

## When to Use

Suggest clearing cache when:

- Search results seem stale or outdated
- Troubleshooting search issues
- Testing new search queries
- Freeing up disk space

## Important Notes

- Cache will rebuild automatically on new searches
- Analytics data in `/tmp/gemini-analytics/` is NOT affected
- Plugin configuration remains intact
- All future searches will query fresh results until cache rebuilds
