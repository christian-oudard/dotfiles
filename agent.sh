#!/bin/sh
exec sudo systemd-run --slice=agent-claude.slice --uid=agent-claude \
    --pty -- bash --login -c 'cd ~ && claude --dangerously-skip-permissions'
