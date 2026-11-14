# MCP Gateway — canonical Work Tree

Last reconciled: **2026-11-14**. Repo: [`trung-via/mcp-gateway`](https://github.com/trung-via/mcp-gateway), public `main`. Consult live Issue/PR/source before reporting progress.

## Confirmed state

- `GATEWAY-P0-001`: **VERIFIED / CODE**. Public repo with 14 starter files from baseline commit `90206124c1c04e754028a85a258ebcaee4b05e1c`.
- `GATEWAY-P0-002`: **VERIFIED / DESIGN**. ADR-0002 accepted for bounded read-only prototype only. Any host execution, GitHub write or private data access remains unapproved.
- `GATEWAY-P0-003`: **VERIFIED / PLUGIN SOURCE**. MCP Gateway Brain `v0.1.1`, release `pluginrel_6af82bff4c0081919d39246fc6407d1f`; actual cross-chat freshness behavior has not been tested.
- `GATEWAY-P0-004`: **IN_PROGRESS / DOC**. [Issue #2](https://github.com/trung-via/mcp-gateway/issues/2) is the ChatGPT surface connection feasibility probe.
- `GATEWAY-P1-001`: **VERIFIED / DESIGN**. `mcp==2.3.0` and `gateway_health` contract accepted for local read-only MVP; no runtime claim.
- `GATEWAY-P1-002`: **IN_PROGRESS / ISSUE ONLY**. [Issue #1](https://github.com/trung-via/mcp-gateway/issues/1) created for source/tests.
- **No live MCP Gateway endpoint, production deployment, Windows adapter, GitHub adapter or exact Chat A wake has been verified.** P2 through P5 remain unimplemented unless later source/receipts prove otherwise.

## Task / decision / evidence triad

| Field | Accepted values | Meaning |
| --- | --- | --- |
| `task_status` | NOT_STARTED, IN_PROGRESS, BLOCKED, VERIFIED, RETIRED | Delivery state of **one** task |
| `decision_status` | PROPOSED, ACCEPTED, SUPERSEDED | ADR status only; not executable permission by itself |
| `evidence_tier` | DESIGN, CODE, TEST, LIVE, UNVERIFIED | What was *actually* observed |

**A created Issue does not imply an executor was called. A PR or CI success does not imply an MCP server was deployed. A tool reply in ChatGPT does not imply events can message an arbitrary Chat A.**

## Active bounded Engineering task

```yaml
kind: GATEWAY_TASK_V1
task_id: GATEWAY-P1-002
source: trung-via/mcp-gateway
base_ref: main
source_pin: use exact base commit when creating branch
owner: Engineering
decision: docs/adr/0002-mcp-mvp-security-and-evidence.md
contract: contracts/tools/gateway_health.v1.md
issue: https://github.com/trung-via/mcp-gateway/issues/1
goal: Read-only MCP Python server, gateway_health, protocol tests and Windows CI
scope:
  allowed:
    - src/gateway/ and P1 package/run instructions
    - tests/ and focused dependency/test configuration
    - .github/workflows/ focused Python validation
  forbidden:
    - arbitrary shell tool or remote laptop execution
    - GitHub write tools, project/private data, credential files
    - CDP Host/WakeHub changes or proactive chat injection
    - production deployment, paid services or admin account changes
implementation:
  language: Python
  sdk: mcp==2.3.0
  transport: streamable-http
  endpoint: /mcp (loopback-only for local test)
  protocol:
    modern: MCP 2026-07-28 server/discover
    legacy: compatible initialize path tested where supported
verification:
  - in-process tool list and response-schema checks
  - error on extra input and unknown tool
  - HTTP/streamable MCP smoke if available
  - no unapproved side effects or secrets
  - Windows CI at exact PR HEAD
result:
  required:
    - task_id
    - branch_and_commit_sha
    - PR_and_CI_run_URL
    - observed_test_results
    - scope_and_security_review
    - exact_blockers_and_next_action
authority: SOURCE_AND_TEST_ONLY
```

## Current near-term queue

1. [#1](https://github.com/trung-via/mcp-gateway/issues/1): build P1 read-only MCP prototype and produce a PR; accept only after source and tests.
2. [#2](https://github.com/trung-via/mcp-gateway/issues/2): validate ChatGPT Chat/plugin/transport feasibility independently of P1 code.
3. P1-003: inspect Windows CI on exact PR head; update the Work Tree only with actual CI receipts.
4. P2: connect a working tool to ChatGPT and obtain a real invocation witness.
5. P3/P4/P5: remain roadmap tasks; create Issues when dependencies are concrete.

## Decision registry

- [ADR-0001](adr/0001-repository-and-boundaries.md): Public repo and separate project boundaries, accepted.
- [ADR-0002](adr/0002-mcp-mvp-security-and-evidence.md): Bounded read-only MVP, accepted 2026-11-14; no production or write grants.

## Reconciliation rules

- Fetch canonical GitHub on each review; stale plugin references cannot override live source.
- Keep exact task IDs, related Issue/PR URLs and head SHA plus status/evidence per task. Prefer updating a concrete blocker to creating more meta-work.
- Unknown write effects: `UNKNOWN_EFFECT_NO_RETRY` and read-only reconciliation.
- Record tests and runtime witnesses separately; never manufacture results. Use smallest effective next action.
