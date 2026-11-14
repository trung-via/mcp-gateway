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
| `GATEWAY-P0-004` | Verify actual ChatGPT Chat MCP connection path | **BLOCKED / CODE + TEST + DOC, not LIVE** | [Issue #2 remains open](https://github.com/trung-via/mcp-gateway/issues/2), [PR #4 merged](https://github.com/trung-via/mcp-gateway/pull/4), [Windows main CI PASS](https://github.com/trung-via/mcp-gateway/actions/runs/43584905472) at `bf7b649ea05429656c7345d98f58ba96c59ceb8b`; 20 tests + loopback MCP probe. [P2 connection runbook](p2-connection-runbook.md). UI **Add custom MCP server** confirmed by user screenshot. Need independently hosted HTTPS **Server URL** endpoint and **normal ChatGPT Chat** invocation; **no Tunnel or Work**. |

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

P0-004 account/transport research may proceed in parallel with code. The **next executable goal** is a bounded P2 connection experiment via normal ChatGPT Chat + independent HTTPS **Server URL** hosting. The custom MCP creation UI has been confirmed by user screenshot; hosting still requires a separate scoped security and deployment decision. **Do not propose Tunnel, tunnel-like forwarding, or Work for P2.** CI on GitHub cannot prove ChatGPT Chat invoked MCP; an MCP tool result in current Chat does not prove proactive messaging to an existing Chat A. Keep CDP Host and AI Commerce independent; do not grant universal Windows or GitHub write rights from a prompt.
