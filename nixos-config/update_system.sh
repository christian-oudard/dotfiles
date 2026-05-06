#!/bin/bash
set -e
cd "$(dirname "$0")"

# Try `switch`. If pre-switch checks block it (e.g. dbus implementation
# change), fall back to `boot`, which stages the new configuration as
# the next-boot default without touching the running system.
log=$(mktemp)
trap 'rm -f "$log"' EXIT

sudo nixos-rebuild switch --flake . 2>&1 | tee "$log"
rc=${PIPESTATUS[0]}

if [ "$rc" -eq 0 ]; then
    new_kernel=$(readlink -f /run/current-system/kernel)
    booted_kernel=$(readlink -f /run/booted-system/kernel)
    if [ "$new_kernel" != "$booted_kernel" ]; then
        echo
        echo "==> kernel changed; reboot to load the new kernel: sudo reboot"
    fi
elif grep -q "Pre-switch check" "$log"; then
    echo
    echo "==> live switch blocked by pre-switch checks; staging for next boot..."
    sudo nixos-rebuild boot --flake .
    echo
    echo "==> running system was not changed"
    echo "==> new configuration scheduled for next boot; reboot to activate: sudo reboot"
else
    exit "$rc"
fi
