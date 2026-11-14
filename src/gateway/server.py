"""Read-only MCP Gateway P1 proof. No host, GitHub or project data access.

Run locally: python -m src.gateway.server
This starts a loopback Streamable HTTP MCP endpoint at /mcp.
"""

from typing import Literal

from mcp.server import MCPServer
from mcp.types import ToolAnnotations
from pydantic import BaseModel, ConfigDict

SERVICE_VERSION = "0.1.0"


class HealthResponse(BaseModel):
    """Strict, deterministic public health payload without host information."""

    model_config = ConfigDict(extra="forbid")

    service: Literal["mcp-gateway"]
    version: Literal["0.1.0"]
    status: Literal["ok"]


mcp = MCPServer("mcp-gateway")


@mcp.tool(
    title="MCP Gateway health",
    annotations=ToolAnnotations(read_only_hint=True, open_world_hint=False),
    structured_output=True,
)
def gateway_health() -> HealthResponse:
    """Check whether the MCP Gateway read-only demo tool responds.

    Returns public static service/version/ok fields only.
    This tool does not inspect Windows, GitHub, users or any private project.
    """
    return HealthResponse(service="mcp-gateway", version=SERVICE_VERSION, status="ok")


# ASGI entrypoint for local inspection; defaults protect localhost Host/Origin.
app = mcp.streamable_http_app()


if __name__ == "__main__":
    # SDK's one-process loopback Streamable HTTP test server.
    # Never expose on a public interface without a separate auth/deployment ADR.
    mcp.run("streamable-http")
