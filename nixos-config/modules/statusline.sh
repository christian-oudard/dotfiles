#!/bin/bash
# Cave statusline, composed from segments each owned by its own component:
#   - byline:               cav-host agent-tag        (coding-cave)
#   - persist session:      persist status --short    (persist plugin)
#   - model class + context%: Claude Code statusLine JSON on stdin
# This script only assembles them; it parses no component's internal state.
input=$(cat)

line=$(cav-host agent-tag)

# Model class from the model id, e.g. claude-opus-4-8 -> Opus.
id=$(printf '%s' "$input" | jq -r '.model.id // empty')
case "$id" in
    *fable*)  model=Fable ;;
    *opus*)   model=Opus ;;
    *sonnet*) model=Sonnet ;;
    *haiku*)  model=Haiku ;;
    *)        model=$(printf '%s' "$input" | jq -r '.model.display_name // empty') ;;
esac
[ -n "$model" ] && line="$line · $model"

# Context window fill, pre-calculated by Claude Code (0-100).
pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty' | cut -d. -f1)
[ -n "$pct" ] && line="$line · ${pct}%"

# persist owns its compact rendering. Gate on the public `persist active`
# predicate so nothing shows when no session is running.
if persist active 2>/dev/null; then
    seg=$(persist status --short 2>/dev/null)
    [ -n "$seg" ] && line="$line · $seg"
fi

echo "$line"
