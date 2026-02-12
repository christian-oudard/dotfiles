#! /bin/sh

set -e

# Mount the given flash drive as the current user.
device=${1:-/dev/sda1}
mountpoint=${2:-/mnt/usb}

# Detect filesystem type
fstype=$(lsblk -no FSTYPE "$device")

case "$fstype" in
    vfat|exfat|ntfs|ntfs3)
        # FAT/NTFS don't have Unix permissions, so set uid/gid
        sudo mount "$device" "$mountpoint" \
            -o uid=$(id -u),gid=$(id -g),umask=002
        ;;
    *)
        # ext4, btrfs, xfs, etc. have native permissions
        sudo mount "$device" "$mountpoint"
        ;;
esac

echo "Mounted $device ($fstype) at $mountpoint"
