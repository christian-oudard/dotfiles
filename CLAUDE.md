# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a chezmoi dotfiles repository. Files here are source templates that chezmoi applies to the home directory.

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
- **Editor**: neovim with plugins managed via nix (not packer), config in `dot_config/nvim/`
- **Window Manager**: sway with config in `dot_config/sway/`
- **Terminal**: foot with config in `dot_config/foot/`
