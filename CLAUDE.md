# NixOS Config

## Current State
- NixOS 25.11 (stable), flake-based
- Full home-manager config via `home.nix`
- Agenix enabled for secrets
- Claude Code via npx alias (auto-updates)

## Testing Changes (without sudo)
```bash
XDG_CACHE_HOME=/tmp/claude/nix-cache nixos-rebuild build --flake .
```
This builds the config to verify it's valid. Sandbox blocks the normal cache path, so use temp cache.

New files must be `git add`ed before nix can see them.

## Activating Changes
Run `./rebuild.sh` (Claude can't - sandbox blocks sudo)

## Testing as Another User
Use `machinectl shell` instead of `sudo -u`:
```bash
sudo machinectl shell testuser@
```
This creates a proper systemd user session. Required for agenix (secrets decryption) and other systemd user services. `sudo -u testuser -i` doesn't work - it lacks the systemd user instance.

## Claude Code Sandbox
Requires `socat` and `bubblewrap` in systemPackages. User runs `/sandbox` in Claude Code. Uses kernel "no new privileges" flag to block sudo.

**Sandbox limitations:**
- Can't run sudo (intended)
- Can't GPG-sign commits (blocks ~/.gnupg)
- Creates empty dotfiles in CWD as protection artifacts (bug) - these are gitignored

## File Structure
- `flake.nix` - inputs and module composition
- `flake.lock` - pinned versions (commit this for reproducibility)
- `hosts/x1carbon/configuration.nix` - system config (minimal packages)
- `home.nix` - home-manager config (programs, dotfiles, packages)
- `packages.nix` - user packages imported by home.nix
- `secrets/` - agenix-encrypted secrets (.age files)
- `nvim/` - neovim config files (referenced by home.nix via xdg.configFile)

## Neovim Setup
Plugins managed via `programs.neovim.plugins` in home.nix (not Packer). Config files stored in repo:
- `nvim/init.vim` - main config with Dvorak mappings, gruvbox, settings
- `nvim/lua/lsp.lua` - LSP config for pyright, rust-analyzer, ruff, ts_ls
- `nvim/UltiSnips/all.snippets` - custom snippets

LSP servers installed as packages: pyright, rust-analyzer, ruff, typescript-language-server

Disabled: minuet-ai (not in nixpkgs)

