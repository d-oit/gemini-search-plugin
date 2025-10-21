---
description: Agent description explaining what this agent does and when to use it
capabilities:
  [
    "capability-1",
    "capability-2",
    "capability-3",
  ]
---

# My Agent Name

This agent provides [specific functionality] with [key features like context isolation, specialized processing, etc.].

## Purpose

[Explain why this agent exists and what problems it solves]

## Features

- Context isolation for token savings
- Specialized processing for [specific task]
- Error handling and retry logic
- [Additional features]

## Usage Patterns

This agent should be used when:
- Pattern 1: [specific scenario]
- Pattern 2: [specific scenario]
- Pattern 3: [specific scenario]

## Architecture

[Explain key architectural decisions, such as:]
- Why context isolation is used
- What data flows in and out
- Performance characteristics
- Integration points with commands/hooks

## Processing Logic

1. Receive input from parent command
2. Process data in isolated context
3. Return structured results
4. Handle errors gracefully

## Error Handling

- Retry logic with exponential backoff
- Fallback strategies
- Graceful degradation
- Comprehensive error logging

## Performance Considerations

- Typical token usage: [estimate]
- Cache utilization: [if applicable]
- Context isolation savings: [percentage]
- Processing time: [estimate]

## Important Notes

- Key constraint or limitation
- Dependency requirements
- Security considerations
- Best practices for using this agent
