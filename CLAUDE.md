# NixOS Config

## Current State
- NixOS 25.11 (stable), flake-based
- Full home-manager config via `home.nix`
- Agenix enabled for secrets
- Claude Code via npx alias (auto-updates)
- Dotfiles managed by chezmoi: https://github.com/christian-oudard/dotfiles (clone to `./dotfiles/`)

## Testing Changes (without sudo)
```bash
XDG_CACHE_HOME=/tmp/claude/nix-cache nixos-rebuild build --flake .
```
This builds the config to verify it's valid. Sandbox blocks the normal cache path, so use temp cache.

New files must be `git add`ed before nix can see them.

## Activating Changes
After making changes, run `./rebuild.sh` (requires disabling sandbox).

## Claude Code Sandbox
Requires `socat` and `bubblewrap` in systemPackages. User runs `/sandbox` in Claude Code. Uses kernel "no new privileges" flag to block sudo.

**Sandbox limitations:**
- Can't run sudo (intended)
- Can't GPG-sign commits (blocks ~/.gnupg)
- Creates empty dotfiles in CWD as protection artifacts (bug) - these are gitignored

## File Structure
- `flake.nix` - inputs and module composition
- `flake.lock` - pinned versions (commit this for reproducibility)
- `hosts/x1carbon/configuration.nix` - system config (greetd, XKB, minimal packages)
- `home.nix` - home-manager config (packages only, dotfiles via chezmoi)
- `dotfiles/` - chezmoi source repo (clone from github.com/christian-oudard/dotfiles)

## Neovim Setup
Plugins managed via `programs.neovim.plugins` in home.nix (not Packer). Config files in chezmoi dotfiles repo.
LSP servers installed as packages: pyright, rust-analyzer, ruff, typescript-language-server

