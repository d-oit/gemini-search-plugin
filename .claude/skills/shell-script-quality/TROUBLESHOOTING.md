# Troubleshooting Guide

Common issues and solutions for shell script quality tools.

## ShellCheck Issues

### SC1090: Can't follow non-constant source

**Problem**: ShellCheck can't analyze sourced files with dynamic paths

```bash
# Causes SC1090
source "$CONFIG_DIR/settings.sh"
```

**Solution 1**: Add directive
```bash
# shellcheck source=config/settings.sh
source "$CONFIG_DIR/settings.sh"
```

**Solution 2**: Use relative path
```bash
# shellcheck source=./lib/utils.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/utils.sh"
```

### SC2086: Double quote to prevent word splitting

**Problem**: Unquoted variables cause issues

```bash
# ❌ Bad
cp $files $dest
```

**Solution**: Always quote
```bash
# ✅ Good
cp "$files" "$dest"
```

**When intentional**: Use array or disable
```bash
# shellcheck disable=SC2086
cp $files $dest  # Intentional word splitting
```

### SC2155: Declare and assign separately

**Problem**: Masks command failures

```bash
# ❌ Bad - doesn't catch curl failure
local result=$(curl -s api.example.com)
```

**Solution**: Separate declaration
```bash
# ✅ Good
local result
result=$(curl -s api.example.com) || return 1
```

### SC2181: Check exit code directly

**Problem**: Race condition with $?

```bash
# ❌ Bad
command
if [[ $? -ne 0 ]]; then
```

**Solution**: Test directly
```bash
# ✅ Good
if ! command; then
```

### False Positives

**Disable specific line**:
```bash
# shellcheck disable=SC2086
echo $INTENTIONAL_WORD_SPLITTING
```

**Disable entire file**:
```bash
#!/bin/bash
# shellcheck disable=SC2086,SC2181
```

**Disable in .shellcheckrc**:
```bash
disable=SC2086,SC2181
```

## BATS Issues

### Tests Pass Individually But Fail Together

**Problem**: State pollution between tests

**Solution**: Proper cleanup in teardown
```bash
teardown() {
    # Reset environment
    unset MY_VAR
    
    # Clean temp files
    [[ -d "$TEST_TEMP_DIR" ]] && rm -rf "$TEST_TEMP_DIR"
    
    # Restore PATH
    export PATH="$ORIGINAL_PATH"
}
```

### Can't Source Script

**Problem**: Script executes on source

**Bad script**:
```bash
#!/bin/bash
# Script runs immediately
echo "Starting..."
main "$@"
```

**Solution**: Add execution guard
```bash
#!/bin/bash

main() {
    echo "Starting..."
}

# Only run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

### Path Issues in Tests

**Problem**: Relative paths don't work

**Solution**: Use BATS variables
```bash
setup() {
    # Use BATS test directory
    SCRIPT_DIR="$BATS_TEST_DIRNAME/../scripts"
    source "$SCRIPT_DIR/example.sh"
}
```

### Temp File Conflicts

**Problem**: Tests conflict on temp files

**Solution**: Unique temp directories
```bash
setup() {
    TEST_TEMP_DIR="$(mktemp -d -t bats-test.XXXXXX)"
}

teardown() {
    [[ -d "$TEST_TEMP_DIR" ]] && rm -rf "$TEST_TEMP_DIR"
}
```

### Mock Not Working

**Problem**: Original command still runs

**Solution**: Check PATH order
```bash
create_mock() {
    local cmd="$1"
    cat > "$TEST_TEMP_DIR/$cmd" <<'EOF'
#!/bin/bash
echo "mock output"
EOF
    chmod +x "$TEST_TEMP_DIR/$cmd"
    
    # Put mock first in PATH
    export PATH="$TEST_TEMP_DIR:$PATH"
    
    # Verify
    which "$cmd"  # Should show mock path
}
```

## Performance Issues

### Slow ShellCheck

**Problem**: Linting takes too long

**Solution 1**: Exclude large files
```bash
# .shellcheckrc
exclude-dir=vendor
exclude-dir=node_modules
```

**Solution 2**: Parallel execution
```bash
find scripts -name '*.sh' | parallel shellcheck
```

**Solution 3**: Cache in CI
```yaml
- uses: actions/cache@v4
  with:
    path: ~/.cache/shellcheck
    key: shellcheck-${{ hashFiles('**/*.sh') }}
```

### Slow BATS Tests

**Problem**: Tests take too long

**Solution 1**: Parallel tests
```bash
# Run in parallel (if tests are independent)
bats --jobs 4 tests/
```

**Solution 2**: Skip slow tests locally
```bash
@test "slow integration test" {
    [[ "$SKIP_SLOW" == "true" ]] && skip
    # Slow test...
}
```

**Solution 3**: Mock expensive operations
```bash
@test "api call" {
    # Mock curl instead of real API call
    create_mock "curl" '{"status":"ok"}' 0
    run script_that_uses_curl
    [ "$status" -eq 0 ]
}
```

## Debugging Techniques

### Debug BATS Tests

**Enable debug output**:
```bash
@test "debug example" {
    # Show variables
    echo "DEBUG: variable=$variable" >&3
    
    run command
    
    # Show output
    echo "DEBUG: status=$status" >&3
    echo "DEBUG: output=$output" >&3
}
```

**Run with debug**:
```bash
bats -t tests/example.bats  # Show timing
bats -x tests/example.bats  # Show trace
```

### Debug Shell Scripts

**Enable tracing**:
```bash
#!/bin/bash
set -x  # Print commands before execution

# Or conditionally
[[ "${DEBUG:-}" == "true" ]] && set -x
```

**Run with debug**:
```bash
DEBUG=true bash script.sh
bash -x script.sh
```

### ShellCheck Debug

**See wiki page for warning**:
```bash
shellcheck -W SC2086 script.sh
```

**Show all checks**:
```bash
shellcheck -a script.sh
```

## CI/CD Issues

### GitHub Actions Fails but Local Passes

**Problem**: Different environments

**Solution**: Match versions
```yaml
- name: Install exact versions
  run: |
    shellcheck --version
    bats --version
```

**Solution**: Use containers
```yaml
runs-on: ubuntu-latest
container:
  image: koalaman/shellcheck:stable
```

### Permission Denied in CI

**Problem**: Scripts not executable

**Solution**: Set permissions in CI
```yaml
- name: Make scripts executable
  run: find scripts -name '*.sh' -exec chmod +x {} +
```

**Solution**: Track permissions in git
```bash
git add --chmod=+x scripts/*.sh
```

### Test Timeout

**Problem**: Tests hang in CI

**Solution**: Add timeout
```yaml
- name: Run tests
  timeout-minutes: 5
  run: bats tests/
```

## Platform-Specific Issues

### macOS vs Linux

**Problem**: Different command behaviors

**Solution**: Use portable commands
```bash
# ❌ Bad - GNU-specific
date -d "yesterday"
stat -c %Y file

# ✅ Good - Portable
date -v-1d  # macOS
date --date="yesterday"  # Linux

# Or detect platform
if [[ "$(uname)" == "Darwin" ]]; then
    # macOS version
else
    # Linux version
fi
```

### Windows (WSL/Git Bash)

**Problem**: Line endings

**Solution**: Configure git
```bash
git config --global core.autocrlf input
```

**Solution**: Add .gitattributes
```
*.sh text eol=lf
*.bats text eol=lf
```

## Common Error Messages

### "command not found: bats"

**Solution**:
```bash
# Install BATS
brew install bats-core  # macOS
sudo apt install bats   # Linux
```

### "No such file or directory"

**Check**:
- File paths are correct
- Using absolute paths or proper relative paths
- BATS_TEST_DIRNAME is used correctly

### "Syntax error near unexpected token"

**Common causes**:
- Missing quotes
- Wrong script interpreter (bash vs sh)
- Line ending issues (CRLF vs LF)

**Debug**:
```bash
# Check interpreter
head -1 script.sh

# Check line endings
file script.sh

# Fix line endings
dos2unix script.sh
```

## Getting Help

### ShellCheck
- Wiki: https://www.shellcheck.net/wiki/
- GitHub Issues: https://github.com/koalaman/shellcheck/issues

### BATS
- Docs: https://bats-core.readthedocs.io/
- GitHub Issues: https://github.com/bats-core/bats-core/issues

### Interactive Help
```bash
# ShellCheck help
shellcheck --help
man shellcheck

# BATS help
bats --help
man bats
```
