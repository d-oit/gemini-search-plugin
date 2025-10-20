---
name: search-stats
description: View usage statistics including cache hit rate, top queries, and token savings
usage: /search-stats
examples:
  - /search-stats
---

# /search-stats Command

The `/search-stats` command provides analytics and usage statistics for the Gemini Search plugin.

## Features
- Total searches performed
- Cache hit rate percentage
- Average response time
- Top search queries
- Most used search engines
- Token savings from context isolation

## Metrics Tracked
- `total_searches`: Number of searches conducted
- `cache_hits`: Number of results served from cache
- `cache_misses`: Number of fresh searches required
- `cache_hit_rate`: Percentage of cached results
- `avg_response_time_ms`: Average response time in milliseconds
- `top_queries`: Most common search queries
- `engine_usage`: Distribution across search engines
- `estimated_token_savings`: Estimated token savings from caching

## Response Format
The command returns:
1. Summary statistics
2. Cache performance metrics
3. Popular search queries
4. Search engine usage breakdown
5. Estimated token savings percentage

## Performance Insights
- Shows cache effectiveness
- Identifies popular topics
- Helps optimize search engine usage
- Tracks plugin adoption

## Privacy Notice
- All statistics are collected locally
- No personal search queries are stored
- Only aggregate metrics are maintained
- Data is reset with cache clearing