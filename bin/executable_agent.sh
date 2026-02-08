#!/bin/sh
# Launch Claude Code as the agent user with namespace isolation.
# --scope: cgroup resource limits via agent.slice, uses current terminal
# unshare: mount/pid namespaces for proc hiding and private /tmp
exec sudo systemd-run --scope --slice=agent.slice \
    -- unshare --mount --pid --fork sh -c '
# Hide other users processes from the agent
mount -t proc proc /proc -o hidepid=invisible

# Give the agent its own /tmp so it cannot see other users files
mkdir -p /tmp/agent
chown agent:users /tmp/agent
chmod 700 /tmp/agent
mount --bind /tmp/agent /tmp

# Drop privileges and run claude
exec su - agent -c "claude --dangerously-skip-permissions"
'
