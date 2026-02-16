# NixOS system configuration for cantor
{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
  ];

  networking.hostName = "cantor";

  # NVIDIA RTX 4070 Max-Q (Ada Lovelace)
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Add NVIDIA/CUDA libraries to nix-ld (picked up via NIX_LD_LIBRARY_PATH in zshenv)
  programs.nix-ld.libraries = [ config.hardware.nvidia.package ];
}
