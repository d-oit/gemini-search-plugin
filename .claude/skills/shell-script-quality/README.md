# Shell Script Quality Skill

A Claude Code skill for linting and testing shell scripts using ShellCheck and BATS with 2025 best practices.

## Overview

This skill helps you:
- Lint bash/sh scripts with ShellCheck
- Write and run BATS tests
- Integrate quality checks into CI/CD
- Follow modern shell scripting best practices

## For Claude Code Users

See **[SKILL.md](SKILL.md)** for the complete skill implementation with:
- Core workflow and checklists
- Step-by-step guidance
- Validation patterns
- Plugin-specific testing patterns
- Quick reference to detailed guides

## Quick Start

### 1. Lint a Script

```bash
# Install ShellCheck
brew install shellcheck         # macOS
sudo apt-get install shellcheck # Linux

# Lint your script
shellcheck scripts/example.sh
```

### 2. Write Tests

```bash
# Install BATS
brew install bats-core          # macOS
sudo apt-get install bats       # Linux

# Create test file
cat > tests/example.bats <<'EOF'
#!/usr/bin/env bats

@test "script runs successfully" {
    run bash scripts/example.sh
    [ "$status" -eq 0 ]
}
EOF

# Run tests
bats tests/
```

### 3. GitHub Actions Integration

```yaml
name: Shell Quality
on: [push, pull_request]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: ShellCheck
        uses: ludeeus/action-shellcheck@master
      - name: Install BATS
        run: sudo apt-get install -y bats
      - name: Run Tests
        run: bats tests/
```

## Script Template

Use this template for new scripts:

```bash
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

error_exit() {
    echo "ERROR: $1" >&2
    exit "${2:-1}"
}

main() {
    [[ $# -lt 1 ]] && {
        echo "Usage: $0 <argument>" >&2
        exit 1
    }
    
    # Your logic here
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

## Project Structure

Recommended layout:

```
project/
├── scripts/          # Shell scripts
│   ├── main.sh
│   └── utils.sh
├── tests/            # BATS tests
│   ├── main.bats
│   └── utils.bats
├── .shellcheckrc     # ShellCheck config
└── .github/
    └── workflows/
        └── quality.yml
```

## Common Test Patterns

### Test with Valid Input

```bash
@test "function succeeds with valid input" {
    run example_function "test"
    [ "$status" -eq 0 ]
    [ -n "$output" ]
}
```

### Test Error Handling

```bash
@test "function fails gracefully" {
    run example_function ""
    [ "$status" -ne 0 ]
    [[ "$output" =~ "ERROR" ]]
}
```

### Test JSON Output

```bash
@test "script returns valid JSON" {
    run bash scripts/api.sh
    [ "$status" -eq 0 ]
    echo "$output" | jq empty
}
```

## Configuration

Create `.shellcheckrc` in project root:

```bash
shell=bash
disable=SC1090
enable=all
source-path=SCRIPTDIR
```

## Quick Commands

```bash
# Lint all scripts
find scripts -name "*.sh" -exec shellcheck {} +

# Run all tests
bats tests/

# Run with verbose output
bats -t tests/

# Combined check
shellcheck scripts/*.sh && bats tests/
```

## Troubleshooting

**ShellCheck Issues:**
- SC2086 quoting: Always quote variables `"$var"`
- SC1090 warnings: Add `# shellcheck source=path/to/file.sh`
- SC2181 exit codes: Use `if ! command; then` instead of `$?`

**BATS Issues:**
- Tests interfere: Ensure proper `teardown()` cleanup
- Can't source script: Add main execution guard
- Path issues: Use `$BATS_TEST_DIRNAME` for relative paths

## Resources

- [ShellCheck Documentation](https://www.shellcheck.net/)
- [BATS GitHub](https://github.com/bats-core/bats-core)
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [SKILL.md](SKILL.md) - Complete skill implementation for Claude

## Contributing

Contributions welcome! Please submit issues or pull requests.

## License

Part of the gemini-search-plugin project.
