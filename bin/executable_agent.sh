#!/bin/sh
exec sudo systemd-run --scope --slice=agent.slice \
    -- unshare --mount --pid --fork bash -c \
    'mount -t proc proc /proc -o hidepid=invisible && exec su - agent -c "claude --dangerously-skip-permissions"'
