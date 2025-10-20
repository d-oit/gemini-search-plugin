# Changelog

All notable changes to the Gemini Search Plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-01-20

### Initial Release

This is the first public release of the Gemini Search Plugin for Claude Code.

#### Added

**Core Search Functionality**
- Integrated Gemini CLI in headless mode (`gemini -p` with `--yolo` flag)
- Restricted Gemini CLI to only use `google_web_search` tool via `.gemini/settings.json`
- Zero direct web scraping or HTTP requests - all content via Gemini's grounded search

**Caching System**
- Smart caching with 1-hour TTL
- MD5-based cache keys for efficient lookups
- Platform-independent cache validation (supports macOS, Linux, Windows)
- Cache statistics and management commands

**Analytics & Tracking**
- Comprehensive analytics tracking with JSON storage
- Cache hit/miss rate monitoring
- Search engine usage distribution
- Top 10 queries tracking (automatically maintained)
- Token savings estimates (39% per cache hit)
- Atomic writes to prevent data corruption

**Content Extraction**
- Dynamic content extraction from web pages using Gemini CLI
- Clean text extraction (removes HTML, scripts, styling)
- Content relevance validation
- Multiple content sources with fallback methods

**Validation Pipeline**
- Multi-stage result validation to prevent false positives
- Query term matching with relevance scoring
- Domain blacklist filtering (example.com, test.com, etc.)
- Content quality checks (minimum length, error indicators)
- 50% minimum relevance threshold for search results
- 30% minimum relevance threshold for extracted content

**Commands**
- `/search [query]` - Perform web search with caching and validation
- `/search-stats` - View analytics and cache statistics
- `/clear-cache` - Clear cache and reset analytics

**Hooks**
- `error-search.sh` - Auto-detects errors with exponential backoff retry logic
- `pre-edit-search.sh` - Provides search suggestions before edits

**Agents**
- `gemini-search` - Isolated context subagent for search operations (39% token savings)

**Error Handling**
- Exponential backoff retry logic (configurable via environment variables)
- Error type categorization (timeout, not_found, server_error, rate_limit, etc.)
- Comprehensive error logging with structured JSON format
- Graceful degradation when services unavailable

**Development & Testing**
- Integration test suite with 10 automated tests
- ShellCheck linting for all bash scripts
- JSON validation for all configuration files
- CI/CD workflows (GitHub Actions)
- Release automation with version validation

**Security Features**
- Content size limits (100KB default, configurable)
- URL validation to prevent injection
- Timeout protection (15s default)
- Error message sanitization
- No hardcoded credentials
- Comprehensive SECURITY.md documentation

**Documentation**
- Complete README.md with features and usage
- CONTRIBUTING.md with development guidelines
- SECURITY.md with vulnerability reporting
- DEPLOYMENT.md with testing and release procedures
- Inline documentation in all scripts

**Repository Setup**
- Branch protection rules on master branch
- Issue and PR templates
- Automated CI/CD pipeline
- Security scanning (Trivy)
- Semantic versioning support

#### Configuration

Environment variables for customization:
- `CACHE_DIR` - Cache directory location
- `CACHE_TTL` - Cache time-to-live in seconds (default: 3600)
- `LOG_FILE` - Main log file path
- `ERROR_LOG_FILE` - Error log path
- `MAX_RETRIES` - Retry attempts on failure (default: 3)
- `RETRY_DELAY` - Initial retry delay in seconds (default: 1)
- `BACKOFF_BASE` - Exponential backoff multiplier (default: 2)
- `EXPONENTIAL_MAX_DELAY` - Maximum retry delay cap (default: 60)
- `ANALYTICS_DIR` - Analytics data directory
- `TIMEOUT_SECONDS` - Content extraction timeout (default: 15)
- `MAX_CONTENT_SIZE` - Maximum content size to process (default: 100000)

#### Dependencies

- **Required**: Gemini CLI (`npm install -g @google/genai-cli`) - must be pre-authenticated
- **Required**: `jq` for JSON processing
- **Required**: `md5sum` for cache key generation
- **Required**: `stat` for cache TTL validation

**Note**: The plugin uses the Gemini CLI's existing authentication. No separate API key configuration is needed for the plugin itself.

#### Known Limitations

- Cache stored in `/tmp` by default (consider private location on shared systems)
- Log files may contain sensitive query information
- Requires Gemini CLI to be pre-authenticated (`gemini auth login` or equivalent)

---

## Release Checklist

For maintainers preparing releases:

- [ ] Update version in `.claude-plugin/plugin.json`
- [ ] Update version in `.claude-plugin/marketplace.json`
- [ ] Update CHANGES.md with release date
- [ ] Run integration tests: `bash tests/run-integration-tests.sh`
- [ ] Commit changes: `git commit -m "chore: prepare release vX.Y.Z"`
- [ ] Create tag: `git tag -a vX.Y.Z -m "Release vX.Y.Z"`
- [ ] Push: `git push origin master && git push origin vX.Y.Z`

---

[0.1.0]: https://github.com/do-ops885/gemini-search-plugin/releases/tag/v0.1.0
