---
name: search
description: Perform a web search using multiple search engines with caching and validation
usage: /search [query]
examples:
  - /search latest developments in AI
  - /search how to fix javascript null reference error
  - /search benefits of renewable energy
---

# /search Command

The `/search` command performs web searches using multiple search engines and provides relevant results with caching for efficiency.

## Parameters
- `query`: The search query string (required)

## Features
- Multi-engine search (Google, Bing, DuckDuckGo)
- Context isolation to preserve conversation flow
- Smart caching with 1-hour TTL
- Relevance scoring of results
- Source attribution
- Dynamic content extraction from results
- False positive validation

## Response Format
The command returns:
1. Top 5 relevant search results
2. Brief snippet for each result
3. Source URL
4. Relevance score (1-10)
5. Cache status indicator

## Error Handling
- Graceful fallback between search engines
- Exponential backoff on failures
- Clear error messages when searches fail
- Automatic retry logic

## Performance Notes
- Results cached for 1 hour
- MD5 keying for efficient lookup
- Cache hits return significantly faster
- Analytics collected for usage patterns