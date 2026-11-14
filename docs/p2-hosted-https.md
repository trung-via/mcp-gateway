# P2 Hosted HTTPS MCP Gateway — direct Server URL, no Tunnel or Work

Status: **SOURCE + TEST PREPARATION ONLY**. This file is not proof that any
service is running or that ChatGPT can call it.

This deployment path satisfies the user's hard constraints:
- ChatGPT **ordinary Chat** using custom MCP **Server URL**, not Work;
- **no Tunnel**, reverse tunnel, ngrok, Cloudflare Tunnel, SSH forwarding;
- **no inbound laptop ports**, especially CDP 9444;
- one anonymous, deterministic read-only `gateway_health` tool only;
- P3 Windows/GitHub adapters remain absent and require separate permission design.

## Rationale

The official MCP Python SDK rejects real external Host headers by default
(DNS-rebinding protection). The hosted entrypoint at
[`src/gateway/public_server.py`](../src/gateway/public_server.py)
constructs a strict `TransportSecuritySettings` allowlist from the exact
`MCP_PUBLIC_HOSTNAME` or Render-provided `RENDER_EXTERNAL_HOSTNAME`.
It also denies browser Origin headers and uses stateless JSON Streamable HTTP.
The existing localhost-only `src.gateway.server` remains unchanged.

## Candidate host: Render Free, testing only

[`render.yaml`](../render.yaml) describes a **free Python web service** called
`mcp-gateway-health`, with no automatic deploys after first creation.
The service gets its hostname automatically through Render's
`RENDER_EXTERNAL_HOSTNAME` environment variable, and listens on
Render's `PORT` on `0.0.0.0`. Render terminates external HTTPS.
`.python-version` selects the 3.11 Python runtime.

The **Free** plan is for temporary evaluation only. It can spin down when idle,
cold-start slowly, be subject to quotas and be unsuitable for always-on service.
Confirm current terms before activation; no Render service or account has been
created by this code change.

Alternative deployment: run
`python -m src.gateway.public_server` on another managed Python host.
Set `MCP_PUBLIC_HOSTNAME=your-exact-domain.example`, `PORT` to the runtime
port and `RENDER=true` **only for a trusted web hosting environment**;
configure the host to accept inbound HTTPS and forward to the internal HTTP
service. Keep the Host header intact or configure the exact forwarded hostname.

## Verification (before any ChatGPT plugin creation)

On localhost with Python 3.11:

```powershell
py -3.11 -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements-dev.txt
.\.venv\Scripts\python.exe -m pytest -q tests/test_gateway_health.py tests/test_connection_probe.py tests/test_public_hosting.py
```

For hosted entrypoint loopback test, set process environment variables in
PowerShell before starting the server:

```powershell
$env:MCP_PUBLIC_HOSTNAME = "localhost"
$env:PORT = "18080"
.\.venv\Scripts\python.exe -m src.gateway.public_server
```

Then, in another shell:

```powershell
.\.venv\Scripts\python.exe tests/probe_mcp_endpoint.py --url http://localhost:18080/mcp
.\.venv\Scripts\python.exe tests/smoke_public_host.py
```

Expected: tool discovery, correct static JSON output, INVALID_PARAMS, HTTP 421
for untrusted Host and HTTP 403 for untrusted Origin.

## Actual hosting activation (requires owner and approval)

Only after the user authorizes service creation:

1. Sign in to Render and connect GitHub repository
   `trung-via/mcp-gateway`; create Blueprint from root `render.yaml`.
2. Inspect the plan (Free), runtime, service name, branch and **auto-deploy off**
   before confirming. Do not grant access to other private repos.
3. Record the **actual** Render service URL after deployment. Do not invent a URL.
4. Probe from an independent network:
   `python tests/probe_mcp_endpoint.py --url https://<actual-host>/mcp`.
   Record status/tool/schema/Host behavior and any cold-start timeouts.
5. In ChatGPT Plugins → Add custom MCP server → **Server URL**,
   enter `https://<actual-host>/mcp`. Use "No authentication" **only** if
   the actual UI offers it for the public stateless health tool. If only OAuth
   is offered, stop and investigate before adding an identity system.
6. Install the connected plugin and invoke `gateway_health` in **normal Chat**.
   Require the exact `service/version/status` response and a genuine MCP call
   witness. Do not use Work as a substitute.
7. Log the result to [Issue #2](https://github.com/trung-via/mcp-gateway/issues/2)
   with time, provider and exact source commit. Keep secrets and personal
   Chat URLs out of this public repository.

## Failure model and scope

- `421 Invalid Host header`: check `RENDER_EXTERNAL_HOSTNAME` and forwarded
  Host header; never use a wildcard or disable the entire rebinding guard.
- `403 Invalid Origin header`: a browser is sending an Origin. Only approve an
  expected exact origin after verifying the actual client; do not allow `*`.
- `502 / startup timeout`: verify Render `PORT` and service logs.
- Idle spin-down: Free-tier availability limitation, **not** proof that MCP is
  broken. Prefer a suitable managed plan after real usage is demonstrated.
- `401 OAuth`: the creation form may default to OAuth; this P2 test is
  anonymous/public only, so select No authentication if supported, or
  separately review a true OAuth architecture.
- A reachable server and CI PASS do not prove ChatGPT Chat tool-call success.
- A ChatGPT tool result does not imply an external webhook can wake Chat A.

## Sources

- [MCP SDK deployment and Host protection](https://py.sdk.modelcontextprotocol.io/run/deploy/)
- [Render blueprint reference](https://render.com/docs/blueprint-spec)
- [Render default environment](https://render.com/docs/environment-variables)
- [Render service and HTTPS](https://render.com/docs/web-services)
- [Render Free limitations](https://render.com/docs/free)
- [OpenAI MCP Server deploy and connect](https://developers.openai.com/plugins/build/mcp-server)
