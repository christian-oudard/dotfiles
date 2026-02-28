"""Build-time tests — verify NixOS config produces the expected system.

These inspect the nix evaluation output, not the live system. Safe to run
from the cave or anywhere with access to the flake.

Run with: uvx pytest test_build.py
"""

import json
import os
import shutil
import subprocess
import tempfile
from pathlib import Path

NIXOS_DIR = Path(__file__).resolve().parent.parent


def _resolve_flake_dir():
    """Return a flake directory that nix can evaluate.

    In the coding cave, nix can't read the overlayfs gitdir alternates
    directly. Fall back to extracting via git archive into a temp dir.
    """
    # Try direct path first
    r = subprocess.run(
        ["nix", "eval", f"{NIXOS_DIR}#nixosConfigurations.cantor.config.system.stateVersion", "--raw"],
        capture_output=True, text=True,
    )
    if r.returncode == 0:
        return str(NIXOS_DIR), None

    # Fall back: extract nixos-config/ from git into a temp dir
    repo_root = NIXOS_DIR.parent
    tmpdir = tempfile.mkdtemp(prefix="nixos-check-")
    subprocess.run(
        ["git", "archive", "HEAD", "nixos-config/"],
        capture_output=True, cwd=repo_root,
    ).stdout
    subprocess.run(
        f"git -C {repo_root} archive HEAD nixos-config/ | tar -x -C {tmpdir}",
        shell=True, check=True,
    )
    return os.path.join(tmpdir, "nixos-config"), tmpdir


FLAKE_DIR, _TMPDIR = _resolve_flake_dir()
FLAKE_ATTR = f"{FLAKE_DIR}#nixosConfigurations.cantor.config"


def teardown_module():
    if _TMPDIR:
        shutil.rmtree(_TMPDIR, ignore_errors=True)


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


def test_ssl_cert_pem_symlink():
    """/etc/ssl/cert.pem should be configured (needed by uv's standalone Python)."""
    entry = _nix_etc("ssl/cert.pem")
    assert entry["enable"], "/etc/ssl/cert.pem is not enabled"
    assert "ca-bundle" in entry["source"] or "ca-certificates" in entry["source"], (
        f"Unexpected source: {entry['source']}"
    )


def test_ca_bundle_configured():
    """/etc/ssl/certs/ca-certificates.crt should point to the cacert package."""
    entry = _nix_etc("ssl/certs/ca-certificates.crt")
    assert entry["enable"]
    assert "nss-cacert" in entry["source"], f"Unexpected source: {entry['source']}"


def test_ca_bundle_has_enough_certs():
    """The CA bundle should contain a reasonable number of certificates."""
    source = _nix_eval('environment.etc."ssl/certs/ca-certificates.crt".source', raw=True)
    with open(source) as f:
        content = f.read()
    cert_count = content.count("BEGIN CERTIFICATE") + content.count("BEGIN TRUSTED CERTIFICATE")
    assert cert_count >= 100, f"Only {cert_count} certs in CA bundle"


# --- System packages ---


def test_system_packages_include_essentials():
    """systemPackages should include git, gcc, and pkg-config."""
    pkgs = _nix_eval("environment.systemPackages")
    pkg_str = " ".join(pkgs)
    for name in ["git", "gcc", "pkg-config"]:
        assert name in pkg_str, f"{name} not in systemPackages"


# --- Key system settings ---


def test_nix_flakes_enabled():
    """Flakes should be enabled."""
    features = _nix_eval("nix.settings.experimental-features")
    assert "flakes" in features


def test_zsh_enabled():
    """zsh should be the configured shell."""
    assert _nix_eval("programs.zsh.enable") is True


def test_nix_ld_enabled():
    """nix-ld should be enabled for pip-installed packages with C extensions."""
    assert _nix_eval("programs.nix-ld.enable") is True
