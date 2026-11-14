# MCP Gateway

An independent, public, evidence-driven project for safely connecting ChatGPT to authorized tools across multiple projects using the Model Context Protocol (MCP).

> Status: **P1 + P2 hosting source/Windows CI verified**. The read-only `gateway_health` server and independent HTTPS hosting configuration exist in code, but **no external service has been created** and **ChatGPT Chat has not yet invoked it**. Windows adapters and chat wake-up are future work.

## Goals

1. Provide a small MCP-compatible gateway with discoverable, documented tools.
2. Separate authentication, authorization, and project-specific adapters.
3. Verify tool calls originating from a ChatGPT conversation without assuming external events can proactively message that conversation.
4. Connect Windows and GitHub only after a read-only prototype is tested.
5. Keep CDP Host and AI Commerce independent; integrate only through explicit bounded contracts.

## Architecture

See [architecture overview](docs/architecture/overview.md), [ADR-0001](docs/adr/0001-repository-and-boundaries.md), [roadmap](docs/roadmap.md), [worktree](docs/worktree.md), and [ChatGPT MCP connection feasibility](docs/research/chatgpt-mcp-connection-feasibility-2026-11-14.md).

```text
ChatGPT / other MCP client
        |
        v
   MCP Gateway
   | authn/authz | tool registry | audit |
        |
        +-- Windows Host adapter (planned)
        +-- GitHub adapter (planned)
        +-- Project adapters (planned)
```

## Local MCP read-only prototype

Run from this repo with Python 3.11+: `python -m pip install -r requirements-dev.txt`; `python -m pytest -q tests/test_gateway_health.py`; `python -m src.gateway.server`. Then use `python tests/smoke_http.py` in another terminal. See [P1 guide](docs/development-p1.md). [PR #3](https://github.com/trung-via/mcp-gateway/pull/3) and [Windows main CI](https://github.com/trung-via/mcp-gateway/actions/runs/43583364258) provide source/test evidence only.

## Optional P2 direct HTTPS hosting (normal Chat, no Tunnel or Work)

A [Render Free evaluation Blueprint](render.yaml) is prepared with strict Host/Origin checks and **auto deploy disabled**. [Deploy to Render](https://render.com/deploy?repo=https://github.com/trung-via/mcp-gateway) opens Render for the **owner** to review and explicitly approve service creation. Clicking this link does not automatically deploy anything from GitHub; account confirmation is required.

After Render reports a **real** HTTPS service hostname, use `https://<actual-host>/mcp` in **ChatGPT Plugins → Add custom MCP server → Server URL**. Keep **Issue #2** open until `gateway_health` is actually invoked inside an ordinary ChatGPT Chat. No laptop ports, CDP 9444, or tunneling are used.

See the [P2 hosted-HTTPS runbook](docs/p2-hosted-https.md), [PR #5](https://github.com/trung-via/mcp-gateway/pull/5) and [exact-merge CI](https://github.com/trung-via/mcp-gateway/actions/runs/43587666927). The Free plan may sleep when idle and is **not** an always-on production choice.

## Security baseline

Public source does not mean public execution permissions. Never commit secrets, user data, browser cookies, access tokens, private conversation URLs, or real host paths. Tool annotations are descriptive, not authorization controls. See [SECURITY.md](SECURITY.md).

## Roadmap

- P0: bootstrap canonical source, ADRs, security and tool contracts
- P1: implement a read-only MCP prototype with tests
- P2: verify discovery and tool execution in ChatGPT Chat
- P3: integrate independently authorized Windows and GitHub adapters
- P4: research external events, origin correlation, and optional CDP bridge
- P5: reliability, release, and operations

## Relationship to ChatGPT plugin

The `MCP Gateway Brain` plugin is a **planning and review** interface, not evidence that a gateway server is deployed. Code and test evidence become authoritative only when committed and verified in this repository.

## License

No license has been selected. Public visibility alone does **not** grant third parties an open-source license; choose and add a LICENSE after deciding how the source should be reused.
