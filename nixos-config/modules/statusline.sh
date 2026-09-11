#!/bin/bash
# Statusline, composed from segments each owned by its own component:
#   - byline:               the command given as arguments, e.g.
#                           `cav-host agent-tag` (coding-cave). Omitted on
#                           the host, which has no agent to name.
#   - model class + context%: Claude Code statusLine JSON on stdin
#   - persist session:      persist status --short    (persist plugin)
# This script only assembles them; it parses no component's internal state.
input=$(cat)

line=
add() { [ -n "$1" ] && line+="${line:+ · }$1"; }

[ $# -gt 0 ] && add "$("$@")"

# Model class from the model id, e.g. claude-opus-4-8 -> Opus.
id=$(printf '%s' "$input" | jq -r '.model.id // empty')
case "$id" in
    *fable*)  model=Fable ;;
    *opus*)   model=Opus ;;
    *sonnet*) model=Sonnet ;;
    *haiku*)  model=Haiku ;;
    *)        model=$(printf '%s' "$input" | jq -r '.model.display_name // empty') ;;
esac
# Effort level (/effort), e.g. xhigh. Absent on models without effort levels.
effort=$(printf '%s' "$input" | jq -r '.effort.level // empty')
[ -n "$model" ] && [ -n "$effort" ] && model="$model $effort"
add "$model"

# Context window fill, pre-calculated by Claude Code (0-100).
pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty' | cut -d. -f1)
add "${pct:+${pct}%}"

# persist owns its compact rendering. Gate on the public `persist active`
# predicate so nothing shows when no session is running.
if persist active 2>/dev/null; then
    add "$(persist status --short 2>/dev/null)"
fi

echo "$line"
