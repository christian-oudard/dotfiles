#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"
sudo nixos-rebuild switch --flake .
