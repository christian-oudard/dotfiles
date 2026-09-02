# The headless system half every host shares: the account and its shell, the
# nix machinery, and the glue language tooling needs. Anything that
# presupposes a screen, a battery or a desk lives in laptop.nix instead.
#
# Exported from the flake as nixosModules.common and imported by hosts outside
# this repository, so nothing here may reference the private coding-cave
# input, and per-host judgment calls are mkDefault.
{
  config,
  lib,
  pkgs,
  username,
  ...
}:

{
  # Locale and timezone
  time.timeZone = "US/Mountain";
  i18n.defaultLocale = "en_US.UTF-8";

  # The account. Hardware-dependent group memberships come from laptop.nix;
  # a host that enables Docker or audio adds the matching groups itself.
  users.users.${username} = {
    uid = 1000;
    isNormalUser = true;
    homeMode = "700";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  # Sudo: ask for password, cache 15 minutes globally across all terminals.
  # mkDefault, because a host reachable only by SSH key turns the password off.
  security.sudo = {
    wheelNeedsPassword = lib.mkDefault true;
    extraConfig = ''
      Defaults timestamp_type=global
      Defaults timestamp_timeout=15
      Defaults lecture=never
    '';
  };

  # Daily nix garbage collection. The retention is mkDefault: fourteen days
  # suits a laptop disk, and zeal's forty gigabytes wants three.
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = lib.mkDefault "--delete-older-than 14d";
  };

  # Deduplicate the store, and let the daemon GC under disk pressure during
  # builds so the root partition never fills up between scheduled runs.
  nix.optimise.automatic = true;
  nix.settings = {
    min-free = 5 * 1024 * 1024 * 1024; # start freeing when < 5G free
    max-free = 20 * 1024 * 1024 * 1024; # free up to 20G
  };

  # A GitHub token, so `github:` flake inputs are not capped at the 60/hour
  # per-IP limit for anonymous api.github.com requests. Kept out of the store:
  # nix.settings would render the token into world-readable /etc/nix/nix.conf.
  # `!include` is the optional form, so a host without the file still builds.
  nix.extraOptions = ''
    !include /etc/nix/access-tokens.conf
  '';

  # Shells
  programs.zsh.enable = true;
  programs.bash.enable = true;

  # nix-ld for running pip-installed packages with C extensions.
  # Project-specific libs (e.g. CUDA) belong in per-project devShells, not here.
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    portaudio
  ];

  # Create /bin/bash symlink for scripts with hardcoded shebangs
  system.activationScripts.binbash = ''
    ln -sf /run/current-system/sw/bin/bash /bin/bash
  '';

  # uv's standalone Python expects CA certs at /etc/ssl/cert.pem, which NixOS
  # doesn't create. Symlink it to the NixOS CA bundle so SSL works in uv venvs.
  environment.etc."ssl/cert.pem".source = "/etc/ssl/certs/ca-bundle.crt";

  # System packages (minimal - user packages in home-manager)
  environment.systemPackages = with pkgs; [
    git
    nano
    acl
    gcc
    pkg-config
  ];

  # Temp directory for Claude Code sandbox (TMPDIR=/tmp/claude)
  systemd.tmpfiles.rules = [
    "d /tmp/claude 0755 ${username} users -"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
