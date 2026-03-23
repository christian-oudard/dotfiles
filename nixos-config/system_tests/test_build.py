"""Build-time tests — verify NixOS config produces the expected system.

These inspect the nix evaluation output, not the live system. Safe to run
from the cave or anywhere with access to the flake.

Run with: uvx pytest test_build.py
"""

import json
import subprocess
from pathlib import Path

NIXOS_DIR = Path(__file__).resolve().parent.parent
FLAKE_ATTR = f"{NIXOS_DIR}#nixosConfigurations.cantor.config"


def _nix_eval(attr, *, raw=False):
    cmd = ["nix", "eval", f"{FLAKE_ATTR}.{attr}"]
    if raw:
        cmd.append("--raw")
    else:
        cmd.append("--json")
    r = subprocess.run(cmd, capture_output=True, text=True)
    assert r.returncode == 0, f"nix eval failed: {r.stderr}"
    if raw:
        return r.stdout
    return json.loads(r.stdout)


def _nix_etc(path):
    return _nix_eval(f'environment.etc."{path}"')


# --- SSL / Certificates ---


def test_ssl_etc_entries_configured():
    """SSL cert paths needed by uv and system Python should be configured."""
    cert_pem = _nix_etc("ssl/cert.pem")
    assert cert_pem["enable"], "/etc/ssl/cert.pem is not enabled"
    assert "ca-bundle" in cert_pem["source"] or "ca-certificates" in cert_pem["source"], (
        f"Unexpected cert.pem source: {cert_pem['source']}"
    )

    ca_crt = _nix_etc("ssl/certs/ca-certificates.crt")
    assert ca_crt["enable"], "/etc/ssl/certs/ca-certificates.crt is not enabled"
    assert "nss-cacert" in ca_crt["source"], f"Unexpected ca-certs source: {ca_crt['source']}"


def test_ca_bundle_has_enough_certs():
    """The CA bundle should contain a reasonable number of certificates."""
    source = _nix_eval('environment.etc."ssl/certs/ca-certificates.crt".source', raw=True)
    with open(source) as f:
        content = f.read()
    cert_count = content.count("BEGIN CERTIFICATE") + content.count("BEGIN TRUSTED CERTIFICATE")
    assert cert_count >= 100, f"Only {cert_count} certs in CA bundle"


