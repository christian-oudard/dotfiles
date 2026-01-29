# NixOS Config

## Fresh Install with LUKS/LVM

Boot from NixOS installer USB, then:

```bash
# Connect to wifi if needed
sudo nmtui

# Clone config
git clone https://github.com/christian-oudard/nixos-config
cd nixos-config

# Partition and format disk (WIPES ALL DATA)
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./hosts/dedekind/disk-config.nix

# Install
sudo nixos-install --flake .#dedekind

# Reboot
reboot
```

## Updating an Existing System

```bash
./rebuild.sh
```

## Recovery (Unbootable System)

If the system won't boot after install, boot from a NixOS live USB:

```bash
# Unlock LUKS
sudo cryptsetup open /dev/nvme0n1p2 crypted

# Activate LVM
sudo vgchange -ay

# Mount filesystems
sudo mount /dev/pool/root /mnt
sudo mount /dev/nvme0n1p1 /mnt/boot

# Install bootloader to ESP
sudo nixos-enter --root /mnt -c "bootctl install"

# Option 1: Regenerate boot entries from existing system
sudo nixos-enter --root /mnt -c "/run/current-system/bin/switch-to-configuration boot"

# Option 2: Full reinstall (if Option 1 fails)
cd /tmp
git clone https://github.com/christian-oudard/nixos-config
sudo nixos-install --root /mnt --flake /tmp/nixos-config#dedekind --no-root-password
```

### Fixing stale EFI boot entries

If `efibootmgr -v` shows entries with PARTUUIDs that don't match `lsblk -o NAME,PARTUUID`:

```bash
# Delete stale entry (replace 0002 with actual boot number)
sudo efibootmgr -b 0002 -B

# Create fresh entry
sudo efibootmgr --create --disk /dev/nvme0n1 --part 1 \
  --loader /EFI/systemd/systemd-bootx64.efi --label "Linux Boot Manager"
```
