#!/bin/bash
set -e
cd "$(dirname "$0")"
sudo nixos-rebuild switch --flake .

cd system_tests
uvx pytest -q
