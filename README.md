# MCP Gateway

An independent, public, evidence-driven project for safely connecting ChatGPT to authorized tools across multiple projects using the Model Context Protocol (MCP).

> Status: **P1 source + Windows CI verified**. A read-only `gateway_health` MCP Server exists in source, but is **not deployed publicly** and has **not been called from ChatGPT Chat**. Windows adapters, authentication for private tools and chat wake-up are future work.

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
