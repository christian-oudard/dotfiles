# Host configuration for zeal.
{
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/virtualisation/google-compute-config.nix")
    ../../common.nix
  ];

  networking.hostName = "zeal";

  # The disk is partitioned for UEFI, so GRUB installs into the ESP rather than
  # onto a drive, and the ESP has to be mounted for that to work. Both are
  # declared by the module that builds the image, which is not part of the
  # running system; google-compute-config.nix's plain /dev/sda fails here.
  boot.loader.grub = {
    device = lib.mkForce "nodev";
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
  };

  # Named explicitly: this driver failing to autoload leaves a machine with no
  # network, reachable only over serial.
  boot.kernelModules = [ "gve" ];

  nix.gc.options = "--delete-older-than 3d";

  # Keys come from instance metadata, so OS Login stays off. None are declared
  # here; this repository is public.
  security.googleOsLogin.enable = lib.mkForce false;

  # The only way in is an SSH key, so a sudo password gates nothing that key
  # does not already gate. Overrides common.nix's mkDefault.
  security.sudo.wheelNeedsPassword = false;

  # Defaults to "prohibit-password", which leaves a root key someone later
  # drops into /root/.ssh working.
  services.openssh.settings.PermitRootLogin = "no";

  # No firewall stanza on purpose: networking.firewall is off here and ports are
  # opened outside this repository. Listing allowedTCPPorts without also forcing
  # enable = true does nothing at all, silently.

  # Never bump: it selects stateful defaults and migrates nothing.
  system.stateVersion = "26.05";
}
