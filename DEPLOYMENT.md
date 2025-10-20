# Deployment Guide

This document outlines the complete setup for testing, regression prevention, and release management for the Gemini Search Plugin.

## Repository Information

- **GitHub Repository**: https://github.com/do-ops885/gemini-search-plugin
- **Installation Command**: `/plugin add https://github.com/do-ops885/gemini-search-plugin`

## Best Practices Implemented

### 1. Security

#### SECURITY.md
- Vulnerability reporting process
- Security best practices for users and contributors
- Contact information for security issues
- List of supported versions

#### Key Security Features
- Content size limits (100KB default)
- URL validation
- Timeout protection (15s default)
- No direct web scraping
- Error message sanitization
- Tool restriction via `.gemini/settings.json`

### 2. Contributing Guidelines

#### CONTRIBUTING.md
- Development workflow
- Branch naming conventions
- Testing requirements
- Coding standards (bash, JSON, markdown)
- Pull request process
- Release process

### 3. Repository Configuration

#### Branch Protection (main)
- ✅ Require pull request reviews (1 approval)
- ✅ Dismiss stale reviews
- ✅ Require linear history
- ✅ Block force pushes
- ✅ Block branch deletion
- ✅ Require status checks (when available)

#### Repository Settings
- ✅ Issues enabled
- ✅ Wiki disabled
- ✅ Projects disabled
- ✅ Topics: claude-code, plugin, gemini, search, web-search

## Testing Framework

### Integration Tests

Located in `tests/run-integration-tests.sh`:

```bash
# Run all integration tests
bash tests/run-integration-tests.sh
```

**Test Coverage:**
1. JSON validation (plugin.json, marketplace.json, hooks.json)
2. Script permissions verification
3. Analytics initialization
4. Analytics tracking accuracy
5. Cache operations
6. Cache statistics
7. Error logging
8. Analytics report generation
9. Cache clearing functionality
10. Environment variable validation

### Manual Testing

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

### Linting

```bash
# ShellCheck for bash scripts
shellcheck scripts/*.sh hooks/*.sh

# JSON validation
jq empty .claude-plugin/plugin.json
jq empty .claude-plugin/marketplace.json
jq empty hooks/hooks.json
```

## CI/CD Workflows

### 1. CI Workflow (`.github/workflows/ci.yml`)

**Triggers**: Push/PR to main or develop branches

**Jobs:**
- ShellCheck linting (scripts and hooks)
- JSON validation (all config files)
- Integration tests (requires GEMINI_API_KEY secret)
- Security scanning (Trivy)
- Markdown linting

### 2. PR Checks (`.github/workflows/pr-checks.yml`)

**Triggers**: Pull request opened/updated

**Jobs:**
- PR title format validation (semantic commits)
- PR size labeling (XS/S/M/L/XL)
- CHANGES.md update reminder
- Merge conflict detection

### 3. Release Workflow (`.github/workflows/release.yml`)

**Triggers**: Push tag matching `v*.*.*`

**Jobs:**
- Version validation (plugin.json, marketplace.json match tag)
- GitHub release creation with changelog
- Release archive generation
- Asset upload
- Post-release notifications

## Regression Prevention

### Automated Safeguards

1. **Required Status Checks**
   - All CI checks must pass before merge
   - ShellCheck ensures script quality
   - JSON validation prevents config errors

2. **Code Review**
   - Minimum 1 approval required
   - Stale reviews dismissed on new commits

3. **Linear History**
   - Forces rebasing, prevents merge commits
   - Keeps history clean and traceable

4. **Version Validation**
   - Release workflow validates version consistency
   - Prevents mismatched versions across files

### Test-Driven Development

- Add tests for new features
- Regression tests for bug fixes
- Integration tests run on every commit
- Manual testing checklist in CONTRIBUTING.md

## Release Process

### Semantic Versioning

- **MAJOR** (X.0.0) - Breaking changes
- **MINOR** (1.X.0) - New features, backward compatible
- **PATCH** (1.2.X) - Bug fixes, backward compatible

### Step-by-Step Release

#### 1. Prepare Release

```bash
# Use the automated script
bash scripts/prepare-release.sh 1.2.1

# This updates:
# - .claude-plugin/plugin.json
# - .claude-plugin/marketplace.json
# - CHANGES.md (adds release date)
```

#### 2. Create Release Branch

```bash
git checkout -b release/v1.2.1
git add -A
git commit -m "chore: prepare release v1.2.1"
git push origin release/v1.2.1
```

#### 3. Create Pull Request

- Open PR from `release/v1.2.1` to `main`
- Ensure all CI checks pass
- Get required approvals
- Merge the PR

#### 4. Tag and Push

```bash
git checkout main
git pull origin main
git tag -a v1.2.1 -m "Release v1.2.1"
git push origin v1.2.1
```

#### 5. GitHub Actions Automation

The release workflow automatically:
- ✅ Validates version consistency
- ✅ Extracts changelog from CHANGES.md
- ✅ Creates GitHub release
- ✅ Generates release notes
- ✅ Creates and uploads release archive
- ✅ Publishes release

### Release Checklist

Before creating a release:

- [ ] All tests pass locally
- [ ] CHANGES.md updated with changes
- [ ] Version bumped in all required files
- [ ] Documentation updated (if needed)
- [ ] Breaking changes documented
- [ ] Security implications reviewed
- [ ] Migration guide provided (if breaking)

## Issue and PR Templates

### Issue Templates

Located in `.github/ISSUE_TEMPLATE/`:

1. **Bug Report** (`bug_report.md`)
   - Environment details
   - Reproduction steps
   - Expected vs actual behavior
   - Log file requirements

2. **Feature Request** (`feature_request.md`)
   - Problem statement
   - Proposed solution
   - Use cases
   - Implementation ideas

### Pull Request Template

Located in `.github/PULL_REQUEST_TEMPLATE.md`:

- Change description and type
- Testing performed
- Documentation updates
- Security considerations
- Breaking changes
- Reviewer guidance

## Monitoring and Analytics

### Metrics Tracked

1. **Search Operations**
   - Total searches
   - Search engine distribution
   - Top queries

2. **Cache Performance**
   - Cache hit rate
   - Cache miss rate
   - Token savings estimate (39% per hit)

3. **Error Tracking**
   - Error types and frequencies
   - Retry attempts
   - Failure reasons

### Viewing Analytics

```bash
# View comprehensive report
bash scripts/analytics.sh report

# Validate analytics data
bash scripts/analytics.sh validate

# Reset analytics
bash scripts/analytics.sh reset
```

## Troubleshooting

### CI Failures

1. **ShellCheck Errors**
   ```bash
   shellcheck scripts/*.sh hooks/*.sh
   ```

2. **JSON Validation Errors**
   ```bash
   jq empty <file.json
   ```

3. **Integration Test Failures**
   - Check `/tmp/gemini-test-results.log`
   - Verify Gemini CLI installed
   - Ensure API key configured

### Release Issues

1. **Version Mismatch**
   - Ensure all files have same version
   - Use `scripts/prepare-release.sh` script

2. **Missing Changelog Entry**
   - Add entry to CHANGES.md
   - Follow existing format

3. **Tag Already Exists**
   ```bash
   git tag -d v1.2.1  # Delete local
   git push --delete origin v1.2.1  # Delete remote
   ```

## Security Secrets

### Required Secrets (GitHub Actions)

1. **GEMINI_API_KEY**
   - Required for integration tests
   - Add in: Settings → Secrets → Actions
   - Scope: Repository secrets

### Secret Management

- Never commit secrets to repository
- Use GitHub Secrets for CI/CD
- Rotate API keys regularly
- Review `.gitignore` before commits

## Maintenance

### Regular Tasks

- [ ] Review and update dependencies
- [ ] Check for security advisories
- [ ] Update documentation
- [ ] Respond to issues and PRs
- [ ] Monitor CI/CD pipeline health

### Quarterly Reviews

- [ ] Audit security practices
- [ ] Review analytics trends
- [ ] Update roadmap
- [ ] Performance optimization
- [ ] Dependency updates

## Support

- **Issues**: https://github.com/do-ops885/gemini-search-plugin/issues
- **Security**: do-tester@proton.me
- **Documentation**: README.md, CONTRIBUTING.md

## Additional Resources

- [Claude Code Plugins Documentation](https://docs.claude.com/en/docs/claude-code/plugins)
- [Semantic Versioning](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
