# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a chezmoi dotfiles repository. Files here are source templates that chezmoi applies to the home directory.

## Branches

- **`main`** — Arch Linux
- **`nixos`** — NixOS

These branches intentionally diverge in:
- **Neovim plugin management**: Arch uses lazy.nvim (`dot_config/nvim/lua/plugins.lua`), NixOS has plugins managed by nix (no plugin manager in the config)
- **Shell aliases**: Arch aliases coreutils to uutils (`uu-cp`, `uu-mv`), NixOS uses standard coreutils
- **NixOS-specific shell config**: `nix-shell` alias, `nix_shell_status` prompt indicator, `LD_LIBRARY_PATH`

Claude settings (`private_dot_claude/`) and the bulk of `dot_config/nvim/init.lua` should be kept in sync between branches.

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

**Before editing permissions**: Read `rstrict-sandbox/README.md` for the sandboxing setup, documented settings, and known limitations. Many sandbox settings found online or hallucinated by Claude don't actually exist.

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
XDG_CACHE_HOME=/tmp/claude/nix-cache nixos-rebuild build --flake nixos-config/
```

This builds the config to verify it's valid. Sandbox blocks the normal cache path, so use temp cache.

New files must be `git add`ed before nix can see them.

### Activating Changes

After making changes, run `./nixos-config/rebuild.sh` (requires disabling sandbox).

### Neovim Setup

Plugins managed via `programs.neovim.plugins` in `nixos-config/home.nix`. Config files in chezmoi dotfiles repo.
LSP servers installed as packages: pyright, rust-analyzer, ruff, typescript-language-server

## Claude Code Sandbox

Requires `socat` and `bubblewrap` in systemPackages. User runs `/sandbox` in Claude Code. Uses kernel "no new privileges" flag to block sudo.

**Sandbox limitations:**
- Can't run sudo (intended)
- Can't GPG-sign commits (blocks ~/.gnupg)
