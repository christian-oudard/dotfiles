# Cave-only zsh home-manager module.
#
# Host: NixOS programs.zsh.enable plus chezmoi installs ~/.zshenv,
# ~/.config/zsh/.{zshenv,zshrc,zlogin} directly. Home-manager isn't in the
# loop on the host.
#
# Cave: home-manager is the only config layer, so we use programs.zsh and
# read the same chezmoi source files (dot_zshenv, dot_zshrc, dot_zlogin)
# through the zsh-config flake input. dotDir is set to xdg.configHome/zsh
# so $ZDOTDIR resolves to the same path inside and outside the cave.

{ config, pkgs, zsh-config, ... }:

{
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    envExtra = builtins.readFile "${zsh-config}/dot_zshenv";
    initContent = builtins.readFile "${zsh-config}/dot_zshrc";
    loginExtra = builtins.readFile "${zsh-config}/dot_zlogin";
    # Files in /nix/store/*/share/zsh are owned by host root, which the
    # cave's user namespace surfaces as "nobody". compinit's default check
    # ("owned by root or you") fails on that and prompts for confirmation.
    # -C skips the check; the host-side .zshrc keeps its own compinit -C.
    completionInit = "autoload -U compinit && compinit -C";
  };

  xdg.configFile."zsh/history_filter.zsh".source =
    "${zsh-config}/history_filter.zsh";

  # cav shell reads $SHELL from the cave env to choose the interactive
  # shell; setting it here flows through home-manager's session-variable
  # generator into env.json, which the cave bwrap'd agent inherits.
  home.sessionVariables.SHELL = "${pkgs.zsh}/bin/zsh";
}
