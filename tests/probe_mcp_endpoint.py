"""Read-only connection probe for an operator-approved MCP endpoint.

This script does not register an app, open a tunnel, install a plugin or
authenticate. It performs only MCP tool discovery and calls gateway_health.
Run against localhost or an independently approved HTTPS MCP endpoint.
"""

import argparse
import asyncio
from urllib.parse import urlsplit

from mcp import Client, MCPError
from mcp.types import INVALID_PARAMS


EXPECTED = {"service": "mcp-gateway", "version": "0.1.0", "status": "ok"}


def validate_endpoint(url: str) -> str:
    if not isinstance(url, str) or not url or url.strip() != url:
        raise ValueError("A non-empty MCP server URL is required")
    try:
        value = urlsplit(url)
        port = value.port  # Detect invalid ports eagerly.
    except ValueError as exc:
        raise ValueError("Invalid MCP URL") from exc

    if value.scheme not in {"http", "https"}:
        raise ValueError("Only HTTP(S) MCP URLs are supported")
    if not value.hostname or value.username is not None or value.password is not None:
        raise ValueError("MCP URL must have a host and no embedded credentials")
    if value.query or value.fragment or value.path != "/mcp":
        raise ValueError("MCP URL must end in /mcp without query or fragment")
    if port is not None and port < 1:
        raise ValueError("Invalid port")

    # Plain HTTP is safe only for the loopback-only local test.
    if value.scheme == "http" and value.hostname not in {"localhost", "127.0.0.1", "::1"}:
        raise ValueError("Non-local MCP endpoints require HTTPS")
    return url


async def check_mcp_endpoint(url: str) -> None:
    validate_endpoint(url)
    async with Client(url) as client:
        listing = await client.list_tools()
        matches = [tool for tool in listing.tools if tool.name == "gateway_health"]
        if len(matches) != 1:
            raise AssertionError("Expected exactly one gateway_health tool")

        tool = matches[0]
        if not (tool.annotations and tool.annotations.read_only_hint is True):
            raise AssertionError("gateway_health must be annotated read-only")
        if tool.input_schema.get("properties", {}) != {}:
            raise AssertionError("gateway_health input schema is not empty")

        result = await client.call_tool("gateway_health", {})
        if result.is_error or result.structured_content != EXPECTED:
            raise AssertionError("gateway_health returned an unexpected result")

        try:
            await client.call_tool("gateway_health", {"unexpected": True})
        except MCPError as error:
            if error.code != INVALID_PARAMS:
                raise AssertionError("Expected INVALID_PARAMS for unexpected argument") from error
        else:
            raise AssertionError("gateway_health accepted unexpected arguments")


def main() -> None:
    parser = argparse.ArgumentParser(description="Probe an approved read-only MCP gateway")
    parser.add_argument("--url", required=True, help="Local HTTP or approved HTTPS URL ending /mcp")
    args = parser.parse_args()
    endpoint = validate_endpoint(args.url)
    asyncio.run(check_mcp_endpoint(endpoint))
    print("PASS: MCP endpoint discovery, health response and INVALID_PARAMS")


if __name__ == "__main__":
    main()
