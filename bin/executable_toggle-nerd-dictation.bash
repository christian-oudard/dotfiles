#!/bin/bash

COOKIE="/tmp/nerd-dictation.cookie"
STATUS_FILE="/tmp/nerd-dictation-status"
STATUS_REC='<span color="#fb4934">● REC</span>'

# Check if process is running
PID=$(cat "$COOKIE" 2>/dev/null)
if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
    # Process exists - toggle suspend/resume
    if [ -f "$COOKIE.suspended" ]; then
        echo "$STATUS_REC" > "$STATUS_FILE"
        nerd-dictation resume
        rm -f "$COOKIE.suspended"
    else
        echo "" > "$STATUS_FILE"
        nerd-dictation suspend
        touch "$COOKIE.suspended"
    fi
else
    # Not running (no cookie or stale cookie) - start fresh
    echo "$STATUS_REC" > "$STATUS_FILE"
    rm -f "$COOKIE" "$COOKIE.suspended"
    exec nerd-dictation begin --simulate-input-tool=WTYPE
fi
