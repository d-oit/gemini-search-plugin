# Plugin Creator Skill

A comprehensive Claude Code skill for creating well-structured Claude Code plugins following official best practices.

## Overview

This skill provides step-by-step guidance for creating Claude Code plugins, including:
- Complete plugin structure and architecture
- Configuration files (plugin.json, marketplace.json)
- Commands, agents, and hooks
- Scripts and automation
- Documentation and testing
- Marketplace publishing

## Installation

### As a Project Skill

The skill is currently located in `.claude/skills/plugin-creator/` within this project.

### For Global Use

To make this skill available globally or in other projects:

1. **Copy to a reusable location:**
   ```bash
   mkdir -p ~/claude-skills
   cp -r .claude/skills/plugin-creator ~/claude-skills/
   ```

2. **Create as a plugin:**
   - Package this skill as its own Claude Code plugin
   - Publish to a marketplace
   - Install via `/plugin add plugin-creator`

## Usage

### Automatic Invocation

Claude Code will automatically use this skill when you:
- Ask to create a new Claude Code plugin
- Request help with plugin structure
- Need guidance on plugin.json or marketplace.json
- Want to add commands, agents, or hooks
- Ask about plugin best practices

Example prompts:
```
"Help me create a new Claude Code plugin"
"How do I structure a Claude Code plugin?"
"Create a plugin that does X"
"Add a new command to my plugin"
"What's the format for marketplace.json?"
```

### Manual Invocation

You can manually invoke the skill using:
```
/skill plugin-creator
```

(Note: This requires the skill to be properly registered with Claude Code)

## Structure

```
plugin-creator/
├── SKILL.md                          # Main skill definition
├── README.md                         # This file
└── resources/                        # Template files
    ├── template-plugin.json          # Plugin configuration template
    ├── template-marketplace.json     # Marketplace listing template
    ├── template-command.md           # Command file template
    ├── template-agent.md             # Agent file template
    ├── template-hooks.json           # Hooks configuration template
    ├── template-script.sh            # Bash script template
    └── template-README.md            # Plugin README template
```

## Resources

The `resources/` directory contains ready-to-use templates:

### template-plugin.json
Basic plugin.json configuration with all required fields.

### template-marketplace.json
Complete marketplace listing with metadata, features, and dependencies.

### template-command.md
Command file template with YAML frontmatter and execution instructions.

### template-agent.md
Agent definition template for subagent-based processing.

### template-hooks.json
Hooks configuration for PreToolUse, PostToolUse, and UserPromptSubmit events.

### template-script.sh
Bash script template with error handling, logging, and JSON output.

### template-README.md
Comprehensive README template for plugin documentation.

## What This Skill Covers

### Plugin Architecture
- Directory structure and organization
- Core configuration files
- Commands, agents, and hooks
- Scripts and automation
- Documentation requirements

### Step-by-Step Creation
1. Initialize plugin structure
2. Create plugin.json
3. Create marketplace.json
4. Create commands
5. Create agents (optional)
6. Create hooks (optional)
7. Create scripts
8. Create CLAUDE.md
9. Create documentation
10. Validate and test

### Best Practices
- Context isolation with agents (30-40% token savings)
- Caching strategies for expensive operations
- Error handling and logging
- Security considerations
- Performance optimization
- Testing strategies
- Semantic versioning

### Common Patterns
- Command with script execution
- Agent-based processing
- Hook-driven automation
- Caching layer implementation

### Publishing
- Marketplace prerequisites
- Release preparation
- GitHub release creation
- Installation testing

## Examples

### Complete Minimal Plugin

The skill includes a complete example of a minimal "hello world" plugin:

```
my-plugin/
├── .claude-plugin/
│   ├── plugin.json
│   └── marketplace.json
├── commands/
│   └── hello.md
├── scripts/
│   └── hello.sh
├── CLAUDE.md
├── README.md
├── CHANGES.md
└── LICENSE
```

### Real-World Example

The skill references the gemini-search plugin as a real-world example demonstrating:
- Subagent architecture for context isolation
- Caching with 1-hour TTL
- Analytics tracking
- Multiple commands
- Hook system for automation
- Comprehensive testing

## Customization

### Adapting Templates

All templates in `resources/` are designed to be:
- Copied and customized for your needs
- Extended with additional sections
- Modified to match your coding style
- Used as reference implementations

### Adding Your Own Patterns

You can extend SKILL.md to include:
- Your organization's specific patterns
- Additional template files
- Custom workflows
- Domain-specific examples

## Troubleshooting

### Skill Not Auto-Loading

If Claude Code doesn't automatically invoke this skill:
1. Check SKILL.md frontmatter format
2. Verify description clearly states when to use
3. Ensure file is in correct location
4. Try manual invocation with `/skill plugin-creator`

### Templates Not Accessible

Templates are in `resources/` relative to the skill directory. Reference them with:
```
.claude/skills/plugin-creator/resources/template-*.{json,md,sh}
```

## Contributing

To improve this skill:
1. Update SKILL.md with additional guidance
2. Add new templates to resources/
3. Include more examples and patterns
4. Document lessons learned from real plugins

## Related Documentation

- [Claude Code Docs](https://docs.claude.com/en/docs/claude-code)
- [Skills Documentation](https://docs.claude.com/en/docs/claude-code/skills)
- [Anthropic Skills Repository](https://github.com/anthropics/skills)
- [Awesome Claude Code](https://github.com/hesreallyhim/awesome-claude-code)

## License

This skill and its templates are provided as examples for creating Claude Code plugins. Use and modify freely for your projects.
