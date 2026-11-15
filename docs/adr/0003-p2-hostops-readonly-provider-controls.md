# ADR-0003 (PROPOSED): Narrow P2 HostOps checker-control exception

Status: **PROPOSED — source candidate only, NOT an active HostOps permission**
Date: 2026-11-15
Related: [GATEWAY-P2-HOSTOPS-001 Issue #9](https://github.com/trung-via/mcp-gateway/issues/9), [ADR-0002](0002-mcp-mvp-security-and-evidence.md).

## Context

ADR-0002 disallows Windows execution as part of the public MCP P1/P2 tool surface. The owner subsequently requested that MCP Gateway's IPv6 checker diagnostics be run via HostOps rather than manual Human PowerShell. The new request does **not** authorize public MCP callers or untrusted issues to execute Windows commands.

## Proposed boundary

A dedicated source-registered, operator-initiated, **zero-argument** HostOps *internal* diagnostic may call only third-party public positive controls for ipv6.google.com:443. It does not add any MCP tool, Windows adapter, public remote command surface, or ongoing background daemon.

GitHub event identity (actor and issue) selects the fixed diagnostic but is not itself permission to issue arbitrary commands. A separately verified Windows HostOps runner with access to the specific repository and the reviewed operation must enforce its own native policy. The source is checked out from the trusted default branch; untrusted PR code never runs on this self-hosted runner.

All network controls and resulting public receipts are bounded/redacted. Internal HostOps activity and CI evidence are never conflated with a live ChatGPT MCP call.

## Merge and runtime acceptance

Before promoting beyond PROPOSED:
1. Review exact head and hosted CI/fixture results for allowlist, fail-closed and trigger restrictions.
2. Independently verify the Windows runner identity, label, repository access, execution policy and sanitized native receipt route.
3. Authorize a single bounded diagnostic invocation; check native receipt separately from Issue creation and GitHub workflow acknowledgment.

If missing, stay BLOCKED_NO_NATIVE_ROUTE. Do not change AI Commerce HostOps contracts implicitly or ask Human to run ad hoc scripts as a substitute.

This does NOT supersede ADR-0002 for MCP client tools, P2 exposure, authentication or project authorization; it proposes one internal HostOps exception contingent on the above gates.
