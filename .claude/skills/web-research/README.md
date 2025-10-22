# Web Research Skill

Token-efficient web research using the gemini-search agent with caching and context isolation for 30-40% token savings.

## Features

- **Context Isolation**: Searches run in isolated agent context (30-40% token savings)
- **Smart Caching**: 1-hour cache TTL (configurable) to avoid redundant searches
- **Analytics Tracking**: Monitor cache hits, token savings, and query patterns
- **Structured Research**: Pre-defined patterns for common research tasks

## When to Use

This skill is automatically invoked when you need to:
- Research official documentation
- Find best practices and examples
- Troubleshoot errors or issues
- Learn about tools and frameworks
- Compare approaches or technologies

## Research Patterns

1. **Documentation Research**: Find official docs and specifications
2. **Best Practices**: Discover current industry standards
3. **Troubleshooting**: Research error solutions and fixes
4. **Tool Research**: Learn about frameworks and libraries
5. **Comparative Analysis**: Compare different approaches

## How It Works

Uses the gemini-search agent via Task tool:
- `subagent_type: "gemini-search:gemini-search"`
- Isolated context prevents token bloat
- Results cached for repeated queries
- Structured output with sources

## Configuration

```bash
# Cache TTL (default: 3600 seconds)
export GEMINI_SEARCH_CACHE_TTL=3600

# Cache directory
export GEMINI_SEARCH_CACHE_DIR="/tmp/gemini-search-cache"
```

## Commands

```bash
# View analytics
/gemini-search:search-stats

# Clear cache
/gemini-search:clear-cache

# Direct search
/gemini-search:search "your query here"
```

## Token Savings

The web-research skill saves tokens by:
- Running searches in isolated agent context
- Caching results for reuse
- Returning only structured, relevant information
- Avoiding redundant web fetches

**Average savings**: 30-40% on research-heavy tasks

## Related Skills

- **plugin-creator**: Research plugin development best practices
- **shell-script-quality**: Research ShellCheck and BATS examples
- **github-repo-management**: Research GitHub Actions and CI/CD patterns

See SKILL.md for complete documentation.
