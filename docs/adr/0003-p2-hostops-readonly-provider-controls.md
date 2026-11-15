# ADR-0003 (PROPOSED): Private HostOps transport for bounded P2 provider control

Status: **PROPOSED — source only, NO HostOps runtime authority**
Date: 2026-11-15
Related: [Issue #9](https://github.com/trung-via/mcp-gateway/issues/9), [ADR-0002](0002-mcp-mvp-security-and-evidence.md).

## Context

ADR-0002 denies arbitrary Windows execution in the public MCP P1/P2 tool surface. The owner additionally requested read-only IPv6 checker diagnostics via HostOps without manual Human PowerShell. This is a narrowly scoped internal diagnostic request, not a grant to ChatGPT MCP clients, generic GitHub Issues, AI Commerce HostOps or untrusted code.

The canonical MCP Gateway GitHub repository is public. GitHub warns against attaching self-hosted runners to public repositories because untrusted PR/workflow code can compromise the native machine. This remains a threat even when an individual workflow attempts to gate issue_comment triggers: the runner's broader repository scope must be considered.

Source: https://docs.github.com/en/actions/reference/security/secure-use

## Proposed separation

Public MCP Gateway repo owns ONLY:
- The fixed zero-argument PowerShell 7 source for checking TCPData and Check-Host against public ipv6.google.com:443.
- A machine-readable allowlist contract, offline mocked tests, non-native GitHub-hosted CI, architecture and sanitized public receipt schema.
- No self-hosted runner reference or native issue-comment workflow.

A separately approved **private HostOps execution transport** owns:
- Native runner registration, authentication, operation allowlist and exact SHA-pinned source ingestion.
- Invocation of this single operation under a non-administrative Windows identity with bounded network-only effects.
- Sanitized, correlated receipt transport back to MCP Gateway Issue #9. No raw runner logs, user IP, local paths or credentials in public.

This must not silently reuse or modify AI Commerce HostOps; a cross-project adapter, if desired, needs its own authority and code review. A source PR is not a registered operation or native effect.

## Acceptance

Before this proposal can become an accepted and operating contract: independently review source/CI, select and authorize the private transport (new dedicated private infrastructure vs existing explicitly approved private HostOps), establish native runner identity and exact repository/operation grants, and obtain one genuine completed native receipt. Failure of any gate is BLOCKED_NO_REGISTERED_PRIVATE_HOSTOPS; do not ask Human to execute PowerShell instead.

No public inbound 443, firewall changes, Caddy, DNS, ACME, MCP/CDP exposure, tunneling or unrestricted machine rights are authorized by this ADR.
