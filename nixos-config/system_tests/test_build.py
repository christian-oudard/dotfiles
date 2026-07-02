"""Build-time tests — verify NixOS config produces the expected system.

Run with: uvx pytest test_build.py
"""

import json
import os
import subprocess
from pathlib import Path

NIXOS_DIR = Path(__file__).resolve().parent.parent
FLAKE_ATTR = f"{NIXOS_DIR}#nixosConfigurations.cantor.config"

# The host config's coding-cave input is fetched over SSH, which a cave has
# no keys for. In a cave, override it with the local checkout instead.
CAVE_FLAGS = (
    ["--override-input", "coding-cave", "path:/projects/coding-cave", "--no-write-lock-file"]
    if os.environ.get("CODING_CAVE_VERSION")
    else []
)


def _nix_eval(attr):
    cmd = ["nix", "eval", *CAVE_FLAGS, f"{FLAKE_ATTR}.{attr}", "--json"]
    r = subprocess.run(cmd, capture_output=True, text=True)
    assert r.returncode == 0, f"nix eval failed: {r.stderr}"
    return json.loads(r.stdout)


def test_ssl_cert_bundle_configured():
    """Guards against `security.pki.useCompatibleBundle` being dropped, which
    silently empties the CA bundle and breaks uv's standalone Python."""
    cert_pem = _nix_eval('environment.etc."ssl/cert.pem"')
    assert cert_pem["enable"]
    assert "ca-bundle" in cert_pem["source"] or "ca-certificates" in cert_pem["source"], (
        f"Unexpected cert.pem source: {cert_pem['source']}"
    )
