# My Plugin Name

Brief description of what your plugin does and why it's useful.

## Features

- Feature 1 with description
- Feature 2 with description
- Feature 3 with description

## Installation

### Prerequisites

- Requirement 1 (e.g., Node.js 18+)
- Requirement 2 (e.g., specific CLI tool)

### Install from Marketplace

```bash
# In Claude Code
/plugin add my-plugin
```

### Local Testing

Add to your `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "local-test": {
      "source": {
        "source": "directory",
        "path": "/absolute/path/to/my-plugin"
      }
    }
  }
}
```

Then in Claude Code:
```bash
/plugin add my-plugin@local-test
```

## Usage

### Command 1: /my-command

Description of what this command does.

```bash
/my-command "your argument here"
```

**Examples:**
```bash
/my-command "example 1"
/my-command "example 2"
```

### Command 2: /another-command

Description of what this command does.

```bash
/another-command [options]
```

## Configuration

### Environment Variables

- `VAR_NAME` - Description (default: value)
- `ANOTHER_VAR` - Description (default: value)

### Settings

Configure in `.claude/settings.json`:
```json
{
  "plugins": {
    "my-plugin": {
      "option1": "value1",
      "option2": "value2"
    }
  }
}
```

## Architecture

Brief overview of how the plugin works:
- Component 1 explanation
- Component 2 explanation
- Key design decisions

## Troubleshooting

### Issue 1

**Problem:** Description of the problem

**Solution:** Steps to resolve

### Issue 2

**Problem:** Description of the problem

**Solution:** Steps to resolve

## Development

### Setup

```bash
git clone https://github.com/username/my-plugin.git
cd my-plugin
chmod +x scripts/*.sh hooks/*.sh
```

### Running Tests

```bash
bash tests/run-tests.sh
```

### Linting

```bash
shellcheck scripts/*.sh hooks/*.sh
jq empty .claude-plugin/plugin.json
jq empty .claude-plugin/marketplace.json
```

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- Issues: https://github.com/username/my-plugin/issues
- Documentation: https://github.com/username/my-plugin
- Email: your.email@example.com

## Changelog

See [CHANGES.md](CHANGES.md) for a list of changes in each version.

## Acknowledgments

- Inspiration or libraries used
- Contributors
- Related projects
