#! /bin/sh

set -e

# Mount the given flash drive as the current user.
device=/dev/sda1
mountpoint=/mnt/usb

sudo mount $device $mountpoint \
    -o uid=$(id -u),gid=$(id -g),umask=002

echo "Mounted $device at $mountpoint"
