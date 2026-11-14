# GATEWAY-P0-004 — ChatGPT MCP connection feasibility (research, NOT a live proof)

Reviewed: **2026-11-14**. Source tier: **DOC** only.
Tracking issue: [#2](https://github.com/trung-via/mcp-gateway/issues/2).
Related merged source: [PR #3](https://github.com/trung-via/mcp-gateway/pull/3), merge commit `cabdb994bcb342d4b258adc468eafda2c40c3501`.

## Current evidence

- The source repository has a Python `mcp==2.3.0` read-only MCP Server, `gateway_health`, and local Streamable HTTP tests. [Windows CI on main](https://github.com/trung-via/mcp-gateway/actions/runs/43583364258) passed. This is **not** an internet-reachable ChatGPT connection.
- MCP Gateway Brain v0.1.1 is a **skills-only** plugin, NOT an app-backed tool connection.
- No `https://.../mcp` endpoint, MCP tunnel association, registered `plugin_asdk_app...` instance or live ChatGPT `gateway_health` invocation has been established in project evidence.
- The user's personal ChatGPT plan, plugin/workspace entitlements and exact available creation controls cannot be verified from GitHub or public documentation.

## Official documented paths and evidence limits

| Surface/path | Documented capability | Verification still required |
| --- | --- | --- |
| ChatGPT web + plugin | ChatGPT can invoke tools from an installed connected MCP plugin in Chat; remote MCP uses plugin connection | Check *this account* exposes add/connect controls, then observe a real tool call in Chat |
| ChatGPT Work | Official quickstart specifically demonstrates invoking a personal custom MCP plugin in Work | Check plan/role and actual Work access; Work proof does not establish ordinary Chat proof |
| Add custom MCP server | Plugins UI may permit registering a public HTTPS Streamable HTTP endpoint; choose No authentication for this non-sensitive `gateway_health` only | UI availability/entitlement is account- and workspace-dependent, not proven for this account |
| Secure MCP Tunnel | Outbound-only private MCP connection with OpenAI Platform roles and tunnel-client; suitable for supported private testing | Requires supported Platform org, tunnel permissions, runtime credentials and workspace matching; **not** inferred from Plus |
| Local Codex / desktop | Can use local STDIO or HTTP MCP host where supported | Local MCP client success is not proof of ChatGPT web Chat connection |
| Sites-hosted plugin | Plugin Creator/Sites can host a new server when eligible | Hosting another tool implementation does not automatically deploy this repository's Python server; package identity and maintenance must be deliberate |
| Mobile | Plugins may be usable according to installed capability and supported surface | No direct evidence for this project |

## Recommended smallest experiment (P2)

### Stage A — read-only eligibility probe (no network exposure)

1. In the target **ChatGPT Chat** account, inspect Plugins to determine whether `Add custom MCP server`, a connection wizard, or the Plugin Creator/Sites route is actually available.
2. Record which surface worked (Chat web, Work, desktop) and the plan/role limitation, if any. Do not treat a displayed plugin listing or the existing Brain skill as evidence of a running MCP tool.
3. Decide a supported connectivity path *only after* this probe. If Chat web custom connection cannot be established, label `BLOCKED_ENTITLEMENT_OR_SURFACE` with observed UI evidence; continue source work independently.

### Stage B — a safely reachable demo server (requires a distinct deployment decision)

1. Start the merged, pinned read-only server with loopback-only transport and verify local `/mcp`.
2. Use an approved **temporary HTTPS tunnel or secure MCP tunnel** to make that exact server reachable by ChatGPT. Keep all other tools/host endpoints inaccessible. Do not automatically expose CDP 9444, Windows admin interfaces, browser sessions, tokens or filesystem tools.
3. Register a **separate** MCP connection in ChatGPT for the deployed endpoint, with **No authentication only for the static `gateway_health` proof**; use OAuth for any future private/project tool.
4. Install/select that app in **normal Chat** and invoke `gateway_health`. Record observed tool name, schema, result `{service:"mcp-gateway", version:"0.1.0", status:"ok"}`, source SHA, timestamp and non-secret receipt.
5. Separately test wrong endpoint, offline server, unknown tool and malformed input. A command invoked from Codex or MCP Inspector alone does not satisfy this step.

### Stage C — next decision

Only after a **real ChatGPT Chat** tool call is witnessed mark `GATEWAY-P2-002` VERIFIED (LIVE). Event-triggered wake of an arbitrary existing Chat A is a separate P4 proof, not entailed by P2.

## Evidence gap / blockers

- `ACCOUNT_UI_UNVERIFIED`: no direct observation of custom MCP server setup on the current user's ChatGPT account.
- `ENDPOINT_ABSENT`: no approved running HTTPS endpoint/tunnel for this repository's server.
- `CHAT_CALL_ABSENT`: no MCP tool call observed from ordinary ChatGPT Chat.
- `DEPLOYMENT_NOT_AUTHORIZED`: ADR-0002 authorizes source/tests only; external exposure/hosting requires a separate scoped deployment decision and security review.

## Source references (reviewed 2026-11-14)

- [OpenAI Plugins MCP server build guide](https://developers.openai.com/plugins/build/mcp-server)
- [OpenAI Plugins quickstart (uses Work in test walkthrough)](https://developers.openai.com/plugins/quickstart)
- [OpenAI MCP server and UI quickstart (describes add custom MCP server)](https://developers.openai.com/plugins/build/app-quickstart)
- [ChatGPT Learn — MCP setup surfaces](https://learn.chatgpt.com/docs/extend/mcp)
- [OpenAI Help — Plugins in ChatGPT and Codex (plan/role/surface eligibility)](https://help.openai.com/en/articles/20001256-plugins-in-chatgpt)
- [OpenAI Secure MCP Tunnel guide](https://developers.openai.com/api/docs/guides/secure-mcp-tunnels)

This report intentionally separates documentation from personal-account evidence; it does **not** claim successful external deployment, ChatGPT connectivity or exact Chat A messaging.
