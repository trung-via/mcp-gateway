# MCP Gateway — canonical roadmap

Reconciled: **2026-11-14**, public [`trung-via/mcp-gateway`](https://github.com/trung-via/mcp-gateway) (`main`). An Issue, PR, source commit, CI run and live tool call are separate evidence tiers.

## Status definitions

- `task_status`: `NOT_STARTED | IN_PROGRESS | BLOCKED | VERIFIED | RETIRED`.
- `decision_status` (ADR only): `PROPOSED | ACCEPTED | SUPERSEDED`.
- `evidence_tier`: `DESIGN | CODE | TEST | LIVE | UNVERIFIED`.
- `VERIFIED` always applies to a named acceptance objective, **not** an entire production system.

## P0 — Foundation and ChatGPT surface feasibility

| ID | Objective | Task status / evidence | Proof / next dependency |
| --- | --- | --- | --- |
| `GATEWAY-P0-001` | Public repository bootstrap | **VERIFIED / CODE** | Repo `main`, baseline `90206124c1c04e754028a85a258ebcaee4b05e1c` (14 starter files) |
| `GATEWAY-P0-002` | Architecture and read-only security boundary | **VERIFIED / DESIGN** | [ADR-0001](adr/0001-repository-and-boundaries.md), [ADR-0002](adr/0002-mcp-mvp-security-and-evidence.md), read-only test-only authorization |
| `GATEWAY-P0-003` | Brain plugin GitHub-first continuity | **VERIFIED / CODE (plugin source)** | MCP Gateway Brain v0.1.1, release `pluginrel_6af82bff4c0081919d39246fc6407d1f`; cross-chat behavior not independently tested |
| `GATEWAY-P0-004` | Verify actual ChatGPT Chat MCP connection path | **BLOCKED / LOCAL LIVE MCP (not ChatGPT LIVE)** | [Issue #2 open](https://github.com/trung-via/mcp-gateway/issues/2). **Human laptop proof PASS:** MCP Client discovery, `gateway_health` response and `INVALID_PARAMS` at `http://127.0.0.1:8000/mcp` (2026-11-14); separate Windows CI [40 tests PASS](https://github.com/trung-via/mcp-gateway/actions/runs/43587666927). IPv6 outbound HTTPS **PASS**; dynv6 AAAA public DNS query **PASS** and local privacy-preserving IPv6 comparison **MATCH** (user-observed 2026-11-15); **IPv6 inbound, TLS, firewall and ChatGPT Chat call unverified**. Primary: laptop + normal Chat Server URL; no Tunnel/Work. [Next safe preflight](worktree.md#ipv6-address-selection-evidence--2026-11-14): **P2 local Host allowlist PASS:** valid Host HEAD 405, unauthorized Host HEAD 421 (repeated), user-observed 2026-11-15. **LOCAL_TLS_ROUTING_SMOKE_PASS**: Caddy listening only `127.0.0.1:8443`, human-reported HTTPS HEAD returned 405 with local CA test exception (`-k`). **LOCAL_HTTPS_MCP_TOOL_CALL_PASS / USER_LIVE 2026-11-15:** through Caddy internal TLS, JSON-RPC initialize 200, initialized notification 202, `gateway_health` 200 with `isError=false` and exact `structuredContent`. Still NO public trust/inbound IPv6/ChatGPT call. **Windows firewall/listener read-only preflight 2026-11-15:** Domain/Private/Public Enabled, persistent `DefaultInboundAction=NotConfigured` (effective rule result unknown); only loopback listeners 8443/18080, none at 80/443. **ActiveStore verified 2026-11-15:** Wi-Fi Private + IPv6 Internet; Domain/Private/Public Windows Firewall all Enabled, effective DefaultInboundAction Block. Next: inspect router IPv6 inbound policy and existing Windows TCP 443 allow rules read-only; public 443 listener, ACME cert, external IPv6 ChatGPT proof still unverified and require scoped approval. Render code optional only. |

## P1 — Read-only MCP core

| ID | Objective | Task status / evidence | Proof |
| --- | --- | --- | --- |
| `GATEWAY-P1-001` | SDK, protocol, transport and tool contract | **VERIFIED / DESIGN** | Python `mcp==2.3.0`, Streamable HTTP loopback `/mcp`, modern and legacy-compatible tests, [gateway_health contract](../contracts/tools/gateway_health.v1.md) |
| `GATEWAY-P1-002` | Implement minimal server + strict negative tests | **VERIFIED / CODE + TEST** | [Issue #1 closed](https://github.com/trung-via/mcp-gateway/issues/1), [PR #3 merged](https://github.com/trung-via/mcp-gateway/pull/3), squash commit `cabdb994bcb342d4b258adc468eafda2c40c3501`. 6 tests + HTTP smoke pass, including `INVALID_PARAMS` |
| `GATEWAY-P1-003` | Windows CI and source acceptance | **VERIFIED / TEST** | [PR head CI PASS](https://github.com/trung-via/mcp-gateway/actions/runs/43583208001) at `a8d1f419eb3fa6b014f6a3a1499d45187bd1cf84`; [main CI PASS](https://github.com/trung-via/mcp-gateway/actions/runs/43583364258) at merge commit `cabdb994...` |

**P1 is complete at source and CI tier, not deployed/service-live tier.**

## P2 — Real ChatGPT Chat integration

| ID | Objective | Status | Acceptance |
| --- | --- | --- | --- |
| `GATEWAY-P2-001` | Create/connect a supported MCP plugin to a reachable HTTPS endpoint | **NOT_STARTED** | Exact account/surface/permissions and tool discovery observed; no private host access |
| `GATEWAY-P2-002` | Invoke `gateway_health` from normal ChatGPT Chat | **NOT_STARTED** | Real tool request/response observed in target Chat; model answer matches expected schema |
| `GATEWAY-P2-003` | Test error handling and auth boundary | **NOT_STARTED** | Offline endpoint, invalid arguments, unknown tool, wrong connection produce safe outcomes |

## P3 — Scoped adapters (independent)

| ID | Objective | Status |
| --- | --- | --- |
| `GATEWAY-P3-001` | GitHub read-only adapter | NOT_STARTED |
| `GATEWAY-P3-002` | Windows Host Agent read-only status | NOT_STARTED |
| `GATEWAY-P3-003` | Per-project/caller/tool/resource ACL + OAuth for private data | NOT_STARTED |
| `GATEWAY-P3-004` | Optional bounded write/execute with grants and native receipts | NOT_STARTED — separate decision |

## P4 — Session correlation and optional wake (separate research track)

| ID | Objective | Status |
| --- | --- | --- |
| `GATEWAY-P4-001` | Bind session/correlation IDs without treating them as identity | NOT_STARTED |
| `GATEWAY-P4-002` | Official subscribed MCP Events in supported Work/dot surfaces | NOT_STARTED |
| `GATEWAY-P4-003` | Optional CDP Host route to exact Chat A with identity/send receipts | NOT_STARTED |

## P5 — Reliability and release

| ID | Objective | Status |
| --- | --- | --- |
| `GATEWAY-P5-001` | Timeouts, retries, audit, observability, failure tests | NOT_STARTED |
| `GATEWAY-P5-002` | Deployment, security review, rollback, release | NOT_STARTED |

## Sequencing and authority

P0-004 research may proceed in parallel with source. The **primary user-approved direction** is normal ChatGPT Chat → public HTTPS Server URL → Windows laptop MCP Gateway. Do not assume inbound reachability: the user reported public IPv4 egress, but router WAN was not obtainable by UPnP, and candidate local TCP listeners are absent. IPv6 outbound and MCP loopback tool-call tests have now passed on the human's laptop; next assess IPv6 address stability, DNS AAAA, secure HTTPS reverse proxy, router/Windows inbound firewall and only read-only gateway_health exposure. **Do not propose Tunnel, tunnel-like forwarding, Work or Render as default.** Managed-host blueprint is optional fallback code only, not deployed. Security-sensitive port or firewall changes require explicit scoped approval. CI ≠ live ChatGPT tool-call evidence; no CDP 9444 or private adapters are exposed.
