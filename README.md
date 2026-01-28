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
