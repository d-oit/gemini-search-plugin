# Shell Script Quality Skill

A comprehensive Claude Code skill for linting and testing shell scripts using industry-standard tools and 2025 best practices.

## Overview

This skill provides expert guidance on:

- **ShellCheck**: Static analysis and linting for bash/sh scripts
- **BATS**: Bash Automated Testing System for comprehensive testing
- **Best Practices**: Modern shell scripting patterns and conventions
- **CI/CD Integration**: Automated quality checks in your pipeline

## When to Use

Invoke this skill when you need to:

- Lint shell scripts and fix common issues
- Write tests for bash/sh scripts
- Set up automated testing infrastructure
- Improve shell script quality and reliability
- Integrate shell script checks into CI/CD
- Learn bash scripting best practices

## Features

### ShellCheck Integration

- Complete ShellCheck setup and configuration
- Common issue patterns and fixes
- `.shellcheckrc` configuration examples
- Editor and CI/CD integration
- Ignoring and managing warnings

### BATS Testing

- Test structure and organization
- Setup and teardown patterns
- Common assertions and helpers
- Mocking and stubbing
- Test coverage analysis

### Best Practices

- Script header templates with `set -euo pipefail`
- Error handling and logging patterns
- Function documentation standards
- Input validation techniques
- Portable path handling

### CI/CD Integration

- GitHub Actions workflows
- GitLab CI configuration
- Pre-commit hooks
- Automated quality gates

## Quick Start

### Lint a Script

```bash
# Install ShellCheck
brew install shellcheck  # macOS
sudo apt-get install shellcheck  # Linux

# Lint your script
shellcheck scripts/example.sh

# Fix issues and re-run
```

### Test a Script

```bash
# Install BATS
brew install bats-core  # macOS
sudo apt-get install bats  # Linux

# Create a test file
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

### Automated Quality Check

```bash
# Create quality check script
cat > scripts/check-quality.sh <<'EOF'
#!/bin/bash
set -euo pipefail

echo "Running ShellCheck..."
find scripts -name "*.sh" -exec shellcheck {} +

echo "Running BATS tests..."
bats tests/

echo "All checks passed!"
EOF

chmod +x scripts/check-quality.sh

# Run it
./scripts/check-quality.sh
```

## Examples

### Example 1: Well-Structured Script

```bash
#!/bin/bash
set -euo pipefail

# Function: Process input
# Arguments:
#   $1 - input_file (string)
# Returns: 0 on success, 1 on failure
process_file() {
    local input_file="$1"

    [[ -f "$input_file" ]] || {
        echo "ERROR: File not found: $input_file" >&2
        return 1
    }

    cat "$input_file"
    return 0
}

# Main
main() {
    [[ $# -lt 1 ]] && {
        echo "Usage: $0 <file>" >&2
        exit 1
    }

    process_file "$1"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

### Example 2: BATS Test

```bash
#!/usr/bin/env bats

setup() {
    source scripts/example.sh
    TEST_FILE="$(mktemp)"
    echo "test data" > "$TEST_FILE"
}

teardown() {
    rm -f "$TEST_FILE"
}

@test "process_file succeeds with valid file" {
    run process_file "$TEST_FILE"
    [ "$status" -eq 0 ]
    [ "$output" = "test data" ]
}

@test "process_file fails with missing file" {
    run process_file "/nonexistent"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "ERROR" ]]
}
```

### Example 3: GitHub Actions

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

## Common Patterns

### Testing Scripts with Arguments

```bash
@test "script accepts arguments" {
    run bash scripts/example.sh arg1 arg2
    [ "$status" -eq 0 ]
    [[ "$output" =~ "arg1" ]]
}
```

### Testing JSON Output

```bash
@test "script returns valid JSON" {
    run bash scripts/api.sh
    [ "$status" -eq 0 ]
    echo "$output" | jq empty
}
```

### Testing Error Handling

```bash
@test "script handles errors gracefully" {
    run bash scripts/example.sh invalid_input
    [ "$status" -ne 0 ]
    [[ "$output" =~ "ERROR" ]]
}
```

## File Structure

Recommended project structure for shell script testing:

```
project/
├── scripts/
│   ├── main.sh
│   ├── helper.sh
│   └── utils.sh
├── tests/
│   ├── test_helper/
│   │   └── common.bash
│   ├── main.bats
│   ├── helper.bats
│   └── utils.bats
├── .shellcheckrc
├── .github/
│   └── workflows/
│       └── quality.yml
└── README.md
```

## Tips

1. **Start with ShellCheck**: Run it on all scripts first to catch syntax issues
2. **Write Tests Early**: Create BATS tests as you develop new scripts
3. **Use Setup/Teardown**: Keep tests isolated with proper cleanup
4. **Document Functions**: Add comments with arguments and return values
5. **Check Permissions**: Ensure scripts are executable (`chmod +x`)
6. **Automate Checks**: Integrate into CI/CD to catch issues early
7. **Use Guards**: Protect main execution blocks for testability
8. **Mock External Commands**: Use test helpers to stub dependencies

## Troubleshooting

### ShellCheck

- **SC1090 warnings**: Add `# shellcheck source=path/to/file.sh`
- **SC2086 quoting**: Always quote variables: `"$var"`
- **SC2181 exit codes**: Use `if ! command; then` instead of `$?`

### BATS

- **Tests interfere**: Ensure proper `teardown()` cleanup
- **Can't source script**: Add main execution guard
- **Path issues**: Use `$BATS_TEST_DIRNAME` for relative paths

## Resources

- [ShellCheck Documentation](https://www.shellcheck.net/)
- [BATS GitHub](https://github.com/bats-core/bats-core)
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [Bash Best Practices](https://bertvv.github.io/cheat-sheets/Bash.html)

## Contributing

Found an issue or have a suggestion? Please contribute to improve this skill!

## License

This skill is part of the gemini-search plugin and follows the same license.
