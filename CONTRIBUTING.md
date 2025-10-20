# Contributing to Gemini Search Plugin

Thank you for considering contributing to the Gemini Search Plugin! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Coding Standards](#coding-standards)
- [Release Process](#release-process)

## Code of Conduct

By participating in this project, you agree to abide by our Code of Conduct (see CODE_OF_CONDUCT.md).

## Getting Started

### Prerequisites

1. **Install Gemini CLI**:
   ```bash
   npm install -g @google/genai-cli
   ```

2. **Install jq** (for JSON processing):
   ```bash
   # macOS
   brew install jq

   # Ubuntu/Debian
   sudo apt-get install jq

   # Windows (via Chocolatey)
   choco install jq
   ```

3. **Configure Gemini API Key**:
   ```bash
   gemini config set apiKey YOUR_GOOGLE_AI_API_KEY
   ```

### Setting Up Your Development Environment

1. **Fork the repository** on GitHub

2. **Clone your fork**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/gemini-search-plugin.git
   cd gemini-search-plugin
   ```

3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/ORIGINAL_OWNER/gemini-search-plugin.git
   ```

4. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Workflow

### Branch Naming Convention

- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `test/` - Test additions or modifications
- `refactor/` - Code refactoring
- `chore/` - Maintenance tasks

Example: `feature/add-cache-expiry-api`

### Making Changes

1. **Keep changes focused** - One feature/fix per PR
2. **Update documentation** - Update README.md if needed
3. **Add tests** - Include tests for new functionality
4. **Follow coding standards** - See [Coding Standards](#coding-standards)
5. **Update CHANGES.md** - Document your changes

## Testing

### Manual Testing

Test the core functionality:

```bash
# Test search wrapper
bash scripts/search-wrapper.sh search "test query"

# Test analytics
bash scripts/analytics.sh report

# Test content extraction
bash scripts/extract-content.sh extract "https://example.com" "test query"

# Test error handling
bash hooks/error-search.sh handle-error "test error" "query" "google"
```

### Integration Testing

Run the integration test suite:

```bash
# From the plugin root directory
bash tests/run-integration-tests.sh
```

### Regression Testing

Before submitting a PR, ensure:

1. All existing tests pass
2. Cache functionality works correctly
3. Analytics tracking is accurate
4. Error handling behaves as expected
5. Hooks trigger appropriately

### Test Coverage

Aim for comprehensive coverage:

- ✓ Happy path scenarios
- ✓ Error conditions
- ✓ Edge cases
- ✓ Cache hit/miss scenarios
- ✓ Retry logic
- ✓ Content validation

## Submitting Changes

### Before Submitting

1. **Update your branch** with upstream changes:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Run all tests**:
   ```bash
   bash tests/run-integration-tests.sh
   ```

3. **Check for linting issues**:
   ```bash
   # For bash scripts
   shellcheck scripts/*.sh hooks/*.sh
   ```

4. **Update documentation**:
   - Update README.md if adding features
   - Update CHANGES.md with your changes
   - Add inline comments for complex logic

### Pull Request Process

1. **Create a descriptive PR title**:
   - Good: "Add configurable cache TTL via environment variable"
   - Bad: "Update code"

2. **Fill out the PR template** completely:
   - Describe the changes
   - Link related issues
   - List testing performed
   - Add screenshots if applicable

3. **Ensure CI passes**:
   - All automated tests pass
   - No linting errors
   - No security vulnerabilities

4. **Request review**:
   - Tag appropriate reviewers
   - Be responsive to feedback
   - Update PR based on review comments

5. **Keep PR updated**:
   - Rebase on main if needed
   - Resolve merge conflicts promptly

### PR Requirements

- [ ] Tests pass
- [ ] Documentation updated
- [ ] CHANGES.md updated
- [ ] No merge conflicts
- [ ] Follows coding standards
- [ ] Reviewed and approved

## Coding Standards

### Bash Scripts

1. **Use ShellCheck** for linting:
   ```bash
   shellcheck scripts/*.sh
   ```

2. **Error handling**:
   - Use `set -euo pipefail` at the top of scripts
   - Check command exit codes
   - Provide meaningful error messages

3. **Logging**:
   - Use structured JSON logging
   - Include timestamp, level, and message
   - Log to both file and stderr

4. **Function documentation**:
   ```bash
   # Function: cache_result
   # Description: Cache search results with TTL
   # Arguments:
   #   $1 - cache_key (string)
   #   $2 - result_data (string)
   # Returns: 0 on success, 1 on failure
   cache_result() {
       # implementation
   }
   ```

5. **Variable naming**:
   - Use lowercase with underscores: `cache_key`
   - Constants in uppercase: `MAX_RETRIES`
   - Descriptive names: `search_query` not `sq`

### JSON Configuration

1. **Use consistent formatting**:
   - 2-space indentation
   - Double quotes for strings
   - No trailing commas

2. **Validate JSON**:
   ```bash
   jq empty < file.json
   ```

### Markdown Documentation

1. **Use proper headings** (H1, H2, H3)
2. **Include code examples** with syntax highlighting
3. **Add table of contents** for long documents
4. **Keep line length** reasonable (80-100 chars)

## Release Process

### Versioning

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR** (1.x.x) - Breaking changes
- **MINOR** (x.1.x) - New features, backward compatible
- **PATCH** (x.x.1) - Bug fixes, backward compatible

### Creating a Release

1. **Update version** in:
   - `.claude-plugin/plugin.json`
   - `.claude-plugin/marketplace.json`
   - README.md

2. **Update CHANGES.md**:
   - Add release date
   - Summarize changes
   - Credit contributors

3. **Create release PR**:
   ```bash
   git checkout -b release/v1.2.1
   # Make version updates
   git commit -m "chore: prepare release v1.2.1"
   git push origin release/v1.2.1
   ```

4. **After PR merge**, create and push tag:
   ```bash
   git checkout main
   git pull upstream main
   git tag -a v1.2.1 -m "Release v1.2.1"
   git push upstream v1.2.1
   ```

5. **GitHub Actions** will automatically:
   - Run tests
   - Create GitHub release
   - Publish release notes

## Questions or Issues?

- **Questions**: Open a GitHub Discussion
- **Bugs**: Open a GitHub Issue
- **Security**: Email do-tester@proton.me
- **Chat**: Join our community (link TBD)

## Recognition

Contributors will be recognized in:
- CHANGES.md release notes
- GitHub contributors list
- README.md acknowledgments (for significant contributions)

Thank you for contributing!
