# Neovim home-manager module.

{
  config,
  lib,
  pkgs,
  ...
}:

{
  # init.lua is provided by chezmoi. home-manager only writes
  # hm-generated.lua, which init.lua imports for plugin/runtime setup.
  xdg.configFile."nvim/init.lua".enable = lib.mkForce false;
  xdg.configFile."nvim/lua/hm-generated.lua".text = config.programs.neovim.initLua;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withPython3 = true;
    withRuby = false;
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
