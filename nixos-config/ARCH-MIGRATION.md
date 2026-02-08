# Arch Linux to NixOS Migration Guide

This guide covers migrating from Arch Linux with existing LUKS+LVM to NixOS while preserving your /home partition.

## Current Layout (Arch)

```
nvme0n1p1        (1G)     /boot
nvme0n1p2        (952.9G) LUKS "cryptlvm"
└── archlvm (VG)
    ├── swap     (30.8G)  [SWAP]
    ├── root     (128G)   /        ← will be reformatted
    └── home     (794.1G) /home    ← preserved
```

## Phase 1: Backup (on Arch, before rebooting)

### 1.1 Mount External USB Drive

```bash
# Find your drive
lsblk

# Mount it
sudo mount /dev/sdX1 /mnt/usb
```

### 1.2 Initialize Restic Repos

```bash
# Local backup
restic -r /mnt/usb/backup init

# Remote backup (adjust for your remote)
restic -r sftp:user@host:/path/to/backup init
```

### 1.3 Run Backups

```bash
# Save package list for reference
pacman -Qe > ~/arch-packages.txt

# Backup home and etc
restic -r /mnt/usb/backup backup /home /etc
restic -r sftp:user@host:/path/to/backup backup /home /etc
```

### 1.4 Verify Backups

```bash
# Check snapshots exist
restic -r /mnt/usb/backup snapshots

# Spot-check contents
restic -r /mnt/usb/backup ls latest | head -50

# Optionally verify integrity
restic -r /mnt/usb/backup check
```

## Phase 2: Prepare NixOS Configuration

### 2.1 Create New Host Directory

On your existing NixOS machine (dedekind) or after booting the live USB:

```bash
cd nixos-config
mkdir -p hosts/cantor
```

### 2.2 Create Configuration Files

You'll need to create:
- `hosts/cantor/configuration.nix` - copy from dedekind, change hostname
- `hosts/cantor/hardware-configuration.nix` - generated during install

### 2.3 Update flake.nix

Add the new host to `nixosConfigurations`:

```nix
cantor = nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    ./hosts/cantor/configuration.nix
    # ... same modules as dedekind
  ];
};
```

### 2.4 Commit and Push

```bash
git add hosts/cantor flake.nix
git commit -m "Add cantor configuration"
git push
```

## Phase 3: Install NixOS

### 3.1 Boot NixOS Live USB

Download from https://nixos.org/download/ and boot from USB.

### 3.2 Connect to Network

```bash
sudo nmtui
```

### 3.3 Unlock Existing LUKS + LVM

```bash
# Unlock LUKS (will prompt for passphrase)
sudo cryptsetup open /dev/nvme0n1p2 cryptlvm

# Activate LVM volume group
sudo vgchange -ay

# Verify volumes are available
sudo lvs
```

### 3.4 Format ONLY Root (Preserves Home)

```bash
# Format root - THIS WIPES YOUR ARCH INSTALL
sudo mkfs.ext4 -L nixos /dev/archlvm/root

# DO NOT format home!
```

### 3.5 Mount Filesystems

```bash
sudo mount /dev/archlvm/root /mnt
sudo mkdir -p /mnt/boot /mnt/home
sudo mount /dev/nvme0n1p1 /mnt/boot
sudo mount /dev/archlvm/home /mnt/home
sudo swapon /dev/archlvm/swap
```

### 3.6 Generate Hardware Configuration

```bash
sudo nixos-generate-config --root /mnt
```

This creates `/mnt/etc/nixos/hardware-configuration.nix` with detected mounts.

### 3.7 Clone Your Config

```bash
cd /mnt/home/christian
git clone https://github.com/christian-oudard/dotfiles
cd dotfiles
git checkout nixos
```

### 3.8 Copy Hardware Config

```bash
cp /mnt/etc/nixos/hardware-configuration.nix nixos-config/hosts/cantor/
```

### 3.9 Install

```bash
sudo nixos-install --flake ./nixos-config#cantor
```

Set root password when prompted (or skip if you don't need it).

### 3.10 Reboot

```bash
reboot
```

## Phase 4: Post-Install Setup

### 4.1 Apply Dotfiles

```bash
cd ~/dotfiles
chezmoi apply
```

### 4.2 Verify Everything Works

- [ ] Can log in
- [ ] Sway starts
- [ ] Network works
- [ ] Home directory files intact
- [ ] GPG keys work
- [ ] SSH keys work

### 4.3 Clean Up

Once satisfied, you can remove the Arch package list:

```bash
rm ~/arch-packages.txt
```

## Troubleshooting

### Can't Unlock LUKS

If you changed your LUKS passphrase, you need the current one. If forgotten, restore from backup to a fresh install.

### Boot Fails

See "Recovery (Unbootable System)" in README.md. The process is similar but use `cryptlvm` and `archlvm` instead of `crypted` and `pool`.

### Home Permissions Wrong

If home directory permissions are wrong after install:

```bash
sudo chown -R christian:users /home/christian
```

### Missing Firmware Warnings

Add any missing firmware packages to configuration.nix:

```nix
hardware.firmware = [ pkgs.linux-firmware ];
```
