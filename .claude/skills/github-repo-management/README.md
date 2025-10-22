# GitHub Repository Management Skill

Comprehensive skill for managing GitHub repositories that host Claude Code plugins, including issue tracking, pull request workflows, release management, and CI/CD automation.

## Features

- **Issue Management**: Templates, labels, and workflows for tracking bugs and features
- **Pull Request Workflows**: PR templates, automated checks, and review processes
- **Release Management**: Semantic versioning, changelog management, and automated releases
- **CI/CD with GitHub Actions**: Workflow setup for testing, linting, and deployment
- **GitHub Packages**: Publishing and distributing plugins via GitHub Packages
- **Project Management**: Projects, milestones, and GitHub Discussions

## When to Use

This skill is automatically invoked when you:
- Create or manage GitHub issues
- Set up pull request workflows
- Configure GitHub Actions CI/CD
- Manage releases and versioning
- Set up repository settings and branch protection
- Use GitHub CLI for repository operations

## Key Topics Covered

- Issue templates and label organization
- PR checks (title format, size, CHANGES.md updates, conflicts)
- Semantic versioning and changelog maintenance
- Release automation with tag-triggered workflows
- CI workflows (ShellCheck, JSON validation, testing, security scanning)
- Branch protection rules and code owners
- GitHub CLI commands for issues, PRs, and releases

## Related Skills

- **plugin-creator**: For overall plugin development guidance
- **shell-script-quality**: For CI/CD integration with ShellCheck and BATS
- **web-research**: For researching GitHub best practices and examples

## Quick Reference

```bash
# Issues
gh issue list
gh issue create --title "Bug: issue description"

# Pull Requests
gh pr create --title "feat: new feature"
gh pr merge --squash

# Releases
git tag -a v0.2.0 -m "Release v0.2.0"
git push origin v0.2.0
```

See SKILL.md for complete documentation.
