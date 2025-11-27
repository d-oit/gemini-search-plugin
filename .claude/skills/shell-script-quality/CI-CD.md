# CI/CD Integration

Complete CI/CD workflows for shell script quality assurance.

## GitHub Actions

**.github/workflows/shell-quality.yml**:

```yaml
name: Shell Script Quality
on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]

jobs:
  shellcheck:
    name: ShellCheck
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run ShellCheck
        uses: ludeeus/action-shellcheck@master
        with:
          scandir: './scripts'
          severity: warning
          additional_files: 'hooks tests/*.sh'

  bats:
    name: BATS Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install BATS
        run: sudo apt-get install -y bats
      - name: Run Tests
        run: bats tests/

  quality-gate:
    name: Complete Quality Check
    runs-on: ubuntu-latest
    needs: [shellcheck, bats]
    steps:
      - uses: actions/checkout@v4
      - name: All checks passed
        run: echo "✅ Shell script quality gate passed!"
```

## GitLab CI

**.gitlab-ci.yml**:

```yaml
stages:
  - lint
  - test

shellcheck:
  stage: lint
  image: koalaman/shellcheck-alpine:stable
  script:
    - shellcheck scripts/*.sh hooks/*.sh tests/*.sh
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH == "main"

bats:
  stage: test
  image: ubuntu:latest
  before_script:
    - apt-get update && apt-get install -y bats
  script:
    - bats tests/
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH == "main"
```

## Pre-commit Hooks

**.git/hooks/pre-commit**:

```bash
#!/bin/bash
set -euo pipefail

changed_scripts=$(git diff --cached --name-only | grep -E '\.(sh|bash)$' || true)

if [[ -z "$changed_scripts" ]]; then
    exit 0
fi

echo "🔍 Checking shell scripts..."

# ShellCheck
for script in $changed_scripts; do
    shellcheck "$script" || {
        echo "❌ ShellCheck failed: $script"
        exit 1
    }
done

# BATS (if tests exist)
if [[ -d tests ]]; then
    bats tests/ || {
        echo "❌ BATS tests failed"
        exit 1
    }
fi

echo "✅ All checks passed!"
```

Make executable: `chmod +x .git/hooks/pre-commit`

## Quality Check Script

**scripts/check-quality.sh**:

```bash
#!/bin/bash
set -euo pipefail

printf "=== Shell Script Quality Check ===\n\n"

# ShellCheck
printf "🔍 Running ShellCheck...\n"
find scripts hooks tests -name "*.sh" -exec shellcheck {} + && \
printf "✅ ShellCheck: PASSED\n\n" || exit 1

# BATS
printf "🧪 Running BATS tests...\n"
bats tests/ && \
printf "✅ BATS: PASSED\n\n" || exit 1

# Permissions
printf "🔐 Checking permissions...\n"
find scripts hooks -name "*.sh" ! -perm -111 | \
while read -r file; do
    printf "⚠️  Not executable: %s\n" "$file"
done

printf "\n🎉 All quality checks PASSED!\n"
```

## Multi-Stage Pipelines

### Fast Lint (PR check)
```yaml
lint-fast:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - uses: ludeeus/action-shellcheck@master
      with:
        scandir: 'scripts/'
```

### Full Test Suite (Main branch)
```yaml
full-test:
  if: github.ref == 'refs/heads/main'
  needs: lint-fast
  steps:
    - uses: actions/checkout@v4
    - run: sudo apt-get install -y bats
    - run: bats tests/
```

## Cache Optimization

```yaml
- name: Cache BATS
  uses: actions/cache@v4
  with:
    path: ~/.bats
    key: bats-${{ hashFiles('tests/**/*.bats') }}
```

## Quality Gates

```yaml
quality-gate:
  needs: [lint, test]
  if: always()
  steps:
    - name: Check Results
      run: |
        if [[ "${{ needs.lint.result }}" != 'success' || \
              "${{ needs.test.result }}" != 'success' ]]; then
          echo '❌ Quality gate failed'
          exit 1
        fi
        echo '✅ All checks passed'
```

## VS Code Devcontainer

**.devcontainer/devcontainer.json**:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/shellcheck:1": {},
    "ghcr.io/devcontainers/features/bats-core:1": {}
  },
  "postCreateCommand": "chmod +x scripts/check-quality.sh"
}
```
