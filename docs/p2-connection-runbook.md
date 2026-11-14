# P2 connection test: ChatGPT Chat → MCP Gateway

Status: **PREPARED, NOT LIVE VERIFIED**. Tracking: [Issue #2](https://github.com/trung-via/mcp-gateway/issues/2). The P1 server is already merged and CI-tested, but no approved HTTPS or tunnel endpoint exists.

## Step 0 — confirm ChatGPT connection entitlement (without exposing the laptop)

Open [ChatGPT Plugins](https://chatgpt.com/plugins) **on the web**. Use the plus icon → **Add custom MCP server** if available. An account/workspace may restrict this UI. The OpenAI [quickstart](https://developers.openai.com/plugins/quickstart) uses an independent public read-only example URL to test plugin creation and explicitly demonstrates a Work session. This example is **not** our Gateway and is not proof of normal Chat connectivity. Do not send private information to an unrelated example server.

Record:
- Surface: Chat vs Work vs desktop/mobile and plan/role shown;
- Whether the Add custom MCP server menu exists;
- Whether a created plugin can be installed and used from ordinary Chat;
- Any error verbatim (redact account IDs, tokens or private links).

## Step 1 — run our Gateway locally, only on loopback

From this repository with Python 3.11 and PowerShell 7:

```powershell
py -3.11 -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements-dev.txt
.\.venv\Scripts\python.exe -m pytest -q tests/test_gateway_health.py tests/test_connection_probe.py
.\.venv\Scripts\python.exe -m src.gateway.server
```

In a *second* PowerShell window:

```powershell
.\.venv\Scripts\python.exe tests/probe_mcp_endpoint.py --url http://127.0.0.1:8000/mcp
```

Expected terminal output:

```text
PASS: MCP endpoint discovery, health response and INVALID_PARAMS
```

This is only a local MCP client probe. No ChatGPT verification is implied. The probe intentionally never calls Windows/GitHub tools and refuses nonlocal plain HTTP, embedded URL credentials and unexpected paths.

## Step 2 — select a transport to ChatGPT (separate authorization)

Option A: **Secure MCP Tunnel** (preferred if supported and provisioned). It is outbound-only and avoids public inbound Windows exposure; requires a tunnel identity, runtime credential and suitable OpenAI Platform organization/workspace permissions. Follow the [official Secure MCP Tunnel documentation](https://developers.openai.com/api/docs/guides/secure-mcp-tunnels). Do not commit API keys/tunnel credentials.

Option B: **Approved temporary HTTPS forwarding** dedicated *only* to local port 8000 and `/mcp`. Never expose Chrome CDP 9444, OS admin services, personal files or a generic proxy. Keep it temporary and do not use a URL from an untrusted third party without checking the provider's terms/security. The only MCP tool in this MVP is a deterministic anonymous public health check.

Neither option has been deployed or authorized by an accepted P2 deployment ADR in this repo. Do **not** start exposing a local port just because the read-only test passed.

## Step 3 — register plugin and prove real Chat invocation

1. In ChatGPT web, Plugins → plus → Add custom MCP server.
2. Enter a dedicated name (for example **MCP Gateway Health**) and choose the approved HTTPS URL ending in `/mcp`, or choose the approved Tunnel. Use No authentication **only** for this single public health tool.
3. Inspect the risk warning and create/install the plugin.
4. Open **normal Chat**, choose or @mention the connected MCP plugin and request `gateway_health`. Observe an actual tool invocation, not merely the typed mention.
5. Confirm returned structured content exactly:
   `{"service":"mcp-gateway","version":"0.1.0","status":"ok"}`
6. Record non-secret evidence: tool name, surface, exact source revision, timestamp, the result, and any relevant error. Keep Chat A URL, session IDs, tokens and tunnel credentials private.

Only this end-to-end witness can satisfy `GATEWAY-P2-002` with evidence tier `LIVE`. A Work invocation alone proves Work only. This does not establish that an external webhook can proactively write to Chat A.

## Troubleshooting & interpretation

| Observation | Meaning | Next action |
| --- | --- | --- |
| No Add custom MCP server UI | `ACCOUNT_OR_SURFACE_UNVERIFIED/BLOCKED` | Use supported web/workspace path; do not claim plan eligibility from GitHub |
| Local probe fails | `MCP_LOCAL_NOT_READY` | Inspect server process, SDK pin, loopback port and local logs |
| Local probe passes but ChatGPT cannot connect | `ENDPOINT_OR_CONNECTION_BLOCKED` | Check HTTPS/tunnel reachability and plugin registration/auth |
| Plugin installed but tool not discovered | `DISCOVERY_BLOCKED` | Check MCP endpoint and metadata in connection wizard |
| Tool list shown but Chat does not call | `CHAT_TOOL_SELECTION_UNVERIFIED` | Select installed plugin explicitly; inspect permissions and actual call trace |
| Tool call succeeded in Work, not Chat | `WORK_ONLY_PROOF` | Test Chat separately; do not mark Chat LIVE |
| Tool responds with unexpected fields | `SCHEMA_MISMATCH` | Reject acceptance; check source and tool contract |

## Sources (verified for design: 2026-11-14)

- [Add custom MCP server](https://developers.openai.com/api/docs/guides/custom-mcp-server)
- [Connect and test your plugin](https://developers.openai.com/plugins/deploy/connect-chatgpt)
- [Secure MCP Tunnel](https://developers.openai.com/api/docs/guides/secure-mcp-tunnels)
- [Plugins in ChatGPT](https://help.openai.com/en/articles/20001256-plugins-in-chatgpt)
