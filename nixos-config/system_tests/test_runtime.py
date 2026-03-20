"""Runtime tests — verify the live deployed system works correctly.

These test the actual running system state. Only reliable on the host
after a rebuild, NOT from the cave (which has a frozen /etc snapshot).

Run with: pytest test_runtime.py
"""

import os
import ssl
import socket


# --- SSL / Certificates ---


def test_ssl_cert_pem_exists():
    """/etc/ssl/cert.pem should exist (needed by uv's standalone Python)."""
    assert os.path.exists("/etc/ssl/cert.pem"), (
        "/etc/ssl/cert.pem missing, uv Python SSL will fail"
    )


def test_ssl_connects():
    """Python SSL should successfully complete a TLS handshake."""
    ctx = ssl.create_default_context()
    # badssl.com exists specifically for SSL testing
    with socket.create_connection(("badssl.com", 443), timeout=10) as sock:
        with ctx.wrap_socket(sock, server_hostname="badssl.com") as ssock:
            assert ssock.version().startswith("TLS")


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


# --- Playwright ---


def test_playwright_launches_browser():
    """Playwright should launch chromium headless and render HTML."""
    from playwright.sync_api import sync_playwright

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()
        page.set_content("<h1>hello</h1>")
        assert page.locator("h1").text_content() == "hello"
        page.close()
        browser.close()
