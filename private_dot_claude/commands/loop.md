---
description: "Start a coding loop."
argument-hint: "LIMIT TASK"
allowed-tools: ["Bash(claude-loop:*)"]
hide-from-slash-command-tool: "true"
---
/loop $ARGUMENTS

```!
claude-loop <<'_LOOP_ARGS_'
$ARGUMENTS
_LOOP_ARGS_
```
