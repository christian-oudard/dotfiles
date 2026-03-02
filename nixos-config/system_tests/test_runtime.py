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


def test_ssl_connects():
    """Python SSL should successfully complete a TLS handshake."""
    ctx = ssl.create_default_context()
    # badssl.com exists specifically for SSL testing
    with socket.create_connection(("badssl.com", 443), timeout=10) as sock:
        with ctx.wrap_socket(sock, server_hostname="badssl.com") as ssock:
            assert ssock.version().startswith("TLS")


# --- Core paths ---



def test_bin_bash_exists():
    """/bin/bash should exist (system.activationScripts.binbash)."""
    assert os.path.isfile("/bin/bash")


# --- Key packages ---


def _has_command(cmd):
    return subprocess.run(
        ["which", cmd], capture_output=True
    ).returncode == 0


def test_shell_commands():
    """Shell and terminal commands referenced by zshrc/zshenv/sway."""
    missing = [
        cmd for cmd in [
            "zsh", "bash", "tmux", "nvim", "foot", "direnv",
        ] if not _has_command(cmd)
    ]
    assert not missing, f"Missing commands: {missing}"


def test_desktop_commands():
    """Commands referenced by sway config."""
    missing = [
        cmd for cmd in [
            "swaymsg", "swaylock", "swaybg", "bemenu", "j4-dmenu-desktop",
            "grim", "slurp", "brightnessctl", "wpctl", "makoctl",
            "i3status", "batsignal", "wl-copy", "wl-paste", "notify-send",
        ] if not _has_command(cmd)
    ]
    assert not missing, f"Missing commands: {missing}"


def test_cli_tool_commands():
    """CLI tools referenced by shell aliases, functions, and scripts."""
    missing = [
        cmd for cmd in [
            "eza", "dust", "fd", "fzf", "rg",
            "git", "gh", "jq", "chezmoi", "restic", "gpg",
        ] if not _has_command(cmd)
    ]
    assert not missing, f"Missing commands: {missing}"


def test_dev_tool_commands():
    """Dev tools referenced by nvim LSP config and build system."""
    missing = [
        cmd for cmd in [
            "python3", "uv", "node", "gcc", "pkg-config",
            "pyright", "ruff", "rust-analyzer",
        ] if not _has_command(cmd)
    ]
    assert not missing, f"Missing commands: {missing}"


# --- gnome-keyring / Secret Service ---


def test_gnome_keyring_works():
    """keyring module should store, retrieve, and delete a password via gnome-keyring."""
    import keyring

    service = "test-gnome-keyring-check"
    username = "testuser"
    password = "s3cret-test-value"

    try:
        keyring.set_password(service, username, password)
        retrieved = keyring.get_password(service, username)
        assert retrieved == password, f"Expected {password!r}, got {retrieved!r}"
    finally:
        keyring.delete_password(service, username)
