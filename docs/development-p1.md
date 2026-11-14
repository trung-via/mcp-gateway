# P1 read-only MCP local development

This is a source/test prototype only: no deployed public URL, Windows host agent, GitHub adapter, production OAuth or ChatGPT Chat connection.

## Runtime

- Python 3.11+.
- Official Python MCP SDK pinned to `mcp==2.3.0` (MCP 2026-07-28 plus legacy protocol compatibility).
- Launch with `python -m src.gateway.server`; loopback Streamable HTTP at `http://127.0.0.1:8000/mcp`.
- Keep local host allowlist/dns-rebinding defaults. Do **not** make the server public or add a reverse proxy without a separate security review.

## Windows setup (PowerShell 7)

```powershell
py -3.11 -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements-dev.txt
.\.venv\Scripts\python.exe -m pytest -q tests/test_gateway_health.py
.\.venv\Scripts\python.exe -m src.gateway.server
```

In another terminal:

```powershell
.\.venv\Scripts\python.exe tests/smoke_http.py
```

Alternatively open MCP Inspector and connect using Streamable HTTP to `http://127.0.0.1:8000/mcp`.

## Evidence boundary

- A Python unit test does not prove an HTTP transport is available.
- An HTTP smoke PASS does not prove ChatGPT can install/choose the tool.
- A ChatGPT Chat user turn invoking `gateway_health` is an independent P2 acceptance gate.
- CI validates exact PR code, not production availability.

## Safety scope

The `gateway_health` handler is deterministic, anonymous, no arguments and has no project or host reads. All authentication/access to user-specific data and writes belong to later separately authorized phases.

## References

- [MCP Python SDK v2](https://py.sdk.modelcontextprotocol.io/)
- [In-memory client tests](https://py.sdk.modelcontextprotocol.io/get-started/testing/)
- [Structured output](https://py.sdk.modelcontextprotocol.io/servers/structured-output/)
- [Deploy and localhost safeguards](https://py.sdk.modelcontextprotocol.io/run/deploy/)
