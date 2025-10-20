# Security Policy

## Supported Versions

We release patches for security vulnerabilities. Currently supported versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.2.x   | :white_check_mark: |
| < 1.2   | :x:                |

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report security vulnerabilities by emailing **do-tester@proton.me** with:

1. **Description** of the vulnerability
2. **Steps to reproduce** the issue
3. **Potential impact** of the vulnerability
4. **Suggested fix** (if you have one)

### What to expect

- **Acknowledgment**: Within 48 hours of your report
- **Initial assessment**: Within 7 days
- **Fix timeline**: Depends on severity
  - Critical: 1-7 days
  - High: 7-14 days
  - Medium: 14-30 days
  - Low: 30-90 days

## Security Best Practices

### For Users

1. **API Key Protection**
   - Never commit your Gemini API key to version control
   - Use environment variables or secure key management
   - Rotate API keys regularly

2. **Script Execution**
   - Review scripts before execution
   - Understand what permissions hooks require
   - Use the latest version of the plugin

3. **Content Validation**
   - Be aware that search results come from external sources
   - Validate URLs before visiting them
   - Review extracted content for relevance

### For Contributors

1. **Code Review**
   - All PRs require review before merging
   - Security-sensitive changes require additional review
   - Follow secure coding practices

2. **Dependencies**
   - Keep dependencies up to date
   - Review dependency changes for security issues
   - Use `npm audit` or equivalent tools

3. **Input Validation**
   - Validate and sanitize all user inputs
   - Prevent command injection in bash scripts
   - Escape special characters appropriately

4. **Secrets Management**
   - Never hardcode credentials
   - Use environment variables for sensitive data
   - Add sensitive files to `.gitignore`

## Security Features

### Current Implementation

1. **Content Size Limits**
   - Maximum content size: 100KB (configurable via `MAX_CONTENT_SIZE`)
   - Prevents processing of oversized responses

2. **URL Validation**
   - Validates URLs before processing
   - Prevents malicious input injection

3. **Timeout Protection**
   - All external operations have timeouts (default: 15s)
   - Prevents hanging on unresponsive services

4. **No Direct Web Scraping**
   - All web content comes through Gemini CLI's `google_web_search` tool
   - Zero direct HTTP requests or HTML parsing
   - Reduces attack surface

5. **Error Message Sanitization**
   - Error messages don't expose sensitive system information
   - Structured logging prevents information leakage

6. **Tool Restriction**
   - Gemini CLI restricted to only `google_web_search` tool via `.gemini/settings.json`
   - Prevents unauthorized tool usage

## Known Security Considerations

### Cache Security

- Cache files are stored in `/tmp/gemini-search-cache/` by default
- On shared systems, consider setting `CACHE_DIR` to a private location
- Cache files contain search results and may include sensitive queries

### Log Files

- Logs may contain search queries and results
- Default locations:
  - `/tmp/gemini-search.log`
  - `/tmp/gemini-search-errors.log`
- Consider log rotation and secure log storage in production

### API Key Exposure

- Gemini CLI requires an API key configured via `gemini config`
- Ensure your API key is not exposed in:
  - Environment variables in CI/CD
  - Screenshot or screen recordings
  - Log files or error messages

## Vulnerability Disclosure Policy

We follow responsible disclosure:

1. Reporter submits vulnerability privately
2. We confirm and assess the issue
3. We develop and test a fix
4. We release the fix and notify users
5. We publicly acknowledge the reporter (if desired)

## Security Updates

Security updates are released as patch versions (e.g., 1.2.1) and announced via:

- GitHub Security Advisories
- Release notes
- Email notification to repository watchers

## Contact

For security concerns: **do-tester@proton.me**

For general questions: Open a GitHub issue

## Acknowledgments

We thank the security researchers and community members who help keep this project secure.
