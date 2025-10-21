# Gemini Search Plugin - Examples

This directory contains example queries and their outputs to demonstrate the plugin's capabilities.

## Example Categories

### 1. **Basic Searches** (`01-basic-searches.md`)

Simple search queries and their results.

### 2. **Technical Queries** (`02-technical-queries.md`)

Programming and technical topic searches.

### 3. **Validation Examples** (`03-validation-examples.md`)

Examples of result validation and false positive filtering.

### 4. **Advanced Usage** (`04-advanced-usage.md`)

Complex queries and multi-step workflows.

## How to Use These Examples

1. **Try the commands** in your Claude Code environment
2. **Compare outputs** with the examples shown
3. **Modify queries** to explore different use cases
4. **Use as templates** for your own searches

## Running Examples

All examples can be executed using the `/search` command in Claude Code:

```
/search [your query]
```

Or directly via the command line:

```bash
bash scripts/search-wrapper.sh search "your query"
```

## Performance Notes

- First search for a query: ~5-15 seconds (calls Gemini API)
- Cached searches: <1 second (served from cache)
- Cache TTL: 1 hour (configurable)
- Validation adds: ~2-5 seconds for link checks

## Example Output Format

All search results include:

- **Query**: The original search query
- **Cache Status**: HIT or MISS
- **Response**: Formatted search results
- **Sources**: Referenced URLs
- **Statistics**: Token usage and performance metrics
