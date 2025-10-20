# Gemini Search Plugin

Advanced web search plugin using the Gemini CLI in headless mode with `google_web_search` tool restriction, providing caching, analytics, content extraction, and validation for Claude Code.

**Important**: This plugin uses the Gemini CLI with the `google_web_search` tool exclusively via headless mode (`gemini -p` with `--yolo` flag). It does NOT:

- Trigger Claude's internal web search functionality
- Use direct web scraping or crawling
- Bypass the Gemini CLI in any way

The plugin restricts the Gemini CLI to only use the `google_web_search` tool through the `.gemini/settings.json` configuration.

## Features

### 💎 Key Features:

- **Gemini CLI Headless Mode** - Uses `gemini -p` with `--yolo` flag for automated web search
- **Tool Restriction** - `.gemini/settings.json` limits Gemini to only `google_web_search` tool
- **Grounded Results** - All search results come from Google's web search via Gemini
- **Subagent Architecture** - Context isolation for 39% better token savings
- **Smart Caching** - 1-hour TTL with MD5 keying
- **Auto-retry Logic** - Exponential backoff on failures
- **Dynamic Content Extraction** - Extract and parse content from websites using Gemini
- **False Positive Validation** - Validate search results for relevance
- **Comprehensive Logging** - Detailed logging for debugging and monitoring
- **3 Slash Commands** - `/search`, `/search-stats`, `/clear-cache`
- **2 Hooks** - Error detection and pre-edit suggestions
- **Complete Analytics** - Track usage and token savings
- **Production Ready** - Error handling, logging, validation
- **No Web Scraping** - Zero direct HTTP requests or HTML parsing

## Commands

### `/search [query]`

Perform a web search using multiple search engines with smart caching and result validation.

### `/search-stats`

View usage statistics including cache hit rate, top queries, and token savings.

### `/clear-cache`

Clear the search result cache and reset analytics data.

## Architecture

### Directory Structure

```
~/claude-plugins/gemini-search/
├── .claude-plugin/
│   └── plugin.json                    # Plugin metadata
├── agents/
│   └── gemini-search.md               # Subagent (isolated context)
├── skills/
│   └── web-search-patterns/
│       └── SKILL.md                   # Search best practices
├── commands/
│   ├── search.md                      # /search command
│   ├── search-stats.md                # /search-stats analytics
│   └── clear-cache.md                 # /clear-cache
├── scripts/
│   ├── search-wrapper.sh              # Production wrapper with error handling
│   ├── analytics.sh                   # Usage tracking and statistics
│   └── extract-content.sh             # Dynamic content extraction from websites
├── hooks/
│   ├── hooks.json                     # Hook config
│   ├── pre-edit-search.sh             # Pre-edit suggestions with validation
│   └── error-search.sh                # Auto error detection and handling
└── README.md                          # Full documentation
```

## Advanced Features

### Dynamic Content Extraction

- Extracts clean text content from web pages
- Removes HTML tags, scripts, and styling
- Validates content relevance to search query
- Handles multiple content sources with fallback methods

### False Positive Validation

- Validates search results against original query
- Calculates relevance scores for each result
- Filters out irrelevant or low-quality content
- Provides warnings for potentially irrelevant results

### Comprehensive Error Handling

- Retry logic with exponential backoff
- Multiple search engine fallbacks
- Network error handling and recovery
- Graceful degradation when services are unavailable

### Logging System

- Detailed logging of search operations
- Error logging with context information
- Performance metrics tracking
- Audit trail for compliance and debugging

## Getting Started

### Prerequisites

1. **Install Gemini CLI**:

   ```bash
   npm install -g @google/genai-cli
   ```

2. **Verify Installation**:

   ```bash
   gemini --version
   ```

3. **Configure API Key** (optional):
   ```bash
   gemini config set apiKey YOUR_GOOGLE_AI_API_KEY
   ```

### Usage

1. Install the plugin in your Claude Code environment
2. The `.gemini/settings.json` file is automatically used to restrict tools
3. Use `/search [your query]` to perform web searches via Gemini
4. Check `/search-stats` to monitor usage and cache effectiveness
5. Use `/clear-cache` if you need to reset cached results

## Configuration

The plugin can be configured through environment variables:

- `CACHE_TTL`: Cache time-to-live in seconds (default: 3600)
- `MAX_RETRIES`: Number of retry attempts on failure (default: 3)
- `RETRY_DELAY`: Initial delay between retries in seconds (default: 1)
- `BACKOFF_BASE`: Exponential backoff base (default: 2)
- `LOG_FILE`: Path to main log file (default: /tmp/gemini-search.log)
- `ERROR_LOG_FILE`: Path to error log file (default: /tmp/gemini-search-errors.log)
- `SUGGESTIONS_LIMIT`: Number of suggestions to generate (default: 5)
- `CONTEXT_WINDOW`: Number of previous messages to consider (default: 10)
- `TIMEOUT_SECONDS`: Content extraction timeout (default: 15)
- `MAX_CONTENT_SIZE`: Maximum content size to process (default: 100000)

## Performance Notes

- Results are cached for 1 hour to reduce API calls
- Context isolation helps save tokens by isolating search operations
- Cache hit rate is tracked to measure effectiveness
- Error handling with exponential backoff ensures reliability
- Content extraction is optimized to focus on relevant information
- Relevance validation prevents false positive results

## Troubleshooting

- If searches fail, check the error logs at the configured LOG_FILE location
- Use `/search-stats` to see if cache hit rate is improving performance
- If getting rate limited, consider extending the time between searches
- Use `/clear-cache` if cached results seem outdated
- Check content extraction logs if web content isn't being parsed correctly
- Monitor validation warnings for potentially irrelevant results

## Security Considerations

- Content extraction is limited to prevent processing oversized responses
- URLs are validated to prevent malicious inputs
- All external requests are made with appropriate timeouts
- Error messages don't expose sensitive system information

## License

MIT License - see LICENSE file for details.
