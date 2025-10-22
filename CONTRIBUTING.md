# Contributing to Gemini Search Plugin

Thank you for your interest in contributing to the Gemini Search Plugin! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Pull Request Process](#pull-request-process)
- [Issue Reporting](#issue-reporting)

## Code of Conduct

This project follows the Anthropic Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

### Our Standards

- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on what is best for the community
- Show empathy towards other community members

## Getting Started

### Prerequisites

Before contributing, ensure you have:

1. **Gemini CLI** installed:

   ```bash
   npm install -g @google/gemini-cli
   ```

2. **Development tools**:

   ```bash
   # ShellCheck for script linting
   brew install shellcheck  # macOS
   # or
   apt-get install shellcheck  # Linux
   ```

3. **Git** for version control

4. **Basic understanding** of:
   - Bash scripting
   - Claude Code plugin architecture
   - Gemini CLI usage

## Development Setup

1. **Fork and clone** the repository:

   ```bash
   git clone https://github.com/d-oit/gemini-search-plugin.git
   cd gemini-search-plugin
   ```

2. **Create a feature branch**:

   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes** and test thoroughly

4. **Run linting**:

   ```bash
   shellcheck scripts/*.sh
   ```

5. **Test your changes**:

   ```bash
   bash tests/run-integration-tests.sh
   ```

## How to Contribute

### Types of Contributions

We welcome several types of contributions:

1. **Bug Fixes** - Fix issues in existing functionality
2. **Features** - Add new capabilities
3. **Documentation** - Improve or add documentation
4. **Tests** - Add or improve test coverage
5. **Performance** - Optimize existing code
6. **Refactoring** - Improve code quality without changing behavior

### Contribution Workflow

1. **Check existing issues** - Look for related issues or create a new one
2. **Discuss your idea** - Comment on the issue to discuss your approach
3. **Implement your changes** - Write code following our standards
4. **Test thoroughly** - Ensure all tests pass
5. **Submit a pull request** - Reference the issue number
6. **Address feedback** - Work with maintainers to refine your contribution

## Coding Standards

### Bash Script Standards

All bash scripts must:

1. **Use strict error handling**:

   ```bash
   set -euo pipefail
   ```

2. **Follow ShellCheck recommendations**:
   - Separate variable declarations and assignments (SC2155)
   - Check exit codes directly instead of using `$?` (SC2181)
   - Use bash parameter expansion instead of `sed` when possible (SC2001)
   - Quote array expansions properly (SC2206)

3. **Include proper documentation**:

   ```bash
   # Function: Function name
   # Arguments:
   #   $1 - description (type)
   #   $2 - description (type)
   # Returns: description
   function_name() {
       # Implementation
   }
   ```

4. **Use meaningful variable names**:

   ```bash
   # Good
   local query_string="$1"
   local cache_file="$CACHE_DIR/$cache_key.json"

   # Bad
   local q="$1"
   local f="$DIR/$k.json"
   ```

5. **Handle errors gracefully**:

   ```bash
   if ! result=$(some_command); then
       log_error "Command failed: some_command"
       return 1
   fi
   ```

### Code Style

- **Indentation**: 4 spaces (no tabs)
- **Line length**: Maximum 120 characters
- **Function length**: Keep functions focused and under 50 lines
- **Comments**: Explain "why" not "what"
- **Logging**: Use structured JSON logging

### Variable Declaration Best Practices

Always split variable declarations and assignments:

```bash
# Good
local timestamp
timestamp=$(date -Iseconds)

# Bad
local timestamp=$(date -Iseconds)
```

### Exit Code Checking

Check exit codes directly:

```bash
# Good
if content=$(extract_content "$url"); then
    echo "$content"
fi

# Bad
content=$(extract_content "$url")
if [[ $? -eq 0 ]]; then
    echo "$content"
fi
```

## Testing Guidelines

### Test Requirements

All contributions should include:

1. **Unit tests** for new functions
2. **Integration tests** for new features
3. **Manual testing** to verify behavior

### Running Tests

```bash
# Run all integration tests
bash tests/run-integration-tests.sh

# Run specific script tests
bash scripts/search-wrapper.sh search "test query"
bash scripts/search-wrapper.sh validate-result "title" "url" "snippet" "query"

# Check syntax
bash -n scripts/*.sh

# Lint scripts
shellcheck scripts/*.sh
```

### Test Coverage

Ensure tests cover:

- ✅ Happy path (normal operation)
- ✅ Error cases (failures, invalid input)
- ✅ Edge cases (empty input, special characters)
- ✅ Performance (caching, timeouts)

### Writing Tests

Create test scripts in the `tests/` directory:

```bash
#!/bin/bash
# tests/test-feature.sh

set -euo pipefail

echo "Testing feature X..."

# Setup
EXPECTED="expected result"
ACTUAL=$(your_function "input")

# Assert
if [[ "$ACTUAL" == "$EXPECTED" ]]; then
    echo "✓ Test passed"
    exit 0
else
    echo "✗ Test failed: expected '$EXPECTED', got '$ACTUAL'"
    exit 1
fi
```

## Pull Request Process

### Before Submitting

1. ✅ All tests pass
2. ✅ ShellCheck shows no errors
3. ✅ Code follows style guidelines
4. ✅ Documentation is updated
5. ✅ CHANGELOG.md is updated
6. ✅ Commit messages are clear

### PR Checklist

- [ ] Branch is up to date with `main`
- [ ] All commits are signed off
- [ ] Tests added/updated
- [ ] Documentation added/updated
- [ ] CHANGELOG.md updated
- [ ] ShellCheck passes
- [ ] Integration tests pass

### Commit Messages

Follow conventional commits format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Test additions/changes
- `chore`: Maintenance tasks

**Example:**

```
feat(search): add support for multi-engine search

Added ability to query multiple search engines simultaneously
with configurable priority and fallback logic.

Closes #123
```

### PR Description Template

```markdown
## Description
Brief description of changes

## Motivation
Why is this change needed?

## Changes Made
- Change 1
- Change 2
- Change 3

## Testing
How was this tested?

## Screenshots (if applicable)
Include screenshots for UI changes

## Related Issues
Closes #issue_number
```

## Issue Reporting

### Bug Reports

When reporting bugs, include:

1. **Environment**:
   - OS and version
   - Gemini CLI version
   - Claude Code version
   - Plugin version

2. **Steps to reproduce**:
   - Detailed steps
   - Expected behavior
   - Actual behavior

3. **Logs**:
   - Relevant error messages
   - Log file contents
   - Stack traces

**Template:**

```markdown
### Environment
- OS: macOS 14.0
- Gemini CLI: 1.2.3
- Plugin Version: 0.1.1

### Steps to Reproduce
1. Run /search "query"
2. Observe error

### Expected Behavior
Search should return results

### Actual Behavior
Error: "Gemini CLI search failed"

### Logs
```

<error logs here>
```
```

### Feature Requests

For feature requests, include:

1. **Use case**: Why is this needed?
2. **Proposed solution**: How should it work?
3. **Alternatives**: Other approaches considered
4. **Benefits**: Who benefits and how?

## Development Tips

### Debugging

Enable debug logging:

```bash
# In search-wrapper.sh
log_message "DEBUG" "Variable value: $var"

# View logs
tail -f /tmp/gemini-search.log
```

### Local Testing

Test without installing the plugin:

```bash
# Run scripts directly
bash scripts/search-wrapper.sh search "test query"

# Test with different environments
CACHE_TTL=60 bash scripts/search-wrapper.sh search "query"
```

### Performance Profiling

Check script performance:

```bash
time bash scripts/search-wrapper.sh search "query"
```

## Getting Help

- **Issues**: Create a GitHub issue
- **Discussions**: Use GitHub Discussions
- **Documentation**: Check README.md and docs/

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to the Gemini Search Plugin! 🎉
