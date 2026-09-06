# NixOS system configuration for dedekind (X1 Carbon)
{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
    ../../laptop.nix
    ../../backup.nix
  ];

  networking.hostName = "dedekind";

  # Webcam: an Intel IPU6 MIPI sensor (ov2740), not a UVC device. The kernel
  # exposes only raw MIPI endpoints, which no ordinary application can open,
  # so this relays the stream to a fixed /dev/video50 that V4L2 apps accept.
  # Alder Lake is the ipu6ep platform.
  hardware.ipu6 = {
    enable = true;
    platform = "ipu6ep";
  };
}
