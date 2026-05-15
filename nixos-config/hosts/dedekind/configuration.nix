# NixOS system configuration for dedekind (X1 Carbon)
{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
    ../../backup.nix
  ];

  networking.hostName = "dedekind";
}
