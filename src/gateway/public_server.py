"""Dedicated HTTPS-hostable, read-only MCP entrypoint.

P1 local server remains localhost-only in src.gateway.server. This separate
entrypoint requires an explicit allowed hostname and exposes ONLY the existing
gateway_health tool. No Windows, GitHub, CDP, or private project adapters.
"""

import os
import re
from typing import Any

from mcp.server.transport_security import TransportSecuritySettings

from src.gateway.server import mcp

# Intentionally limited to literal DNS names, never wildcard hosts/IP ranges.
_DNS = re.compile(
    r"(?=.{1,253}$)(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z]{2,63}\Z"
)
_LOOPBACK = {"localhost", "127.0.0.1"}


def validated_hostname(raw: str | None, *, hosted: bool) -> str:
    """Fail closed if a usable DNS hostname is not configured."""
    if not isinstance(raw, str) or not raw or raw != raw.strip():
        raise ValueError("MCP_PUBLIC_HOSTNAME or RENDER_EXTERNAL_HOSTNAME is required")
    host = raw.lower()
    if not hosted and host in _LOOPBACK:
        return host
    if not _DNS.fullmatch(host):
        raise ValueError("MCP hostname must be an exact DNS name, without scheme, port or wildcard")
    return host


def build_public_app(hostname: str, *, hosted: bool = True) -> Any:
    """Build a narrowly allowlisted ASGI app; no public host wildcard."""
    host = validated_hostname(hostname, hosted=hosted)
    security = TransportSecuritySettings(
        allowed_hosts=[host, host + ":*"],
        allowed_origins=[],  # ChatGPT MCP access is server-to-server; deny browser Origins.
    )
    return mcp.streamable_http_app(
        transport_security=security,
        stateless_http=True,
        json_response=True,
        max_request_body_size=8192,
    )


def main() -> None:
    import uvicorn

    hosted = os.environ.get("RENDER", "").lower() == "true"
    host_name = os.environ.get("MCP_PUBLIC_HOSTNAME") or os.environ.get(
        "RENDER_EXTERNAL_HOSTNAME"
    )
    app = build_public_app(host_name, hosted=hosted)
    port = int(os.environ.get("PORT", "10000"))
    if not 1 <= port <= 65535:
        raise ValueError("PORT must be a TCP port 1..65535")

    # Render routes external HTTPS to its internal web port. Local execution
    # remains loopback-only, regardless of hostname configured.
    uvicorn.run(
        app,
        host="0.0.0.0" if hosted else "127.0.0.1",
        port=port,
        workers=1,
        proxy_headers=False,
        access_log=False,
    )


if __name__ == "__main__":
    main()
