#!/usr/bin/env bash
set -e

# Check if ngrok is authenticated
if ! ngrok config check &>/dev/null; then
    echo "ngrok is not configured. Run 'ngrok authtoken <your-token>' first."
    echo "Get your token from: https://dashboard.ngrok.com/get-started/your-authtoken"
    exit 1
fi

# Check if sshd is running
if ! systemctl is-active --quiet sshd; then
    echo "SSH server is not running. Enable it in your NixOS config and rebuild."
    exit 1
fi

echo "Starting ngrok tunnel to SSH (port 22)..."
echo "Share the connection info that appears below with whoever needs access."
echo ""

ngrok tcp 22
