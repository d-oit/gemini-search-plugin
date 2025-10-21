#!/bin/bash
set -euo pipefail

# Release preparation script
# Usage: bash scripts/prepare-release.sh <version>

VERSION="$1"

if [ -z "$VERSION" ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 1.2.1"
    exit 1
fi

# Validate version format (semver)
if ! echo "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo "Error: Invalid version format. Use semantic versioning (e.g., 1.2.1)"
    exit 1
fi

echo "Preparing release v$VERSION..."

# Update plugin.json
echo "Updating plugin.json..."
jq ".version = \"$VERSION\"" plugin.json > plugin.json.tmp
mv plugin.json.tmp plugin.json

# Update marketplace.json
echo "Updating .claude-plugin/marketplace.json..."
jq ".plugins[0].version = \"$VERSION\"" .claude-plugin/marketplace.json > .claude-plugin/marketplace.json.tmp
mv .claude-plugin/marketplace.json.tmp .claude-plugin/marketplace.json

# Update CHANGES.md with release date if entry exists
if [ -f CHANGES.md ]; then
    echo "Updating CHANGES.md with release date..."
    TODAY=$(date '+%Y-%m-%d')
    if grep -q "## \[$VERSION\] - Unreleased" CHANGES.md; then
        sed -i "s/## \[$VERSION\] - Unreleased/## [$VERSION] - $TODAY/" CHANGES.md
    elif ! grep -q "## \[$VERSION\]" CHANGES.md; then
        echo "Warning: No entry for version $VERSION found in CHANGES.md"
        echo "Please add release notes manually"
    fi
fi

echo ""
echo "✓ Version updated to $VERSION in:"
echo "  - plugin.json"
echo "  - .claude-plugin/marketplace.json"
echo "  - CHANGES.md (if applicable)"
echo ""
echo "Next steps:"
echo "  1. Review the changes"
echo "  2. Commit: git add -A && git commit -m 'chore: prepare release v$VERSION'"
echo "  3. Tag: git tag -a v$VERSION -m 'Release v$VERSION'"
echo "  4. Push: git push origin main && git push origin v$VERSION"
