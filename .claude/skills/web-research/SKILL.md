---
name: web-research
description: Research web content, documentation, and best practices using the gemini-search agent for token-efficient searches with caching. Use when you need to fetch documentation, research best practices, or gather information from the web.
allowed-tools: Task, Read, Write
---

# Web Research with Gemini Search

This skill enables efficient web research using the gemini-search agent, which provides context isolation for 30-40% token savings and includes built-in caching to avoid redundant searches.

## When to Use This Skill

Invoke this skill when you need to:
- Research documentation from official sources
- Gather best practices and examples
- Find current information about tools, libraries, or frameworks
- Research GitHub workflows, CI/CD patterns
- Look up API documentation
- Find examples of code patterns
- Research security best practices
- Gather information about error messages or issues

## How It Works

This skill uses the **gemini-search agent** (available in this plugin) which:
- Performs web searches in an isolated context (saves 30-40% tokens)
- Caches results for 1 hour (configurable via `GEMINI_SEARCH_CACHE_TTL`)
- Tracks analytics (cache hits, query patterns, token savings)
- Provides structured, relevant results

## Research Patterns

### 1. Documentation Research

When you need to research official documentation:

```
Use the Task tool with subagent_type="gemini-search:gemini-search" to search for:
- "Claude Code skills documentation"
- "GitHub Actions workflow syntax"
- "ShellCheck best practices 2025"
- "Semantic versioning specification"
```

**Example prompt for agent:**
```
Search the web for comprehensive documentation about [topic]. Focus on:
1. Official documentation sources
2. Best practices and recommendations
3. Current (2025) standards and patterns
4. Practical examples and use cases

Please provide a structured summary with key points and source URLs.
```

### 2. Best Practices Research

When researching best practices:

```
Use the Task tool with subagent_type="gemini-search:gemini-search" to search for:
- "bash script best practices 2025"
- "GitHub Actions CI/CD best practices"
- "Claude Code plugin development patterns"
- "Release management workflow"
```

**Example prompt for agent:**
```
Research current best practices for [topic]. Include:
1. Industry-standard approaches
2. Common patterns and conventions
3. Security considerations
4. Performance optimization tips
5. Tools and frameworks commonly used

Provide actionable recommendations with examples.
```

### 3. Troubleshooting and Error Research

When investigating errors or issues:

```
Use the Task tool with subagent_type="gemini-search:gemini-search" to search for:
- "ShellCheck SC2086 fix examples"
- "GitHub Actions workflow not triggering"
- "BATS test framework setup"
- "git tag push not triggering workflow"
```

**Example prompt for agent:**
```
Research solutions for [specific error or issue]. Find:
1. Common causes of this issue
2. Recommended solutions and workarounds
3. Related documentation
4. Working examples

Focus on verified solutions from official docs and reputable sources.
```

### 4. Tool and Framework Research

When learning about tools or frameworks:

```
Use the Task tool with subagent_type="gemini-search:gemini-search" to search for:
- "Gemini CLI features and capabilities"
- "jq JSON processing examples"
- "GitHub CLI pr commands"
- "Trivy security scanner configuration"
```

**Example prompt for agent:**
```
Research [tool/framework name]. Provide:
1. Overview and key features
2. Installation methods
3. Common use cases and examples
4. Configuration options
5. Integration with other tools

Include practical examples and current version info.
```

### 5. Comparative Research

When comparing approaches or tools:

```
Use the Task tool with subagent_type="gemini-search:gemini-search" to search for:
- "GitHub Actions vs GitLab CI comparison"
- "bash vs python for shell scripts"
- "different JSON validation tools"
- "release automation strategies"
```

**Example prompt for agent:**
```
Compare [option A] vs [option B] for [use case]. Include:
1. Key differences and trade-offs
2. Performance considerations
3. Use case recommendations
4. Community adoption and support
5. Integration capabilities

Provide objective comparison with use case recommendations.
```

## Usage Instructions

### Basic Research Pattern

**Step 1:** Invoke the gemini-search agent via Task tool

```
Use the Task tool with:
- subagent_type: "gemini-search:gemini-search"
- description: "Research [topic]"
- prompt: "[Detailed research request as shown in patterns above]"
```

**Step 2:** Process the results

The agent will return structured results including:
- Summary of findings
- Key points and recommendations
- Source URLs for reference
- Relevant examples or code snippets

**Step 3:** Apply the research

Use the research findings to:
- Answer user questions with current information
- Implement features based on best practices
- Troubleshoot issues with verified solutions
- Make informed technical decisions

### Advanced Usage

**Multi-query research:**

When you need to research multiple related topics, invoke the agent multiple times with different queries:

```
1. Search for general overview/documentation
2. Search for specific best practices
3. Search for examples and use cases
4. Search for troubleshooting and common issues
```

**Targeted documentation search:**

For official documentation, include source constraints in your query:

```
"Claude Code skills documentation site:docs.claude.com"
"GitHub Actions workflow syntax site:docs.github.com"
"ShellCheck documentation site:shellcheck.net"
```

## Token Efficiency

### Why This Saves Tokens

**Context isolation:**
- Agent runs in isolated context
- Only returns final results to main conversation
- Doesn't include intermediate search results in main context
- Saves 30-40% tokens on research-heavy tasks

**Caching:**
- Results cached for 1 hour (default)
- Repeated queries use cache (no additional API calls)
- Cache hit rate tracked in analytics

**Structured output:**
- Agent formats results concisely
- Removes redundant information
- Focuses on actionable content

### Monitoring Token Savings

Check analytics to see token savings:

```bash
/gemini-search:search-stats
```

This shows:
- Total searches performed
- Cache hit rate
- Estimated token savings
- Top queries

## Configuration

### Environment Variables

Control caching and behavior:

```bash
# Cache TTL (seconds)
export GEMINI_SEARCH_CACHE_TTL=3600  # 1 hour (default)

# Cache directory
export GEMINI_SEARCH_CACHE_DIR="/tmp/gemini-search-cache"

# Analytics directory
export GEMINI_ANALYTICS_DIR="/tmp/gemini-analytics"

# Enable debug logging
export DEBUG=true
```

### Cache Management

Clear cache if needed:

```bash
/gemini-search:clear-cache
```

This removes all cached search results and resets analytics.

## Best Practices

### 1. Be Specific in Queries

**Good:**
```
"GitHub Actions workflow syntax for release automation with semantic versioning 2025"
```

**Less effective:**
```
"GitHub Actions workflow"
```

### 2. Include Context

Provide context in your research prompts:

```
Research GitHub Actions workflow best practices for a Claude Code plugin repository.
Focus on:
- Shell script linting (ShellCheck)
- JSON validation
- Release automation with semantic versioning
- Security scanning

Include current (2025) best practices and working examples.
```

### 3. Leverage Caching

For repeated research on the same topic, rely on cached results to save time and tokens.

### 4. Verify Sources

Always check the source URLs provided by the agent to ensure information comes from:
- Official documentation
- Reputable technical sites
- Recent publications (prefer 2024-2025)

### 5. Combine with Local Knowledge

Use web research to supplement, not replace, local knowledge:
- Research when local docs are insufficient
- Verify current best practices
- Find recent changes or updates
- Discover new tools or patterns

## Examples

### Example 1: Research Claude Code Skills

```
Task tool parameters:
- subagent_type: "gemini-search:gemini-search"
- description: "Research Claude Code skills"
- prompt: "Search for comprehensive documentation about Claude Code skills.

  Focus on:
  1. What skills are and how they work
  2. Skill structure and YAML frontmatter format
  3. Best practices for skill creation
  4. Examples of well-designed skills
  5. Tool access restrictions with allowed-tools

  Please provide a structured summary with key points and official documentation URLs.

  Include current information from docs.claude.com."
```

### Example 2: Research GitHub Actions Best Practices

```
Task tool parameters:
- subagent_type: "gemini-search:gemini-search"
- description: "Research GitHub Actions CI/CD"
- prompt: "Research GitHub Actions CI/CD best practices for a shell script project.

  Include:
  1. Workflow structure and organization
  2. Matrix testing across platforms
  3. Caching strategies for dependencies
  4. Security scanning integration
  5. Release automation patterns

  Focus on 2025 best practices with working examples.

  Include information from docs.github.com and reputable sources."
```

### Example 3: Troubleshoot ShellCheck Issue

```
Task tool parameters:
- subagent_type: "gemini-search:gemini-search"
- description: "Research ShellCheck SC2086"
- prompt: "Research ShellCheck warning SC2086: 'Double quote to prevent globbing and word splitting'.

  Find:
  1. What causes this warning
  2. Why it's important to fix
  3. Common fix patterns with examples
  4. Cases where it can be safely ignored

  Provide practical examples from shellcheck.net and trusted sources."
```

## Limitations

### When NOT to Use This Skill

**Don't use for:**
- Local file reading (use Read tool instead)
- Code analysis (use Grep/Glob tools)
- Local repository information (use Bash with git commands)
- Information already in context
- Very specific codebase questions (use local search first)

**Do use for:**
- Current best practices and standards
- Official documentation not in context
- Error message troubleshooting
- Tool comparisons and recommendations
- Recent updates or changes to tools
- Examples from the broader community

### Rate Limiting

The gemini-search agent uses the Gemini API which may have rate limits:
- Respect API limits
- Use caching to reduce API calls
- Space out multiple searches if needed

## Integration with Other Skills

This web-research skill complements other skills:

**plugin-creator:**
- Research Claude Code plugin best practices
- Find examples of successful plugins
- Look up marketplace requirements

**shell-script-quality:**
- Research ShellCheck best practices
- Find BATS testing examples
- Look up shell script patterns

**github-repo-management:**
- Research GitHub Actions patterns
- Find CI/CD best practices
- Look up release automation examples

## Troubleshooting

### Agent Not Responding

If the gemini-search agent doesn't return results:

1. Check Gemini API key is configured
2. Verify internet connectivity
3. Check agent is installed with `/plugin list`
4. Review error logs at `/tmp/gemini-search-errors.log`

### Poor Results Quality

If results are not relevant:

1. Make queries more specific
2. Include more context in prompt
3. Specify source constraints (e.g., site:docs.github.com)
4. Try different phrasing

### Cache Issues

If cache is causing stale results:

1. Clear cache with `/gemini-search:clear-cache`
2. Adjust cache TTL with `GEMINI_SEARCH_CACHE_TTL`
3. Verify cache directory permissions

## Quick Reference

**Invoke gemini-search agent:**
```
Task tool with subagent_type="gemini-search:gemini-search"
```

**Research patterns:**
- Documentation: "Find official docs for [topic]"
- Best practices: "Research best practices for [topic]"
- Troubleshooting: "Find solutions for [error/issue]"
- Tools: "Research [tool] features and usage"
- Comparison: "Compare [A] vs [B] for [use case]"

**Commands:**
- `/gemini-search:search [query]` - Direct search
- `/gemini-search:search-stats` - View analytics
- `/gemini-search:clear-cache` - Clear cache

## Resources

- **Gemini Search Agent**: `.claude/agents/gemini-search.md`
- **Search Command**: `.claude/commands/search.md`
- **Analytics**: `/tmp/gemini-analytics/analytics.json`
- **Cache**: `/tmp/gemini-search-cache/`
- **Logs**: `/tmp/gemini-search.log`

## Next Steps

To use this skill effectively:

1. Ensure Gemini API key is configured
2. Familiarize yourself with the gemini-search agent capabilities
3. Review analytics to understand usage patterns
4. Adjust cache TTL based on your needs
5. Use specific, context-rich queries for best results
