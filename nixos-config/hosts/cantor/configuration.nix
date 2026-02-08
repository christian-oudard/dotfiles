# NixOS system configuration for cantor
{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
  ];

  networking.hostName = "cantor";
}
