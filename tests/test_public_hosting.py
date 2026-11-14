"""P2 deployment entrypoint validation without network or hosting credentials."""

import pytest

from src.gateway.public_server import build_public_app, validated_hostname


@pytest.mark.parametrize("host", ["mcp.example.org", "mcp-gateway-health.onrender.com"])
def test_allowlisted_dns_host(host):
    assert validated_hostname(host, hosted=True) == host
    assert build_public_app(host, hosted=True) is not None


@pytest.mark.parametrize(
    "host",
    [
        None, "", " ", "https://example.org", "*.example.org", "example.org:8000",
        "example.org/mcp", "example.org?x=1", ".example.org", "example.org.",
        "127.0.0.1", "localhost", "0.0.0.0", "example..org",
        "example.org,evil.example.org", "evil_example.org",
    ],
)
def test_reject_host_wildcard_url_port_ip_or_missing(host):
    with pytest.raises(ValueError):
        validated_hostname(host, hosted=True)


def test_local_hostname_is_test_only():
    assert validated_hostname("localhost", hosted=False) == "localhost"
    assert validated_hostname("127.0.0.1", hosted=False) == "127.0.0.1"


def test_localhost_not_accepted_for_hosted_server():
    with pytest.raises(ValueError):
        build_public_app("localhost", hosted=True)
