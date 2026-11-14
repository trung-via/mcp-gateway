# MCP Gateway canonical work tree

Last source reconciliation: **2026-11-14**.

## Verified project baseline

- **P0-001 VERIFIED:** [`trung-via/mcp-gateway`](https://github.com/trung-via/mcp-gateway) exists, is **PUBLIC**, and the default branch is `main`.
- The initial Git tree `90206124c1c04e754028a85a258ebcaee4b05e1c` contains **14 starter files**, including README, SECURITY, architecture, ADR-0001, roadmap, work tree, contracts and tests placeholders.
- MCP Gateway Brain is a separate skills-only planning/review plugin. CDP Host and AI Commerce are separate projects.
- **UNVERIFIED / NOT BUILT:** a live MCP endpoint, a running host agent, GitHub/Windows runtime adapters, ChatGPT live tool-call evidence, or any event that proactively targets Chat A.

## Tasks and handoffs

| ID | Scope | Status | Owner | Next acceptance |
| --- | --- | --- | --- | --- |
| `GATEWAY-P0-001` | Public repo and baseline | **VERIFIED 2026-11-14** | Bootstrap / GitHub | No further action |
| `GATEWAY-P0-002` | Architecture and permission policy | **REVIEWED DRAFT** | Gateway Brain | Review [ADR-0002](adr/0002-mcp-mvp-security-and-evidence.md); record accepted/rejected/deferred decisions |
| `GATEWAY-P1-001` | Read-only MCP `gateway_health` | **NOT STARTED** | Engineering | Tested initialize/list/call, schemas, negative tests, CI evidence |
| `GATEWAY-P2-001` | Real ChatGPT Chat connection | **NOT STARTED** | Gateway Brain + Engineering | Real invocation witness with exact tool/result |
| `GATEWAY-P3-001` | Windows/GitHub adapters | **NOT STARTED** | Engineering + Security | Per-project grants and negative permission tests |
| `GATEWAY-P4-001` | Events/origin/Chat A feasibility | **NOT STARTED** | Gateway Brain | Distinguish MCP tool response from proactive exact-chat message |
| `GATEWAY-P5-001` | Reliability and release | **NOT STARTED** | Engineering + Brain | Failure tests and source-pinned release evidence |

## Bounded Engineering handoff for P1 (proposal; no executor invoked)

```yaml
kind: GATEWAY_TASK_V1
task_id: GATEWAY-P1-001
intent: Implement a minimal read-only MCP server and gateway_health tool
source: trung-via/mcp-gateway
scope:
  include:
    - MCP initialize, tools/list, tools/call for gateway_health
    - exact empty input JSON Schema and stable structured response
    - positive and malformed/unknown-tool/invalid-input tests
    - pinned dependencies and repeatable test command
  exclude:
    - GitHub write, Windows shell, CDP, host permissions
    - proprietary secrets and personal account data
    - autonomous or proactive ChatGPT wake-up
authority: SOURCE_AND_TEST_ONLY
acceptance:
  - repeatable local protocol and schema tests
  - prove read-only side-effect constraints
  - independently review exact commit and CI evidence
```

## Evidence rules

- `CODE`: exact Git commit/blob, not a claimed live effect.
- `TEST`: repeatable test run with identified revision/environment.
- `LIVE`: directly observed MCP/ChatGPT or native effect in the target surface.
- `DESIGN`: architecture, proposed tools, and ADRs awaiting decisions.
- `UNKNOWN_EFFECT_NO_RETRY`: potentially effectful result is ambiguous; reconcile read-only first.

No issue/PR numbers are assumed to exist. Keep exact issue/PR links, commit SHAs and live receipts here after they actually exist.
