#!/bin/bash
set -e
cd "$(dirname "$0")"

# The host config's only remaining private flake input is coding-cave (over
# SSH). A cave has no keys to fetch it, but has a local checkout to override
# with instead; override the eval-only lock so this runs from inside a cave
# too, not just from a host with SSH access.
flags=()
if [ -n "$CODING_CAVE_VERSION" ]; then
    flags=(--override-input coding-cave path:/projects/coding-cave --no-write-lock-file)
fi

for host in dedekind cantor; do
    echo "Evaluating $host..."
    nix eval "${flags[@]}" .#nixosConfigurations.$host.config.system.build.toplevel --raw >/dev/null
done

cd system_tests
if command -v uvx >/dev/null; then
    uvx pytest test_build.py -q
else
    nix shell nixpkgs#python3Packages.pytest --command pytest test_build.py -q
fi
