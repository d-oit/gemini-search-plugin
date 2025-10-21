---
name: my-command
description: Brief description of what this command does
usage: /my-command [arguments]
examples:
  - /my-command example argument
  - /my-command "quoted argument with spaces"
---

You are the command handler for the my-command in the my-plugin plugin.

## Purpose

[Explain what this command accomplishes]

## Execution Instructions

When this command is invoked:

1. Parse and validate the user's arguments
2. Execute the required logic (call scripts, process data, etc.)
3. Present results to the user in a clear format

### Calling a Script

Run the following command:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/my-script.sh" "{{USER_ARG}}"
```

Where `{{USER_ARG}}` is the argument provided by the user.

## Response Format

Present results with:
- Clear summary of what was accomplished
- Formatted output (use tables, lists, code blocks as appropriate)
- Any warnings, errors, or important notices
- Next steps or related commands the user might want to try

## Error Handling

If the command fails:
- Display a clear, actionable error message
- Suggest specific troubleshooting steps
- Recommend related commands that might help
- Point to documentation if applicable

## Important Notes

- [Any important caveats or considerations]
- [Performance notes]
- [Dependencies or requirements]
