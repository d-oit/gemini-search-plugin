# Marketplace Best Practices

This document outlines best practices for publishing and sharing the Gemini Search Plugin through Claude Code marketplaces.

## Table of Contents

- [Publishing to Marketplaces](#publishing-to-marketplaces)
- [Hosting Strategies](#hosting-strategies)
- [Team Distribution](#team-distribution)
- [Versioning and Updates](#versioning-and-updates)
- [Community Engagement](#community-engagement)
- [Documentation Standards](#documentation-standards)
- [Security Considerations](#security-considerations)

## Publishing to Marketplaces

### GitHub-Based Marketplace (Recommended)

The plugin is already published as a GitHub repository marketplace:

**Installation Command:**
```bash
/plugin add https://github.com/do-ops885/gemini-search-plugin
```

**Benefits:**
- ✅ Built-in version control
- ✅ Issue tracking
- ✅ Pull request workflow
- ✅ GitHub Actions automation
- ✅ Release management
- ✅ Community collaboration

### Marketplace Manifest

The plugin includes two marketplace manifests:

1. **Production Marketplace** (`.claude-plugin/marketplace.json`)
   - For public distribution
   - Points to GitHub repository
   - Used by end users

2. **Test Marketplace** (`.claude/test-marketplace.json`)
   - For local development
   - Points to local directory
   - Used by plugin developers

## Hosting Strategies

### Strategy 1: GitHub Public Repository (Current)

**Best for:** Open-source plugins, community collaboration

**Setup:**
- Repository: https://github.com/do-ops885/gemini-search-plugin
- Default branch: `main`
- License: MIT
- Branch protection enabled

**Installation:**
```bash
/plugin add https://github.com/do-ops885/gemini-search-plugin
```

### Strategy 2: Private GitHub Repository

**Best for:** Internal team tools, proprietary plugins

**Setup:**
1. Create private repository
2. Add team members as collaborators
3. Use same marketplace structure

**Installation:**
```bash
/plugin add https://github.com/your-org/private-plugin
```

Team members need repository access.

### Strategy 3: Git Hosting Service (GitLab, Bitbucket)

**Best for:** Organizations using alternative git platforms

**Setup:**
1. Host plugin on your git service
2. Ensure repository is accessible
3. Use git URL in marketplace

**Installation:**
```bash
/plugin add https://gitlab.com/your-org/plugin.git
```

### Strategy 4: Custom Marketplace

**Best for:** Multiple plugins, centralized management

**Setup:**
Create a marketplace repository with `marketplace.json`:

```json
{
  "name": "your-marketplace",
  "owner": {
    "name": "Your Organization",
    "email": "plugins@yourorg.com"
  },
  "plugins": [
    {
      "name": "gemini-search",
      "source": {
        "type": "github",
        "repo": "do-ops885/gemini-search-plugin"
      },
      "category": "productivity"
    },
    {
      "name": "another-plugin",
      "source": {
        "type": "github",
        "repo": "your-org/another-plugin"
      },
      "category": "development"
    }
  ]
}
```

**Installation:**
```bash
/plugin marketplace add https://github.com/your-org/marketplace
/plugin add gemini-search@your-marketplace
```

## Team Distribution

### Repository-Level Configuration

Configure plugins at the repository level for consistent team tooling.

**Create `.claude/settings.json` in your project:**

```json
{
  "extraKnownMarketplaces": {
    "team-plugins": {
      "source": {
        "source": "github",
        "repo": "your-org/marketplace"
      }
    }
  },
  "plugins": [
    {
      "name": "gemini-search",
      "source": "team-plugins"
    }
  ]
}
```

**Team Workflow:**
1. Team member clones repository
2. Opens folder in Claude Code
3. Prompted to trust folder
4. Marketplace and plugins auto-install
5. Consistent tooling for everyone

### Benefits

- ✅ Automatic plugin installation
- ✅ Version consistency across team
- ✅ No manual setup required
- ✅ Trust boundary respected
- ✅ Explicit user consent

## Versioning and Updates

### Semantic Versioning

Follow semantic versioning (SemVer):

- **MAJOR** (1.0.0) - Breaking changes
- **MINOR** (0.1.0) - New features, backward compatible
- **PATCH** (0.0.1) - Bug fixes, backward compatible

### Release Process

1. **Update version** in all files:
   ```bash
   bash scripts/prepare-release.sh 0.2.0
   ```

2. **Update CHANGES.md** with release notes

3. **Create release:**
   ```bash
   git add -A
   git commit -m "chore: prepare release v0.2.0"
   git tag -a v0.2.0 -m "Release v0.2.0"
   git push origin main && git push origin v0.2.0
   ```

4. **GitHub Actions automatically:**
   - Creates GitHub release
   - Generates changelog
   - Publishes package assets

### Update Notifications

Users are notified of updates through:
- GitHub release notifications (if watching repository)
- Marketplace refresh (`/plugin update`)

### Deprecation Policy

If deprecating features:

1. **Announce** in CHANGES.md with deprecation timeline
2. **Add warnings** in plugin output
3. **Maintain** for at least one major version
4. **Remove** in next major version
5. **Document** migration path

## Community Engagement

### GitHub Features

**Enable and use:**
- ✅ Issues - For bug reports and feature requests
- ✅ Discussions - For questions and community chat
- ✅ Releases - For version announcements
- ✅ Wiki - For extended documentation (optional)

**Configure:**
- Issue templates (already configured)
- PR templates (already configured)
- Labels for categorization
- Milestones for roadmap

### Responding to Issues

**Best practices:**
- Respond within 48 hours
- Use labels to categorize
- Link to relevant documentation
- Close with clear resolution

### Accepting Contributions

**Guidelines in CONTRIBUTING.md:**
- How to submit PRs
- Code style requirements
- Testing requirements
- Review process

### Building Community

1. **Star and watch** encourage users to do so
2. **Changelog** clear and detailed
3. **Roadmap** share future plans
4. **Credits** acknowledge contributors
5. **Examples** provide usage examples

## Documentation Standards

### Required Files

- ✅ **README.md** - Overview, features, installation
- ✅ **CHANGES.md** - Version history
- ✅ **CONTRIBUTING.md** - Contribution guidelines
- ✅ **SECURITY.md** - Security policy
- ✅ **LICENSE** - MIT license
- ✅ **TESTING.md** - Local testing guide
- ✅ **DEPLOYMENT.md** - Release procedures

### README Best Practices

**Must include:**
1. **Clear title and description**
2. **Installation instructions**
3. **Quick start guide**
4. **Command reference**
5. **Configuration options**
6. **Examples**
7. **Troubleshooting**
8. **Links to other docs**

**Use:**
- Clear headings
- Code examples with syntax highlighting
- Screenshots/GIFs for visual features
- Badges for build status, version, license

### Command Documentation

For each command, document:

**Format:**
```markdown
### `/command [arguments]`

**Description:** What the command does

**Arguments:**
- `arg1` - Description of argument

**Examples:**
\`\`\`bash
/command example
\`\`\`

**Output:** What users should expect

**Notes:** Additional information
```

### Configuration Documentation

For each environment variable:

**Format:**
```markdown
- `ENV_VAR` - Description (default: value)
```

**Example:**
```markdown
- `CACHE_TTL` - Cache time-to-live in seconds (default: 3600)
```

## Security Considerations

### Marketplace Security

**Trust boundaries:**
- Users must explicitly trust folders
- Marketplaces require user consent
- Plugins need user approval

**Best practices:**
1. **Sign commits** with GPG
2. **Enable branch protection**
3. **Require code review**
4. **Use secret scanning**
5. **Run security audits**

### Plugin Security

**Implemented:**
- ✅ Content size limits
- ✅ URL validation
- ✅ Timeout protection
- ✅ Error sanitization
- ✅ No hardcoded secrets

**Review:**
- Input validation
- External command execution
- File system access
- Network requests
- User data handling

### SECURITY.md

Maintain comprehensive security documentation:

- Vulnerability reporting process
- Security best practices
- Known limitations
- Contact information

### Dependency Security

**Monitor:**
- Gemini CLI updates
- Bash vulnerabilities
- Third-party tools (jq, etc.)

**Process:**
1. Subscribe to security advisories
2. Test updates before deploying
3. Document security fixes in CHANGES.md

## Marketplace Metadata

### Categories

Choose appropriate category:
- `productivity` - Tools that enhance productivity
- `development` - Development tools
- `testing` - Testing and QA tools
- `documentation` - Documentation tools
- `integration` - External integrations

**Gemini Search:** `productivity`

### Tags/Keywords

**Effective keywords:**
- Primary function: `search`, `web-search`
- Technology: `gemini`, `google-search`
- Platform: `claude-code`, `plugin`
- Features: `caching`, `analytics`

**Current keywords:**
```json
["search", "web-search", "gemini", "google-search", "caching", "analytics", "content-extraction", "grounded-search"]
```

### Description

**Guidelines:**
- Clear and concise (1-2 sentences)
- Mention key technology (Gemini CLI)
- Highlight main features
- Include unique selling points

**Current description:**
> Advanced web search plugin using the Gemini CLI in headless mode with google_web_search tool restriction, providing caching, analytics, content extraction, and validation for Claude Code

## Promotion

### GitHub Topics

**Applied topics:**
- claude-code
- plugin
- gemini
- search
- web-search

### README Badge

Add badge to README:
```markdown
[![Install Plugin](https://img.shields.io/badge/Install-Plugin-blue)](https://github.com/do-ops885/gemini-search-plugin)
```

### Community Sharing

**Share on:**
- Claude Code community forums
- Reddit (r/claudeai, relevant subreddits)
- Twitter/X with #ClaudeCode hashtag
- Developer communities
- Team Slack/Discord channels

### Blog Post

Consider writing:
- Overview of plugin features
- Use cases and examples
- Development journey
- Tips and tricks

## Maintenance

### Regular Tasks

**Weekly:**
- Review and respond to issues
- Monitor CI/CD pipeline

**Monthly:**
- Update dependencies
- Review security advisories
- Check for Gemini CLI updates

**Quarterly:**
- Audit documentation
- Review analytics trends
- Plan new features
- Performance optimization

### Community Health

Track metrics:
- Stars and forks
- Issue response time
- PR merge rate
- Active contributors
- Download statistics

### Long-term Support

**Commitment:**
- Maintain for at least 1 year
- Security patches for current version
- Bug fixes for current version
- New features in minor versions

**End-of-life:**
- Announce 6 months in advance
- Archive repository clearly
- Suggest alternatives

## Resources

### Official Documentation

- [Claude Code Plugins](https://docs.claude.com/en/docs/claude-code/plugins)
- [Plugin Marketplaces](https://docs.claude.com/en/docs/claude-code/plugin-marketplaces)
- [Plugins Reference](https://docs.claude.com/en/docs/claude-code/plugins-reference)

### Community

- [GitHub Discussions](https://github.com/do-ops885/gemini-search-plugin/discussions) (when enabled)
- [Issue Tracker](https://github.com/do-ops885/gemini-search-plugin/issues)

### Development

- [CONTRIBUTING.md](./CONTRIBUTING.md)
- [TESTING.md](./TESTING.md)
- [DEPLOYMENT.md](./DEPLOYMENT.md)
