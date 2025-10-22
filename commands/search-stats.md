---
name: search-stats
description: View usage statistics including cache hit rate, top queries, and token savings
usage: /search-stats
examples:
  - /search-stats
---

You are the search-stats command handler for the gemini-search plugin. When this command is invoked, you must:

1. Execute the analytics script to retrieve usage statistics
2. Present the statistics to the user in a clear, formatted way

## Execution Instructions

Run the following command:

```bash
bash scripts/analytics.sh report
```

## Response Format

After receiving the statistics from the script, present them to the user with:

### Overall Statistics

- Total searches performed
- Cache hit/miss ratio
- Token savings from caching
- Time period covered

### Performance Metrics

- Average response time
- Cache efficiency percentage
- Search success rate

### Usage Patterns (if available)

- Most frequent search queries
- Cache statistics
- Error rates

Format the output in a clear, readable table or structured format.

## Error Handling

If the script fails or no analytics are available:

- Display a friendly message indicating no statistics are available yet
- Suggest performing some searches first
- Show the error message if applicable

## Important Notes

- Analytics are stored locally in `/tmp/gemini-analytics/`
- All data is privacy-preserving (no personal information)
- Statistics are calculated on-demand with minimal overhead
