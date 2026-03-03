---
description: "Start a managed agent loop."
argument-hint: "LIMIT GOALS"
allowed-tools: ["Bash(claude-loop:*)"]
hide-from-slash-command-tool: "true"
---
/loop-agent $ARGUMENTS

```!
claude-loop loop-agent <<'_LOOP_ARGS_'
$ARGUMENTS
_LOOP_ARGS_
```
