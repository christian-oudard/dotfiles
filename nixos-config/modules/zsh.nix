# Cave-only zsh home-manager module.
#
# Host: NixOS programs.zsh.enable plus chezmoi installs ~/.zshenv,
# ~/.config/zsh/.{zshenv,zshrc,zlogin} directly. Home-manager isn't in the
# loop on the host.
#
# Cave: home-manager is the only config layer, so we use programs.zsh and
# read the same chezmoi source files (dot_zshenv, dot_zshrc, dot_zlogin)
# through the zsh-config flake input. dotDir=".config/zsh" matches the
# host layout so $ZDOTDIR resolves to the same place inside and outside
# the cave.

{ config, lib, pkgs, zsh-config, ... }:

{
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    envExtra = builtins.readFile "${zsh-config}/dot_zshenv";
    initContent = builtins.readFile "${zsh-config}/dot_zshrc";
    loginExtra = builtins.readFile "${zsh-config}/dot_zlogin";
  };

  home.file.".config/zsh/history_filter.zsh".source =
    "${zsh-config}/history_filter.zsh";

  # cav shell reads $SHELL from the cave env to choose the interactive
  # shell; setting it here flows through home-manager's session-variable
  # generator into env.json, which the cave bwrap'd agent inherits.
  home.sessionVariables.SHELL = "${pkgs.zsh}/bin/zsh";
}
