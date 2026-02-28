"""Runtime tests — verify the live deployed system works correctly.

These test the actual running system state. Only reliable on the host
after a rebuild, NOT from the cave (which has a frozen /etc snapshot).

Run with: pytest test_runtime.py
"""

import os
import ssl
import socket
import subprocess


# --- SSL / Certificates ---


def test_ssl_cert_pem_exists():
    """/etc/ssl/cert.pem should exist (needed by uv's standalone Python)."""
    assert os.path.exists("/etc/ssl/cert.pem"), (
        "/etc/ssl/cert.pem missing — uv Python SSL will fail"
    )


def test_ssl_default_context_loads_certs():
    """The default SSL context should load a non-trivial number of CA certs."""
    ctx = ssl.create_default_context()
    stats = ctx.cert_store_stats()
    assert stats["x509_ca"] >= 100, f"Only {stats['x509_ca']} CA certs loaded"


def test_ssl_connects_to_major_sites():
    """Python SSL should successfully connect to major HTTPS sites."""
    ctx = ssl.create_default_context()
    failures = []
    for site in ["google.com", "github.com", "pypi.org"]:
        try:
            with socket.create_connection((site, 443), timeout=10) as sock:
                with ctx.wrap_socket(sock, server_hostname=site) as ssock:
                    assert ssock.version().startswith("TLS")
        except Exception as e:
            failures.append(f"{site}: {e}")
    assert not failures, "SSL failures:\n" + "\n".join(failures)


# --- Core paths ---


def test_bin_bash_exists():
    """/bin/bash should exist (system.activationScripts.binbash)."""
    assert os.path.isfile("/bin/bash")


# --- Key packages ---


def _has_command(cmd):
    return subprocess.run(
        ["which", cmd], capture_output=True
    ).returncode == 0


def test_essential_commands():
    """Core commands from systemPackages should be available."""
    missing = [
        cmd
        for cmd in ["git", "python3", "zsh", "uv", "bash"]
        if not _has_command(cmd)
    ]
    assert not missing, f"Missing commands: {missing}"
