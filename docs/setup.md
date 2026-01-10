# NixOS Setup

## Install

```bash
# Boot NixOS installer USB
loadkeys dvorak
nmcli device wifi connect "SSID" password "PASSWORD"

# Partition
gdisk /dev/nvme0n1
# n, 1, default, +1G, ef00 (EFI)
# n, 2, default, default, 8300 (Linux root)
# w

mkfs.fat -F 32 -n boot /dev/nvme0n1p1
mkfs.ext4 -L nixos /dev/nvme0n1p2

mount /dev/nvme0n1p2 /mnt
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot

# Clone repo, generate hardware config
nix-shell -p git
git clone https://github.com/christian-oudard/nixos-config.git /mnt/etc/nixos
nixos-generate-config --root /mnt --show-hardware-config > /mnt/etc/nixos/hosts/x1carbon/hardware-configuration.nix

# Install and reboot
nixos-install --flake /mnt/etc/nixos#x1carbon
reboot
```

## Bootstrap

```bash
# Login as christian, start sway
sway

# Get age key from 1Password (Mod+Return for terminal)
eval $(op signin)
mkdir -p ~/.keys
op item get "age_chezmoi_key.txt" --vault "Personal" --format=json --fields=notesPlain | jq -r .value > ~/.keys/age_key.txt
chmod 600 ~/.keys/age_key.txt

# Rebuild to decrypt secrets
cd /etc/nixos
sudo nixos-rebuild switch --flake .#x1carbon

# SSH keys
ssh-keygen -t ed25519 -C "christian.oudard@gmail.com"
# Add to https://github.com/settings/keys

# Switch repo to SSH
git remote set-url origin git@github.com:christian-oudard/nixos-config.git
```

## Secrets

**Keys:**
- Private: `~/.keys/age_key.txt`
- Public: `age1apnl93pm2smqnd5pkh04suhj3h9a73wtg05p3mtugzw75y8jyg3scfser2`

**Add secret:**
```bash
# 1. Add to secrets/secrets.nix
"new-secret.age".publicKeys = [ christian ];

# 2. Encrypt
age -r "age1apnl93pm2smqnd5pkh04suhj3h9a73wtg05p3mtugzw75y8jyg3scfser2" \
    -o secrets/new-secret.age plaintext.txt

# 3. Add to home.nix age.secrets block

# 4. Rebuild
sudo nixos-rebuild switch --flake .#x1carbon
```

**Edit secret:**
```bash
age -d -i ~/.keys/age_key.txt secrets/file.age > /tmp/file
nvim /tmp/file
age -r "age1apnl93pm2smqnd5pkh04suhj3h9a73wtg05p3mtugzw75y8jyg3scfser2" \
    -o secrets/file.age /tmp/file
rm /tmp/file
sudo nixos-rebuild switch --flake .#x1carbon
```

## Commands

```bash
sudo nixos-rebuild switch --flake /etc/nixos#x1carbon  # Rebuild
sudo nixos-rebuild switch --rollback                    # Rollback
nix flake update                                        # Update inputs
nix search nixpkgs firefox                              # Search packages
sudo nix-collect-garbage -d                             # Garbage collect
```

## Recovery

```bash
# Boot installer, mount, chroot
mount /dev/nvme0n1p2 /mnt
mount /dev/nvme0n1p1 /mnt/boot
nixos-enter
nixos-rebuild switch --flake /etc/nixos#x1carbon
```
