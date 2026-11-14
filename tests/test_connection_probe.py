"""URL safety checks for the operator-selected MCP connection probe."""

import pytest

from tests.probe_mcp_endpoint import validate_endpoint


@pytest.mark.parametrize(
    "url",
    [
        "http://127.0.0.1:8000/mcp",
        "http://localhost:8000/mcp",
        "http://[::1]:8000/mcp",
        "https://gateway.example.org/mcp",
    ],
)
def test_accepted_urls(url: str):
    assert validate_endpoint(url) == url


@pytest.mark.parametrize(
    "url",
    [
        "",
        " http://localhost:8000/mcp ",
        "file:///etc/passwd",
        "http://gateway.example.org/mcp",
        "http://10.0.0.7/mcp",
        "http://127.0.0.1:8000/admin",
        "https://username:password@gateway.example.org/mcp",
        "https://gateway.example.org/mcp?secret=test",
        "https://gateway.example.org/mcp#fragment",
        "https://gateway.example.org:garbage/mcp",
    ],
)
def test_rejected_urls(url: str):
    with pytest.raises(ValueError):
        validate_endpoint(url)
