#!/bin/bash
set -e
cd "$(dirname "$0")"

for host in dedekind cantor; do
    echo "Evaluating $host..."
    nix eval .#nixosConfigurations.$host.config.system.build.toplevel --raw >/dev/null
done

cd system_tests
uvx pytest test_build.py -q
