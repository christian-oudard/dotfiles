#!/bin/bash

COOKIE="/tmp/nerd-dictation.cookie"

# Check if process is running
PID=$(cat "$COOKIE" 2>/dev/null)
if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
    # Process exists - toggle suspend/resume
    if [ -f "$COOKIE.suspended" ]; then
        notify-send -u low "Voice ON"
        nerd-dictation resume
        rm -f "$COOKIE.suspended"
    else
        notify-send -u low "Voice OFF"
        nerd-dictation suspend
        touch "$COOKIE.suspended"
    fi
else
    # Not running (no cookie or stale cookie) - start fresh
    notify-send -u low "Voice START"
    rm -f "$COOKIE" "$COOKIE.suspended"
    exec nerd-dictation begin --simulate-input-tool=WTYPE
fi
