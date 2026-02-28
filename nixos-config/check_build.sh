#!/bin/bash
set -e
cd "$(dirname "$0")"

# Try nix build directly; fall back to git archive if the gitdir is inaccessible
# (e.g., in a coding-cave overlayfs sandbox).
if ! nix build .#nixosConfigurations.cantor.config.system.build.toplevel --no-link 2>/dev/null; then
    tmpdir=$(mktemp -d)
    trap "rm -rf $tmpdir" EXIT
    git -C .. archive HEAD nixos-config/ | tar -x -C "$tmpdir"
    nix build "$tmpdir/nixos-config#nixosConfigurations.cantor.config.system.build.toplevel" --no-link
fi

cd system_tests
uvx pytest test_build.py -q
