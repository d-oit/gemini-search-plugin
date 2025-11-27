# Configuration Reference

Complete configuration guide for shell script quality tools.

## ShellCheck Configuration

### .shellcheckrc

Create `.shellcheckrc` in project root:

```bash
# Shell dialect
shell=bash

# Enable all optional checks
enable=all

# Disable specific warnings
# SC1090: Can't follow non-constant source
# SC2034: Variable appears unused (for exports)
disable=SC1090,SC2034

# Additional source paths
source-path=SCRIPTDIR:./lib:./scripts

# External sources (for libraries)
external-sources=true
```

### Severity Levels

```bash
# Only show errors
shellcheck --severity=error script.sh

# Show warnings and errors
shellcheck --severity=warning script.sh

# Show everything (default)
shellcheck --severity=style script.sh
```

### Per-Project Configs

**Strict Mode**:
```bash
cat > .shellcheckrc <<'EOF'
shell=bash
enable=all
severity=error
EOF
```

**Relaxed Mode**:
```bash
cat > .shellcheckrc <<'EOF'
shell=bash
disable=SC1090,SC2034,SC2086,SC2155
EOF
```

## Editor Integration

### VS Code

**.vscode/settings.json**:
```json
{
  "shellcheck.enable": true,
  "shellcheck.executablePath": "shellcheck",
  "shellcheck.run": "onType",
  "shellcheck.exclude": ["SC1090"],
  "files.associations": {
    "*.sh": "shellscript",
    ".shellcheckrc": "properties"
  }
}
```

Install extension:
```bash
code --install-extension timonwong.shellcheck
```

### Vim/Neovim

**Using ALE**:
```vim
let g:ale_linters = {'sh': ['shellcheck']}
let g:ale_sh_shellcheck_options = '-x'
```

**Using Syntastic**:
```vim
let g:syntastic_sh_shellcheck_args = '-x'
```

### Emacs

**Flycheck**:
```elisp
(require 'flycheck)
(add-hook 'sh-mode-hook 'flycheck-mode)
```

### JetBrains IDEs

Install ShellCheck plugin from marketplace:
- Settings → Plugins → Search "ShellCheck"
- Configure: Settings → Tools → ShellCheck

## BATS Configuration

### Installation Methods

**macOS (Homebrew)**:
```bash
brew install bats-core
brew install bats-support bats-assert bats-file
```

**Ubuntu/Debian**:
```bash
sudo apt-get install bats

# Or latest version
git clone https://github.com/bats-core/bats-core.git
cd bats-core
sudo ./install.sh /usr/local
```

**From npm**:
```bash
npm install -g bats
```

### Helper Libraries

```bash
# Install helper libraries
git clone https://github.com/bats-core/bats-support test/test_helper/bats-support
git clone https://github.com/bats-core/bats-assert test/test_helper/bats-assert
git clone https://github.com/bats-core/bats-file test/test_helper/bats-file
```

**Load in tests**:
```bash
load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'
load 'test_helper/bats-file/load'
```

## Environment Setup

### Development Environment

**direnv (.envrc)**:
```bash
export CLAUDE_PLUGIN_ROOT="$(pwd)"
export LOG_LEVEL="DEBUG"
export PATH="$PWD/scripts:$PATH"
```

**bashrc/zshrc**:
```bash
# ShellCheck alias
alias sc='shellcheck'
alias sca='find . -name "*.sh" -exec shellcheck {} +'

# BATS alias
alias bt='bats tests/'
alias btv='bats -t tests/'
```

### Docker Environment

**Dockerfile**:
```dockerfile
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    shellcheck \
    bats \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
COPY . .

CMD ["bash", "scripts/check-quality.sh"]
```

**docker-compose.yml**:
```yaml
version: '3.8'
services:
  quality-check:
    build: .
    volumes:
      - .:/workspace
    command: bash scripts/check-quality.sh
```

## Project Structure

### Recommended Layout

```
project/
├── .shellcheckrc           # ShellCheck config
├── .editorconfig           # Editor config
├── scripts/
│   ├── main.sh
│   ├── utils.sh
│   └── check-quality.sh
├── tests/
│   ├── test_helper/
│   │   ├── common.bash
│   │   ├── bats-support/
│   │   └── bats-assert/
│   ├── main.bats
│   └── utils.bats
├── .github/
│   └── workflows/
│       └── quality.yml
└── .gitignore
```

### .editorconfig

```ini
root = true

[*.sh]
indent_style = space
indent_size = 4
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.bats]
indent_style = space
indent_size = 4
```

### .gitignore

```
# Logs
*.log

# Test artifacts
*.tmp
*.temp
test-results/
coverage/

# OS files
.DS_Store
Thumbs.db
```

## CI/CD Tool Versions

### GitHub Actions

```yaml
- name: Install specific versions
  run: |
    # ShellCheck latest
    wget -qO- "https://github.com/koalaman/shellcheck/releases/download/stable/shellcheck-stable.linux.x86_64.tar.xz" | tar -xJv
    sudo cp "shellcheck-stable/shellcheck" /usr/bin/
    
    # BATS latest
    git clone --depth 1 https://github.com/bats-core/bats-core.git
    sudo bats-core/install.sh /usr/local
```

### Version Pinning

```yaml
- uses: ludeeus/action-shellcheck@2.0.0
  with:
    version: v0.9.0
```

## Environment Variables

### ShellCheck

```bash
# Custom config location
export SHELLCHECK_OPTS="-x -a"

# Ignore specific codes
export SHELLCHECK_OPTS="-e SC2086,SC2181"
```

### BATS

```bash
# Test timeout
export BATS_TEST_TIMEOUT=30

# Formatter
export BATS_FORMATTER="tap"
```

## Quick Setup Script

**setup-quality-tools.sh**:
```bash
#!/bin/bash
set -euo pipefail

echo "Setting up shell script quality tools..."

# Create directories
mkdir -p tests/test_helper scripts

# Create .shellcheckrc
cat > .shellcheckrc <<'EOF'
shell=bash
enable=all
disable=SC1090
source-path=SCRIPTDIR
EOF

# Create basic test helper
cat > tests/test_helper/common.bash <<'EOF'
setup_test_env() {
    export TEST_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
    export TEST_TEMP_DIR="$(mktemp -d)"
}
EOF

# Install tools (macOS)
if command -v brew >/dev/null; then
    brew install shellcheck bats-core
fi

echo "✅ Setup complete!"
```
