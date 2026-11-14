# MCP Gateway — canonical roadmap

**Last reconciled: 2026-11-14.** Canonical source: [`trung-via/mcp-gateway`](https://github.com/trung-via/mcp-gateway), branch `main`. A repo commit, Issue, PR, CI run, plugin skill, and live MCP/ChatGPT effect are **different evidence tiers**.

## Status semantics

- `task_status`: `NOT_STARTED | IN_PROGRESS | BLOCKED | VERIFIED | RETIRED`
- `decision_status`: `PROPOSED | ACCEPTED | SUPERSEDED` (ADRs only)
- `evidence_tier`: `DESIGN | CODE | TEST | LIVE | UNVERIFIED`
- `VERIFIED` refers only to the expressly named acceptance objective. It is **not** proof of production deployment or model/provider execution.

## P0 — foundation and feasibility

| Task | Objective | Status | Evidence and next acceptance |
| --- | --- | --- | --- |
| `GATEWAY-P0-001` | Public repository `main` bootstrap | **VERIFIED (CODE)** | Repository existed, 14 initial files on baseline commit `90206124c1c04e754028a85a258ebcaee4b05e1c` |
| `GATEWAY-P0-002` | Bounded architecture and security decision | **VERIFIED (DESIGN)** | [ADR-0001](adr/0001-repository-and-boundaries.md), [ADR-0002](adr/0002-mcp-mvp-security-and-evidence.md) accepted for **read-only source/test MVP only**; no host/write/deploy permission |
| `GATEWAY-P0-003` | Brain plugin GitHub-first continuity | **VERIFIED (PLUGIN SOURCE)** | MCP Gateway Brain `v0.1.1`, release `pluginrel_6af82bff4c0081919d39246fc6407d1f`; actual cross-chat behavior still requires test |
| `GATEWAY-P0-004` | Check real ChatGPT Chat custom MCP path and entitlement | **IN_PROGRESS (DOC)** | [Issue #2](https://github.com/trung-via/mcp-gateway/issues/2); actual account/surface proof pending; do not block P1 source work |

## P1 — protocol and first read-only MCP tool

| Task | Objective | Status | Acceptance |
| --- | --- | --- | --- |
| `GATEWAY-P1-001` | Choose SDK/protocol/transport and contract | **VERIFIED (DESIGN)** | Python `mcp==2.3.0`, Streamable HTTP localhost `/mcp`, modern MCP 2026-07-28 and compatibility with prior `initialize` clients, [gateway_health v1 contract](../contracts/tools/gateway_health.v1.md) |
| `GATEWAY-P1-002` | Implement `gateway_health` MCP server and negative tests | **IN_PROGRESS (CODE + TEST)** | [Issue #1](https://github.com/trung-via/mcp-gateway/issues/1); [Draft PR #3](https://github.com/trung-via/mcp-gateway/pull/3), head `a101fc5a339b72c1a4f115d270c6dff597c41db9`; **6 Python tests passed + Streamable HTTP smoke passed** [Windows CI run](https://github.com/trung-via/mcp-gateway/actions/runs/43582404606). Merge/ChatGPT connection not done. |
| `GATEWAY-P1-003` | CI verification and Brain source acceptance | **IN_PROGRESS (TEST)** | Windows CI on exact PR head **PASS**: [run #43582404606](https://github.com/trung-via/mcp-gateway/actions/runs/43582404606), job `132409733091`. PR source review and acceptance/merge remain separate; no implied live ChatGPT connection. |

## P2 — real ChatGPT Chat integration

| Task | Objective | Status | Acceptance |
| --- | --- | --- | --- |
| `GATEWAY-P2-001` | Connect or publish MCP app via supported ChatGPT surface | **NOT_STARTED** | Verified account entitlement and exact connection path; tool discovery observed in ChatGPT |
| `GATEWAY-P2-002` | Live `gateway_health` call from ChatGPT Chat | **NOT_STARTED** | User Chat requests tool; tool invocation/response observed in same conversation |
| `GATEWAY-P2-003` | Authentication and failure behavior (as applicable) | **NOT_STARTED** | Wrong endpoint, service unavailable, malformed tool request produce bounded errors; do not infer public health requires OAuth |

## P3 — separate adapters / least-privilege capabilities

| Task | Objective | Status | Acceptance |
| --- | --- | --- | --- |
| `GATEWAY-P3-001` | GitHub read-only adapter | **NOT_STARTED** | Exact repo/PR scoped reads, denied outside grant |
| `GATEWAY-P3-002` | Windows Host Agent read-only diagnostics | **NOT_STARTED** | Explicit host policy; positive/negative native receipts |
| `GATEWAY-P3-003` | Per-principal/project/tool/resource ACL | **NOT_STARTED** | Validated OAuth identity and fail-closed access boundaries |
| `GATEWAY-P3-004` | Optional bounded write/execute | **NOT STARTED — SEPARATE APPROVAL** | Individually authorized, receipt/idempotency and dangerous-action review; no universal host superuser |

## P4 — origin/events (independent research branch)

| Task | Objective | Status | Acceptance |
| --- | --- | --- | --- |
| `GATEWAY-P4-001` | Correlate request/session/job/route without privilege confusion | **NOT_STARTED** | Distinct identifiers, TTL, authenticated principal and denial tests |
| `GATEWAY-P4-002` | Official subscribed Events/Work/Dots feasibility | **NOT_STARTED** | Subscription, delivery and actual task completion tested separately |
| `GATEWAY-P4-003` | Optional CDP Host bridge for exact Chat A | **NOT_STARTED** | Target registration, exact route, send/readback and duplicate/unknown-effect safety |

## P5 — reliability and release

| Task | Objective | Status | Acceptance |
| --- | --- | --- | --- |
| `GATEWAY-P5-001` | Timeouts, resilience, audit/observability and fault testing | **NOT_STARTED** | Verified fault-injection cases, redacted logs and retries without duplicate effects |
| `GATEWAY-P5-002` | Deployment/security review, release, rollback | **NOT_STARTED** | Pinned version, access review, documented recovery; *no* premature production claim |

## Critical-path boundaries

- P0-004 can proceed in parallel with P1. Do **not** block implementation on speculative Chat A wake, mobile support or production hosting.
- P1's local MCP client/CI tests **cannot** complete P2. P2 needs an observed ChatGPT Chat tool invocation.
- P3 adapters and P4 events are separate projects/owners within the Gateway roadmap; no assumed Chrome ownership transfer.
- Create actionable GitHub Issues only for near-term work, keep full future breakdown here. Do not assign remote executor or claim background runs without a real dispatch receipt.
- Source and static docs remain public; private credentials, ChatGPT URLs and Windows host details stay outside this repository.

## Official implementation references

- [MCP Python v2 SDK](https://py.sdk.modelcontextprotocol.io/), [Tool annotations](https://py.sdk.modelcontextprotocol.io/servers/tools/)
- [OpenAI MCP plugin server guide](https://developers.openai.com/plugins/build/mcp-server)
- [MCP Python SDK releases](https://github.com/modelcontextprotocol/python-sdk/releases)
