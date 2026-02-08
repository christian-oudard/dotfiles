#!/bin/sh
exec sudo systemd-run --slice=agent.slice --uid=agent \
    --pty -- bash --login -c 'cd ~ && claude --dangerously-skip-permissions'
