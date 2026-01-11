# NixOS Config

## Current State
- NixOS 25.11 (stable), flake-based
- Home-manager enabled with `home-packages-only.nix` (packages only, no dotfiles)
- Dotfiles managed by chezmoi
- Agenix disabled

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

## File Structure
- `flake.nix` - inputs and module composition
- `hosts/x1carbon/configuration.nix` - system config (minimal packages)
- `home-packages-only.nix` - user packages via home-manager
- `home.nix` - full home-manager config (unused, has dotfile management)

## Known Issues
- **Packer DNS in nvim**: `:PackerSync` fails with "Could not resolve host: github.com" but git works fine from `:!git ...` and from shell. Async job spawning issue - unresolved.

## Migration Path to Full Home-Manager
To eventually replace chezmoi with home-manager for dotfiles:
1. Back up chezmoi dotfiles
2. Switch from `home-packages-only.nix` to `home.nix` in flake.nix
3. Remove chezmoi-managed files from ~/.config/
4. Re-enable agenix for secrets
5. Rebuild
