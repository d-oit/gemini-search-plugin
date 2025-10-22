# Changelog

All notable changes to the Gemini Search Plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.2] - 2025-10-21

### Added

- **Skills System**: Four comprehensive Claude Code skills for plugin development workflow
  - `plugin-creator`: Complete guide for creating Claude Code plugins with structure, commands, agents, hooks
  - `shell-script-quality`: ShellCheck and BATS testing framework integration and best practices
  - `github-repo-management`: GitHub repository management including issues, PRs, releases, and CI/CD
  - `web-research`: Token-efficient web research using gemini-search agent (30-40% token savings)
- Skills documentation with README.md files for each skill
- Main `.claude/skills/README.md` with comprehensive overview and integration guide
- Cross-references between skills for integrated workflow

### Fixed

- Fixed ShellCheck warnings in `hooks/error-search.sh` (SC2221/SC2222 pattern matching)
- Fixed ShellCheck info in `scripts/search-wrapper.sh` (SC1091 with proper directive)
- Fixed ShellCheck warning in `tests/run-integration-tests.sh` (SC2155 declare and assign separately)
- Fixed ShellCheck info in `tests/test-link-validation.sh` (SC1091 with proper directive)

### Improved

- All shell scripts now pass ShellCheck validation without warnings
- Enhanced code quality with proper shellcheck directives
- Better test script quality assurance
- Comprehensive skills-based workflow for plugin development

### Documentation

- Added skill-specific README files for quick reference
- Updated plugin-creator skill with related skills references
- Complete web-research skill documentation with usage patterns and examples
- GitHub repository management skill with CI/CD workflow examples
- Shell script quality skill with complete testing and linting guide

## [0.1.1] - 2025-10-21

### Changed

- **BREAKING**: Updated Gemini CLI command format to use explicit `googleSearch` tool invocation
  - Changed from: `gemini -p "query" --yolo --output-format json`
  - Changed to: `gemini -p "/tool:googleSearch query:\"search_text\" raw:true" --yolo --output-format json -m "gemini-2.5-flash"`
- Improved search reliability and consistency with explicit tool usage
- Updated all scripts to use new Gemini CLI format:
  - `scripts/search-wrapper.sh`
  - `scripts/extract-content.sh`

### Fixed

- Fixed validation function arithmetic operation that could cause script exit with `set -e`
- Improved ShellCheck compliance:
  - Split variable declarations and assignments (SC2155)
  - Changed to direct exit code checking instead of `$?` (SC2181)
  - Replaced `sed` with bash parameter expansion (SC2001)
  - Fixed array expansion using `read -ra` instead of unquoted expansion (SC2206)
- Fixed false positive validation to properly detect and filter invalid domains

### Improved

- Enhanced code quality and reliability with ShellCheck best practices
- Better error handling in validation and search functions
- More robust script execution with proper return value handling

## [0.1.0] - 2025-10-20

### Added

- Initial release of Gemini Search Plugin
- Core search functionality using Gemini CLI with `google_web_search` tool
- Smart caching system with 1-hour TTL and MD5 keying
- Three slash commands:
  - `/search` - Perform web searches
  - `/search-stats` - View usage statistics
  - `/clear-cache` - Clear search cache
- Subagent architecture for context isolation
- Comprehensive error handling and retry logic
- Dynamic content extraction from websites
- False positive validation with relevance scoring
- Static link validation for URL accessibility
- Two hooks:
  - Error detection hook
  - Pre-edit suggestion hook
- Complete analytics and logging system
- Production-ready scripts:
  - `scripts/search-wrapper.sh` - Main search wrapper
  - `scripts/analytics.sh` - Usage tracking
  - `scripts/extract-content.sh` - Content extraction
  - `scripts/validate-links.sh` - Link validation
  - `scripts/prepare-release.sh` - Release preparation

### Features

- **Gemini CLI Integration**: Uses Gemini CLI in headless mode with `--yolo` flag
- **Tool Restriction**: Limits Gemini to only `google_web_search` tool via `.gemini/settings.json`
- **Grounded Results**: All results from Google's web search via Gemini
- **Smart Caching**: MD5-based cache with configurable TTL
- **Auto-retry Logic**: Exponential backoff on failures
- **Comprehensive Logging**: Detailed JSON logging for debugging
- **Security**: URL validation, content size limits, timeout handling

### Documentation

- Comprehensive README.md with features, usage, and configuration
- GEMINI.md explaining Gemini CLI integration
- Detailed agent documentation
- Command documentation with examples
- Validation methodology documentation

### Configuration

- Environment variable support for all settings
- Configurable cache TTL, retry logic, and timeouts
- Adjustable content extraction limits
- Flexible logging configuration

## [Unreleased]

### Planned

- Enhanced content extraction with better parsing
- Additional search engine fallbacks
- Improved relevance scoring algorithms
- Performance optimizations
- Extended analytics and reporting

---

## Version History

- **0.1.2** - Skills system for plugin development, code quality improvements
- **0.1.1** - Gemini CLI format update and ShellCheck improvements
- **0.1.0** - Initial release with core functionality

## Upgrade Guide

### Upgrading to 0.1.1 from 0.1.0

The 0.1.1 update includes a breaking change to how the Gemini CLI is invoked. No user action is required as the change is internal to the plugin scripts. However, if you have customized any scripts, you'll need to update them to use the new format.

**What Changed:**

- Gemini CLI now explicitly invokes the `googleSearch` tool
- Added `-m "gemini-2.5-flash"` flag for model specification
- Added `raw:true` parameter for unprocessed results

**Benefits:**

- More reliable search results
- Explicit tool usage prevents ambiguity
- Better control over response format

---

For more information, see the [README](README.md) or visit the [GitHub repository](https://github.com/anthropics/claude-code).
