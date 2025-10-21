# Gemini CLI Configuration for Search Plugin

This plugin uses the Gemini CLI in headless mode with restricted tool access to provide grounded web search capabilities.

## How It Works

The plugin leverages the Gemini CLI with these key configurations:

### 1. Tool Restriction via settings.json

The `.gemini/settings.json` file restricts the Gemini CLI to **only** use the `google_web_search` tool by excluding all other tools:

```json
{
  "excludeTools": [
    "file_read", "file_write", "file_search", "file_list",
    "web_fetch", "run_shell_command", "save_memory",
    "code_execution", "edit_file", "create_file", etc.
  ]
}
```

This ensures that when the Gemini CLI agent decides which tool to use, `google_web_search` is the only available option.

### 2. Headless Mode with Auto-Approval

The plugin uses the Gemini CLI in headless mode with the `--yolo` flag:

```bash
gemini -p "/tool:googleSearch query:\"search query\" raw:true" --yolo --output-format json -m "gemini-2.5-flash"
```

- **`-p` (--prompt)**: Runs the CLI in headless mode with a direct prompt
- **`--yolo`**: Auto-approves tool usage (necessary for non-interactive scripting)
- **`--output-format json`**: Returns structured JSON output for easier parsing

### 3. Grounded Web Search Behavior

When the user asks for a search:

- The Gemini CLI agent receives the search query
- It recognizes the need for external information
- Since `google_web_search` is the only available tool, it uses that for grounding
- The agent provides **direct, grounded results** from the web search
- The generative model focuses on presenting search results, not generating unsupported answers

## Installation Requirements

This plugin requires the Gemini CLI to be installed:

```bash
npm install -g @google/gemini-cli
```

Verify installation:

```bash
gemini --version
```

## Search Behavior Guidelines

- **Direct Results**: The plugin provides search results directly from the `google_web_search` tool
- **No Hallucination**: Results are grounded in actual web content retrieved by Gemini
- **Transparent Sources**: Search results include source URLs and attributions
- **No Summarization Override**: The plugin respects the raw search data provided by the tool
