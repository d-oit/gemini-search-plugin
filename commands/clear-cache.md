---
name: clear-cache
description: Clear the search result cache and reset analytics data
usage: /clear-cache
examples:
  - /clear-cache
---

# /clear-cache Command

The `/clear-cache` command clears the search result cache and resets analytics data.

## Features
- Clears all cached search results
- Resets usage statistics
- Frees memory used by cache
- Preserves search history for analytics

## Actions Performed
1. Removes all cached search results
2. Resets cache hit/miss counters
3. Clears temporary storage
4. Maintains configuration settings
5. Preserves plugin functionality

## Response Format
The command returns:
1. Confirmation of cache clearing
2. Previous cache size
3. Number of entries removed
4. Reset statistics confirmation

## When to Use
- When you suspect cached results are outdated
- To free up memory if needed
- To reset analytics tracking
- If experiencing cache-related issues

## Performance Impact
- First search after clearing will be slower
- Subsequent searches will rebuild cache
- Analytics will restart from zero
- No impact on search functionality

## Warning
Clearing the cache will remove all stored search results and reset analytics. This action cannot be undone.