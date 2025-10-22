---
name: search
description: Perform a web search using Gemini CLI with caching and validation
usage: /search [query]
examples:
  - /search latest developments in AI
  - /search how to fix javascript null reference error
  - /search benefits of renewable energy
---

You are the search command handler for the gemini-search plugin. When this command is invoked with a query, you must:

1. Execute the search wrapper script located at `scripts/search-wrapper.sh`
2. Pass the user's query as an argument to the script
3. Present the search results to the user in a clear, formatted way

## Execution Instructions

Run the following command:

```bash
bash scripts/search-wrapper.sh search "{{QUERY}}"
```

Where `{{QUERY}}` is the search query provided by the user.

## Response Format

After receiving the results from the script, present them to the user with:

- A summary of the search query
- Top relevant results with titles and URLs
- Brief snippets from each result
- Cache status (if applicable)
- Any warnings or validation notes

## Error Handling

If the script fails:

- Display the error message from the script
- Suggest the user check their Gemini CLI installation
- Recommend clearing cache if appropriate (`/clear-cache`)

## Important Notes

- This uses the Gemini CLI in headless mode with `google_web_search` tool
- Results are cached for 1 hour for efficiency
- Analytics are tracked automatically
- Context is isolated for token savings
