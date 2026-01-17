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
- `home.nix` - home-manager config (programs, dotfiles, packages)
- `secrets/` - agenix-encrypted secrets (.age files)
- `nvim/` - neovim config (init.vim, lua/plugins.lua, lua/lsp.lua, UltiSnips/)
- `sway/` - sway config and scripts
- `tmux/` - tmux config
- `i3status/` - i3status config
- `config/` - misc config files (gruvbox.sh)

## Neovim Setup
Plugins managed via `programs.neovim.plugins` in home.nix (not Packer). Config files:
- `nvim/init.vim` - main config with Dvorak mappings, gruvbox, settings
- `nvim/lua/plugins.lua` - plugin setup (bufferline, trouble)
- `nvim/lua/lsp.lua` - LSP config for pyright, rust-analyzer, ruff, ts_ls
- `nvim/UltiSnips/all.snippets` - custom snippets

LSP servers installed as packages: pyright, rust-analyzer, ruff, typescript-language-server

Not available in nixpkgs: minuet-ai, copilot

