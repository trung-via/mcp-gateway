# ADR-0001: Independent public repository and trust boundaries

Status: accepted for repository visibility; architecture details remain proposed
Date: 2026-11-14

## Context

The user chose a dedicated `trung-via/mcp-gateway` GitHub repository and explicitly requested **public** visibility. MCP Gateway, CDP Host, and AI Commerce have different responsibilities and should not share unrestricted execution authority.

## Decision

- Use a dedicated public repository for MCP Gateway source, roadmap, contracts and test receipts.
- Keep credential material, private data and machine-specific secrets outside the repository.
- Build read-only, tightly scoped tools before any write-capable adapter.
- Keep CDP Host ownership of Chrome browser automation separate.

## Consequences

- Source and design decisions can be publicly audited.
- Secrets management and authorization remain necessary despite public visibility.
- Future changes in deployment / event delivery require separate ADRs and tests.
