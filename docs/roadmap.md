# MCP Gateway roadmap

Evidence snapshot: 2026-11-14. The live canonical source is [`trung-via/mcp-gateway`](https://github.com/trung-via/mcp-gateway) on `main`. **A source commit is not a deployed MCP server or a ChatGPT invocation proof.**

| Phase / task | Objective | Acceptance evidence | Status |
| --- | --- | --- | --- |
| P0-001 | Public repository bootstrap | Live GitHub repository visible; `main` populated with 14 starter files (baseline tree `90206124c1c04e754028a85a258ebcaee4b05e1c`) | **VERIFIED — 2026-11-14** |
| P0-002 | Review architecture, trust boundaries and MCP tool permission policy | [ADR-0001](adr/0001-repository-and-boundaries.md), [ADR-0002](adr/0002-mcp-mvp-security-and-evidence.md), security checklist; decision explicitly recorded | **REVIEWED DRAFT — policy proposal awaits acceptance** |
| P1-001 | Read-only MCP proof of concept: `gateway_health` | MCP initialize/list/call, JSON Schema validation, side-effect denial, negative tests, reproducible CI | **NOT STARTED** |
| P2-001 | ChatGPT Chat interoperability | Authenticated or deliberately anonymous-as-scoped real Chat tool invocation with request/response witness | **NOT STARTED** |
| P3 | Independently authorized Windows and GitHub adapters | Server-side per-project policy, adapter permission denial tests, redacted receipts | **NOT STARTED** |
| P4 | Event/origin correlation and optional CDP Host bridge | Explicit exact-chat feasibility findings; no assumptions from tool response or session metadata | **NOT STARTED** |
| P5 | Reliability, operational readiness and release | Fault tests, observability, security review, deploy/release checklist | **NOT STARTED** |

## Sequencing

1. P0-001 is complete. No further repo creation or re-bootstrap is needed.
2. P0-002 has a security/architecture proposal; validate outstanding policy decisions without treating draft documentation as deployment authorization.
3. The next bounded Engineering task is P1-001: implement **one** low-risk, read-only `gateway_health` MCP tool in a reviewable branch, then demonstrate local protocol tests and negative tests. This does not require laptop administrator rights, a new queue or CDP automation.
4. P2 requires an **actual ChatGPT Chat** invocation; a successful CLI/MCP Inspector test does not satisfy P2.
5. The event-to-exact-chat problem is separate and must not block P1/P2.

## Source and authority rules

- **VERIFIED** means authenticated GitHub evidence, exact commit/test receipt or observed runtime effect at the appropriate tier.
- **REVIEWED DRAFT** means a proposed architectural decision, **not** human acceptance or a grant.
- **UNKNOWN** means unresolved state; no blind retries of potentially effectful operations.
- Brain plugin skills guide planning and review; they do not deploy an MCP server, run Windows commands or create external events by themselves.
