# ShellCheck Complete Guide

Comprehensive ShellCheck reference for shell script quality assurance.

## Common Warnings & Fixes

### SC2086: Double quote to prevent globbing
**Problem**: Unquoted variables can cause word splitting and globbing

```bash
# ❌ Bad
cp $files $dest
for arg in $@; do

# ✅ Good
cp "$files" "$dest"
for arg in "$@"; do
```

### SC2155: Declare and assign separately
**Problem**: Masks return values from commands

```bash
# ❌ Bad
local result=$(curl -s api.example.com)

# ✅ Good
local result
result=$(curl -s api.example.com)
```

### SC2181: Check exit code directly
**Problem**: Race condition with $?

```bash
# ❌ Bad
command
if [[ $? -ne 0 ]]; then

# ✅ Good
if ! command; then
```

### SC2068: Double quote array expansions
```bash
# ❌ Bad
for file in ${files[@]}; do

# ✅ Good
for file in "${files[@]}"; do
```

## Configuration

**.shellcheckrc** examples:

```bash
# Basic config
shell=bash
enable=all
disable=SC1090,SC2034
source-path=SCRIPTDIR:./lib

# Strict mode
shellcheckrc_strict() {
    cat &gt;&gt; .shellcheckrc &lt;&lt; 'EOF'
disable=SC2016,SC2031,SC2086
EOF
}
```

## Inline Directives

```bash
# Disable specific line
# shellcheck disable=SC2086
cp $files $dest

# Source directive
# shellcheck source=lib/utils.sh
source "./lib/utils.sh"

# Disable entire file (top)
# shellcheck disable=SC1090
```

## CI/CD Integration

```bash
# GitHub Actions
- name: ShellCheck
  uses: ludeeus/action-shellcheck@master
  with:
    scandir: 'scripts/'
    severity: warning

# GitLab CI
shellcheck:
  image: koalaman/shellcheck-alpine:stable
  script:
    - shellcheck scripts/*.sh
```

## Quick Commands

```bash
# Lint all scripts
find . -name '*.sh' -exec shellcheck {} +

# JSON output for parsing
shellcheck -f json scripts/*.sh &gt; shellcheck.json

# Specific shell dialect
shellcheck -s bash script.sh
shellcheck -s sh portable.sh

# Exclude warnings
shellcheck -e SC2086,SC2181 script.sh
```

## Performance Tips

- Use `--exclude` for known false positives
- Cache results in CI with `shellcheck --check-updated`
- Parallel execution: `parallel shellcheck ::: scripts/*.sh`

## Editor Integration

**VS Code**:
```json
{
  "shellcheck.enable": true,
  "shellcheck.run": "workspace"
}
```

**Vim**:
```vim
let g:shellcheck_enabled = 1
```