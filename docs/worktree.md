# MCP Gateway — canonical Work Tree

Reconciled: **2026-11-14**. Canonical source: [`trung-via/mcp-gateway`](https://github.com/trung-via/mcp-gateway) on `main`. Read current GitHub Issue/PR/CI before claiming any newer status.

## Verified records

| Task | Status / evidence | Exact record |
| --- | --- | --- |
| `GATEWAY-P0-001` | VERIFIED / CODE | Public repo + baseline `90206124c1c04e754028a85a258ebcaee4b05e1c` |
| `GATEWAY-P0-002` | VERIFIED / DESIGN | ADR-0001 and ADR-0002 accepted for bounded read-only MVP only |
| `GATEWAY-P0-003` | VERIFIED / CODE (plugin source) | MCP Gateway Brain v0.1.1; cross-chat sync unverified |
| `GATEWAY-P0-004` | BLOCKED / DOC | [Issue #2](https://github.com/trung-via/mcp-gateway/issues/2), [research report](research/chatgpt-mcp-connection-feasibility-2026-11-14.md); account UI and endpoint unavailable for live proof |
| `GATEWAY-P1-001` | VERIFIED / DESIGN | `mcp==2.3.0`, [gateway_health contract](../contracts/tools/gateway_health.v1.md) |
| `GATEWAY-P1-002` | VERIFIED / CODE + TEST | [Issue #1 closed](https://github.com/trung-via/mcp-gateway/issues/1); [PR #3 merged](https://github.com/trung-via/mcp-gateway/pull/3); merge commit `cabdb994bcb342d4b258adc468eafda2c40c3501` |
| `GATEWAY-P1-003` | VERIFIED / TEST | [Windows PR CI PASS](https://github.com/trung-via/mcp-gateway/actions/runs/43583208001) and [main CI PASS](https://github.com/trung-via/mcp-gateway/actions/runs/43583364258): 6 tests + Streamable HTTP positive/invalid-params smoke |

## Result for completed P1 Engineering task

```yaml
kind: GATEWAY_RESULT_V1
task_id: GATEWAY-P1-002
source: trung-via/mcp-gateway
issue: https://github.com/trung-via/mcp-gateway/issues/1
pr: https://github.com/trung-via/mcp-gateway/pull/3
head_sha: a8d1f419eb3fa6b014f6a3a1499d45187bd1cf84
merge_sha: cabdb994bcb342d4b258adc468eafda2c40c3501
tests:
  python_in_process: "6 passed on Windows"
  streamable_http: "PASS (positive and INVALID_PARAMS)"
  ci_pr: https://github.com/trung-via/mcp-gateway/actions/runs/43583208001
  ci_main: https://github.com/trung-via/mcp-gateway/actions/runs/43583364258
proven: SOURCE_AND_CI_ONLY
not_proven:
  - live user laptop MCP server
  - public HTTPS endpoint, deployed service or tunnel
  - connected ChatGPT plugin and normal Chat tool invocation
  - Windows/GitHub adapter, write/host permissions or exact Chat A wake
```

## Active task — GATEWAY-P0-004 / Issue #2

```yaml
kind: GATEWAY_TASK_V1
task_id: GATEWAY-P0-004
owner: MCP Gateway Brain + Integration
source: trung-via/mcp-gateway
issue: https://github.com/trung-via/mcp-gateway/issues/2
goal: Verify how this account can connect a real MCP tool in normal ChatGPT Chat
allowed:
  - source-led capabilities research
  - read-only eligibility / available ChatGPT connection UI assessment
  - documented tunnel/HTTPS choices and security approval proposal
forbidden_without_separate_approval:
  - deploy public endpoint or register paid hosting
  - expose Windows/CDP/host-admin ports or secrets
  - alter AI Commerce/CDP Host
  - mark P2 LIVE without an observed ChatGPT tool call
acceptance:
  - exact account/surface entitlement evidence
  - approved reachable MCP endpoint or supported private tunnel
  - discovered gateway_health in connected plugin
  - successful ChatGPT Chat tool call with receipt
status: BLOCKED_LIVE_PROOF
```

## Continuity rules

- Task `NOT_STARTED | IN_PROGRESS | BLOCKED | VERIFIED | RETIRED`; ADR `PROPOSED | ACCEPTED | SUPERSEDED`; evidence `DESIGN | CODE | TEST | LIVE | UNVERIFIED`. These fields are separate.
- Do not infer executor dispatch from Issue creation, merge from PR creation, live deployment from CI, or Chat A wake from a synchronous tool reply.
- Capture exact GitHub revision, date and non-secret test receipt; unknown effect = `UNKNOWN_EFFECT_NO_RETRY` until read-only reconciliation.
- No active work should remain assigned to an already closed Issue #1. Next focus is [Issue #2](https://github.com/trung-via/mcp-gateway/issues/2).
