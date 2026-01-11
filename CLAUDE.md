# NixOS Config

## Current State
- NixOS 25.11 (stable), flake-based
- christian: `home-packages-only.nix` (packages only, dotfiles via chezmoi)
- testuser: `home.nix` (full home-manager config for testing migration)
- Agenix enabled for secrets

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
- `home-packages-only.nix` - packages only, no dotfiles (christian uses this)
- `home.nix` - full home-manager config with dotfiles (testuser uses this)
- `secrets/` - agenix-encrypted secrets (.age files)
- `nvim/` - neovim config files (referenced by home.nix via xdg.configFile)

## Neovim Setup
Plugins managed via `programs.neovim.plugins` in home.nix (not Packer). Config files stored in repo:
- `nvim/init.vim` - main config with Dvorak mappings, gruvbox, settings
- `nvim/lua/lsp.lua` - LSP config for pyright, rust-analyzer, ruff, ts_ls
- `nvim/UltiSnips/all.snippets` - custom snippets

LSP servers installed as packages: pyright, rust-analyzer, ruff, typescript-language-server

Disabled: minuet-ai (not in nixpkgs)

## What's Been Tested (testuser)
- zsh: prompt, aliases, history, completions, key bindings ✓
- agenix: secrets decryption (zshrc_private) ✓
- neovim: plugins load, LSP works, gruvbox theme ✓
- tmux, foot, sway, i3status, mako: via programs.* ✓

## Migration Path to Full Home-Manager
To switch christian from chezmoi to home-manager:
1. ✓ Test config as testuser first (use `machinectl shell testuser@`)
2. ✓ zsh config tested and working
3. ✓ neovim config tested and working
4. Back up chezmoi dotfiles: `cp -r ~/.local/share/chezmoi ~/chezmoi-backup`
5. Remove chezmoi-managed files: `chezmoi forget` each file, then `rm` it
6. Switch christian to `home.nix` in flake.nix
7. Rebuild and verify
8. Delete testuser when done
