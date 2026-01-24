#!/usr/bin/env bash

# Stop any existing tunnels
tunnels=$(ngrok api tunnels list 2>/dev/null)
session_ids=$(echo "$tunnels" | jq -r '.tunnels[].tunnel_session.id // empty')
if [[ -n "$session_ids" ]]; then
    echo "Found existing tunnels:"
    echo "$tunnels" | jq -r '.tunnels[] | .started_at' | while read -r ts; do
        tunnel=$(echo "$tunnels" | jq -r --arg ts "$ts" '.tunnels[] | select(.started_at == $ts)')
        age=$(( ($(date +%s) - $(date -d "$ts" +%s)) / 60 ))
        url=$(echo "$tunnel" | jq -r '.public_url')
        fwd=$(echo "$tunnel" | jq -r '.forwards_to')
        echo "  • ${age}m ago: $url -> $fwd"
    done
    read -p "Stop these? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        for session_id in $session_ids; do
            ngrok api tunnel-sessions stop "$session_id"
        done
    fi
fi

TERM=xterm-256color ngrok tcp 22
