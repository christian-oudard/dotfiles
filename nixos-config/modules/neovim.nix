# Shared neovim home-manager module. Imported by home.nix on the host
# and by ~/.config/coding-cave/cave.nix in the cave (via the `dotfiles`
# flake input) so the plugin list and editor wiring live in one place.

{ config, lib, pkgs, ... }:

{
  # init.lua is provided externally (chezmoi on the host, dotfiles flake
  # in the cave). home-manager only writes hm-generated.lua, which the
  # external init.lua imports for plugin/runtime setup.
  xdg.configFile."nvim/init.lua".enable = lib.mkForce false;
  xdg.configFile."nvim/lua/hm-generated.lua".text =
    config.programs.neovim.initLua;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      gruvbox-nvim
      vim-commentary
      vim-surround
      vim-fugitive
      ultisnips
      vim-auto-save
      nvim-lspconfig
      vim-python-pep8-indent
      plenary-nvim
      nvim-web-devicons
      trouble-nvim
      telescope-nvim
      bufferline-nvim
      vim-nix
      lean-nvim
    ];
  };
}
