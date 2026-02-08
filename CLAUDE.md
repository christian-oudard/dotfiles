# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a chezmoi dotfiles repository. Files here are source templates that chezmoi applies to the home directory.

## Branches

- **`main`** — Cross-platform base (works on both Arch and NixOS)
- **`archlinux`** — Arch Linux-specific additions on top of main
- **`nixos`** — NixOS-specific additions on top of main

Platform-specific differences:
- **Neovim plugin management**: `archlinux` uses lazy.nvim (`dot_config/nvim/lua/plugins.lua`), `nixos` has plugins managed by nix
- **Shell aliases**: `archlinux` aliases coreutils to uutils (`uu-cp`, `uu-mv`), `main`/`nixos` use standard coreutils

## Chezmoi Naming Conventions

- `dot_` prefix → `.` (e.g., `dot_config/` → `~/.config/`)
- `private_` prefix → file with restricted permissions
- `executable_` prefix → file with execute permission
- `encrypted_*.age` → age-encrypted files (decrypted on apply)
- `.tmpl` suffix → Go template files

## Commands

```bash
chezmoi apply           # Apply changes to home directory
chezmoi diff            # Preview changes before applying
chezmoi edit <file>     # Edit a managed file
chezmoi add <file>      # Add a file to be managed
```

## Structure

- `bin/` - Executable scripts installed to `~/bin/`
- `dot_config/` - XDG config directory (`~/.config/`)
- `private_dot_claude/` - User-level Claude Code settings (`~/.claude/`)
- `.claude/` - Repo-specific Claude Code settings for this dotfiles repo (not managed by chezmoi)

## Claude Code Settings

Two separate Claude configurations exist here:

- **User-level settings** (`private_dot_claude/`): Edit `private_settings.json` and `private_CLAUDE.md` here to change global Claude Code behavior across all projects. These are applied to `~/.claude/` via chezmoi.
- **Repo-specific settings** (`.claude/`): Settings that only apply when working in this dotfiles repository. Not managed by chezmoi.

**Important**: When examining Claude Code settings in this repo, always read the chezmoi source files (`private_dot_claude/private_settings.json`), not the deployed files (`~/.claude/settings.json`).

## Encryption

Uses age encryption with identity at `~/.keys/age_chezmoi_key.txt`. Encrypted files have `.age` extension.

## Key Configurations

- **Shell**: zsh with config in `dot_config/zsh/`
- **Editor**: neovim, config in `dot_config/nvim/` (see Branches section for plugin management differences)
- **Window Manager**: sway with config in `dot_config/sway/`
- **Terminal**: foot with config in `dot_config/foot/`

## NixOS Configuration (`nixos-config/`)

NixOS unstable, flake-based. Full home-manager config via `home.nix`. Disko for LUKS/LVM disk management.

### File Structure

- `flake.nix` - inputs and module composition
- `flake.lock` - pinned versions (commit this for reproducibility)
- `hosts/dedekind/configuration.nix` - system config (greetd, XKB, minimal packages)
- `hosts/dedekind/disk-config.nix` - disko config for LUKS/LVM partitioning
- `home.nix` - home-manager config (packages only, dotfiles via chezmoi)

### Testing Changes (without sudo)

```bash
nixos-rebuild build --flake nixos-config/
```

New files must be `git add`ed before nix can see them.

### Activating Changes

After making changes, run `./nixos-config/rebuild.sh`

### Neovim Setup

Plugins managed via `programs.neovim.plugins` in `nixos-config/home.nix`. Config files in chezmoi dotfiles repo.
LSP servers installed as packages: pyright, rust-analyzer, ruff, typescript-language-server

## Claude Code Sandbox

Requires `socat` and `bubblewrap` in systemPackages. User runs `/sandbox` in Claude Code. Uses kernel "no new privileges" flag to block sudo.

**Sandbox limitations:**
- Can't run sudo (intended)
- Can't GPG-sign commits (blocks ~/.gnupg)
