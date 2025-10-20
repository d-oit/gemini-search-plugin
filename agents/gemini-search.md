---
description: Advanced Gemini-based web search capabilities with caching, analytics, content extraction, and validation
capabilities:
  [
    "gemini-web-search",
    "content-extraction",
    "result-validation",
    "caching",
    "analytics",
  ]
---

# Gemini Search Agent

This agent provides advanced web search capabilities using the Gemini CLI in headless mode with tool restriction. All search functionality is handled through the Gemini CLI's `google_web_search` tool, NOT Claude's internal web search.

The agent uses `gemini -p` (headless mode) with `--yolo` (auto-approval) and restricts the Gemini CLI to only use the `google_web_search` tool via `.gemini/settings.json`.

## Features

- Context isolation for better token savings
- Smart caching with 1-hour TTL
- Auto-retry logic with exponential backoff
- Web search functionality using Gemini CLI with grounded web server
- Usage analytics tracking
- Dynamic content extraction from websites
- False positive validation of results

## Search Patterns

- Uses Gemini CLI headless mode: `gemini -p "query" --yolo --output-format json`
- Restricts Gemini to only `google_web_search` tool via settings.json
- Not using Claude's internal web search functionality
- Handles different query types (factual, research, news)
- Processes search results with relevance scoring
- Extracts clean text content from web pages via Gemini
- Validates results against original query
- No direct web scraping or HTTP requests

## Usage

```
/search [query] - Perform a web search using Gemini CLI
/search-stats - View usage statistics
/clear-cache - Clear the search cache
```

## Caching System

- Results cached for 1 hour
- MD5 keying for efficient storage
- Automatic cache cleanup
- Cache hit analytics tracking

## Error Handling

- Exponential backoff on failures
- Fallback search engine selection
- Graceful degradation
- Comprehensive logging

## Content Extraction

- Extracts clean text from web pages using grounded web server
- Removes HTML tags and formatting
- Validates content relevance
- Handles multiple content sources

## Result Validation

- Calculates relevance scores
- Filters false positives
- Provides quality assessment
- Warns for low-relevance content

## Important Note

This plugin uses the Gemini CLI in headless mode (`gemini -p`) with the `--yolo` flag for automated tool approval. The `.gemini/settings.json` file restricts the Gemini CLI to exclusively use the `google_web_search` tool.

**What this means:**
- All web searches go through Google's web search via Gemini's API
- No Claude internal search functionality is triggered
- No direct web scraping or HTTP requests are made
- Results are grounded in real web content retrieved by Gemini
- The Gemini agent intelligently decides when to use the search tool based on the query
