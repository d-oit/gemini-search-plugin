# Claude Code Skills for Plugin Development

This directory contains skills that enhance Claude's capabilities for developing, testing, and managing Claude Code plugins.

## Available Skills

### 1. plugin-creator (Project Skill)

**Purpose**: Comprehensive guidance for creating Claude Code plugins

**Use when**:
- Building a new Claude Code plugin
- Understanding plugin structure and architecture
- Setting up commands, agents, hooks, and scripts
- Configuring plugin.json and marketplace.json
- Following best practices and conventions

**Key features**:
- Step-by-step plugin creation guide
- Complete examples and templates
- Best practices for all plugin components
- Testing and validation guidance
- Marketplace publishing workflow

### 2. shell-script-quality (Project Skill)

**Purpose**: Lint and test shell scripts with ShellCheck and BATS

**Use when**:
- Working with bash/sh scripts
- Setting up linting and testing
- Configuring CI/CD for shell scripts
- Following shell script best practices
- Adding pre-commit hooks

**Key features**:
- ShellCheck configuration and usage
- BATS test framework setup
- Complete testing workflow
- CI/CD integration patterns
- Pre-commit hook examples

### 3. github-repo-management (Project Skill)

**Purpose**: Manage GitHub repositories for Claude Code plugins

**Use when**:
- Setting up GitHub repository
- Configuring issues and pull requests
- Creating release workflows
- Setting up CI/CD with GitHub Actions
- Managing repository settings and permissions

**Key features**:
- Issue and PR templates
- GitHub Actions workflows
- Release automation
- Branch protection configuration
- GitHub CLI commands

### 4. web-research (Project Skill)

**Purpose**: Research web content using gemini-search agent

**Use when**:
- Need to research documentation
- Looking for best practices
- Troubleshooting errors
- Learning about tools/frameworks
- Comparing approaches

**Key features**:
- Token-efficient searches (30-40% savings)
- Smart caching (1-hour TTL)
- Context isolation via agent
- Analytics tracking
- Structured research patterns

## How Skills Work

Skills are **model-invoked** - Claude automatically determines when to use them based on:
- The skill's `description` in YAML frontmatter
- The current task context
- The user's request

Unlike slash commands (user-invoked), skills activate automatically to provide expertise when needed.

## Skill Structure

Each skill consists of:
```
skill-name/
├── SKILL.md       # Main skill file with YAML frontmatter and instructions
├── README.md      # Documentation and quick reference
└── resources/     # Optional supporting files
```

## Token Efficiency

### web-research Skill

The **web-research** skill provides significant token savings:
- **30-40% reduction** through context isolation
- **Caching** prevents redundant API calls
- **Structured output** focuses on relevant information

**Example**: Researching documentation without web-research might use 10,000 tokens in main context. With web-research, the agent handles search in isolation and returns only essential results, using ~6,000 tokens total.

**Check savings**:
```bash
/gemini-search:search-stats
```

## Skill Integration

Skills work together for a complete workflow:

**Plugin Development Flow**:
1. **plugin-creator** → Structure and create plugin
2. **web-research** → Research best practices and examples
3. **shell-script-quality** → Set up linting and testing
4. **github-repo-management** → Configure repository and CI/CD

**Example workflow**:
```
User: "Create a new Claude Code plugin for JSON validation"

Claude uses:
1. plugin-creator: Guide plugin structure
2. web-research: Research JSON validation tools and best practices
3. shell-script-quality: Set up ShellCheck for scripts
4. github-repo-management: Create GitHub workflows for CI/CD
```

## Using Skills

### As a User

You don't need to invoke skills manually. Claude uses them automatically when appropriate.

**Example**:
```
You: "How do I set up a GitHub Actions workflow for my plugin?"

Claude automatically uses github-repo-management skill
```

### As a Developer

When working on skills or understanding their behavior:

1. **Review SKILL.md** for complete documentation
2. **Check README.md** for quick reference
3. **Test with examples** from the skill documentation
4. **Monitor analytics** (for web-research skill)

## Skill Configuration

### web-research Configuration

```bash
# Adjust cache TTL (seconds)
export GEMINI_SEARCH_CACHE_TTL=3600  # 1 hour default

# Change cache location
export GEMINI_SEARCH_CACHE_DIR="/tmp/gemini-search-cache"

# Enable debug logging
export DEBUG=true
```

### Tool Restrictions

Some skills restrict available tools for security/safety:

**web-research** restricts to:
- `Task` (to invoke gemini-search agent)
- `Read` (to read local files)
- `Write` (to save research results if needed)

This prevents accidental destructive operations during research.

## Best Practices

### For Skill Usage

1. **Trust the system**: Let Claude decide when to use skills
2. **Be specific**: Provide clear context in your requests
3. **Review results**: Skills provide guidance, but review suggestions
4. **Iterate**: Use skills multiple times as you refine your work

### For Skill Development

1. **Clear descriptions**: Make `description` specific and trigger-aware
2. **Focus**: One skill = one capability area
3. **Examples**: Include concrete examples in documentation
4. **Testing**: Test skills with various request patterns
5. **Integration**: Reference related skills for comprehensive workflows

## Troubleshooting

### Skill Not Activating

**Issue**: Claude doesn't seem to use a skill

**Solutions**:
1. Make request more specific to skill's domain
2. Check skill description matches your use case
3. Verify SKILL.md has valid YAML frontmatter
4. Review skill's "When to Use" section

### web-research Issues

**Issue**: Search results not relevant

**Solutions**:
1. Make queries more specific
2. Include source constraints (e.g., site:docs.github.com)
3. Clear cache: `/gemini-search:clear-cache`
4. Check Gemini API key configuration

**Issue**: Token savings not showing

**Solutions**:
1. Check analytics: `/gemini-search:search-stats`
2. Ensure using agent (not direct WebFetch)
3. Verify cache is working (check cache directory)

## Resources

### Official Documentation

- **Claude Code Docs**: https://docs.claude.com/en/docs/claude-code
- **Skills Guide**: https://docs.claude.com/en/docs/claude-code/skills
- **Plugin Development**: https://docs.claude.com/en/docs/claude-code/plugins

### GitHub Resources

- **Example Skills**: https://github.com/anthropics/skills
- **Awesome Claude Code**: https://github.com/hesreallyhim/awesome-claude-code

### Internal Resources

- **Commands**: `.claude/commands/`
- **Agents**: `.claude/agents/`
- **Hooks**: `hooks/`

## Analytics

### web-research Analytics

View search analytics:
```bash
/gemini-search:search-stats
```

**Metrics tracked**:
- Total searches performed
- Cache hit rate (percentage)
- Estimated token savings
- Top queries
- Search patterns

### Interpreting Results

**High cache hit rate (>50%)**:
- Good: Efficient use of caching
- Consider: Increasing cache TTL if frequently reusing results

**Low cache hit rate (<20%)**:
- Normal for diverse queries
- Each query is unique and needs fresh results

**Token savings**:
- Shows estimated tokens saved via context isolation
- Compare against baseline (searches without agent)

## Contributing

When adding or modifying skills:

1. Follow SKILL.md format with YAML frontmatter
2. Include comprehensive "When to Use" section
3. Provide concrete examples
4. Document integration with other skills
5. Create README.md for quick reference
6. Test with various request patterns
7. Update this main README.md

## Version Information

**Last updated**: 2025-01-21

**Skills version**:
- plugin-creator: 1.0
- shell-script-quality: 1.0
- github-repo-management: 1.0
- web-research: 1.0

**Compatible with**:
- Claude Code: 1.0+
- gemini-search plugin: 0.1.0+

## Next Steps

1. **Explore each skill**: Review SKILL.md files for detailed guidance
2. **Try examples**: Use examples from skill documentation
3. **Monitor usage**: Check analytics for web-research skill
4. **Provide feedback**: Report issues or suggest improvements
5. **Contribute**: Add new skills or enhance existing ones
