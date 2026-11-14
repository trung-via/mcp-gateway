# MCP Gateway core — P1 read-only prototype

Implemented in [`server.py`](server.py) using Python `mcp==2.3.0` with MCP Server and loopback Streamable HTTP `/mcp`.

The only registered tool, `gateway_health`, returns static `service`, `version` and `status` fields. There is no private data, Windows/GitHub adapter, write tool, or deployed public endpoint.

See [P1 local development guide](../../docs/development-p1.md), [tool contract](../../contracts/tools/gateway_health.v1.md) and [main Windows CI](https://github.com/trung-via/mcp-gateway/actions/runs/43583364258). Source/test acceptance does not prove ChatGPT Chat interoperability.
