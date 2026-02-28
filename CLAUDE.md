# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a chezmoi dotfiles repository. Files here are source templates that chezmoi applies to the home directory. Never read from `~/` or `~/.config/` to check config state — always read the chezmoi source files in this repo instead.

## Branch

- **`main`** — NixOS-based dotfiles (single branch)

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
- **Editor**: neovim, plugins managed via nix (see `nixos-config/home.nix`), config in `dot_config/nvim/`
- **Window Manager**: sway with config in `dot_config/sway/`
- **Terminal**: foot with config in `dot_config/foot/`

## Shell Functions and Aliases (`dot_config/zsh/dot_zshrc`)

Custom shell functions defined in zshrc:

- **`backup`** — Runs restic backup to USB (if mounted at `/mnt/usb/restic-repo`) then to Google Cloud (`gs:cwo-restic:/`). Excludes defined in `dot_config/restic/excludes.txt`
- **`restic`** — Wrapper that sets Google Cloud credentials and default repo

Key aliases:
- `ls`, `i`, `ll`, `la` → eza
- `du` → dust
- `vim` → nvim

Private/sensitive shell config is in `encrypted_private_dot_zshrc_private.age`.

## NixOS Configuration (`nixos-config/`)

NixOS unstable, flake-based. Full home-manager config via `home.nix`. Disko for LUKS/LVM disk management.

Unfree packages are allowed globally via `dot_config/nixpkgs/config.nix`.

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

After making changes, run `./nixos-config/update_system.sh`

### Neovim Setup

Plugins managed via `programs.neovim.plugins` in `nixos-config/home.nix`. Config files in chezmoi dotfiles repo.
LSP servers installed as packages: pyright, rust-analyzer, ruff, typescript-language-server

## Tests

System tests live in `nixos-config/system_tests/`. Two test files:

- **`test_build.py`** — Build-time tests. Inspect nix evaluation output, not the live system. Safe to run from the cave or anywhere with flake access. Run after changing `nixos-config/`.
- **`test_runtime.py`** — Runtime tests. Verify the live deployed system (SSL connectivity, paths, commands). Only reliable on the host after a rebuild.

```bash
./nixos-config/check_build.sh                  # cave: nix build + build tests
./nixos-config/update_system.sh                # host: rebuild only
```

Tests must not require network access beyond basic HTTPS (no API keys, no auth).

## System Configuration Responsibilities

When working in this repo, Claude Code is responsible for:

- **Keep tests green**: Run `uvx pytest nixos-config/system_tests/test_build.py` after any change to `nixos-config/`. Do not commit changes that break build tests.
- **Add tests for new invariants**: When adding system config (new packages, paths, services), add a corresponding test that verifies the expected behavior.
- **Test before suggesting rebuilds**: Before telling the user to run `update_system.sh`, verify the nix expression parses (`nix-instantiate --parse`) and that tests still pass.
- **Validate SSL/TLS**: The nix-built system Python has correct SSL paths, but uv's standalone Python needs `/etc/ssl/cert.pem` (provided via `environment.etc` in common.nix). Do not change `security.pki.useCompatibleBundle` — it drops CAs.

## Claude Code Sandbox

Requires `socat` and `bubblewrap` in systemPackages. User runs `/sandbox` in Claude Code. Uses kernel "no new privileges" flag to block sudo.

**Sandbox limitations:**
- Can't run sudo (intended)
- Can't GPG-sign commits (blocks ~/.gnupg)
