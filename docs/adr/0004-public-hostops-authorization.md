# ADR-0004 — Public owner-operated MCP Gateway HostOps

Status: **ACCEPTED (owner visibility/authority decision)**, 2026-11-15  
Supersedes: [ADR-0003](0003-p2-hostops-readonly-provider-controls.md) **only as to private repository requirement and deployment destination**. The native evidence and bounded operation contract remain applicable until separately changed.

## Owner decision

The owner explicitly changed the HostOps repository to **Public** and requested broad operational authority for this personal project. HostOps remains **separate from AI Commerce**. Full rights are an owner authorization goal, not evidence that a Windows runner, administrator token or remote tool is already installed. We must not silently reuse a runner or credential from another project.

New repo: [trung-via/mcp-gateway-hostops](https://github.com/trung-via/mcp-gateway-hostops), visibility Public, owner GitHub admin verified.  
[Bootstrap PR #1](https://github.com/trung-via/mcp-gateway-hostops/pull/1) **MERGED** via squash commit `ed3b6fc8aa495a1625495ed754c87e9180c6b256`.

## Current installed source and evidence

- Fixed zero-input operation `MCP_P2_IPV6_PROVIDER_CONTROL_READONLY_V1`; source Git blob `1172099c35eccb56d694d9a3c2f4fa3a145aced5`.
- GitHub Actions `.github/workflows/mcp-p2-provider-readonly.yml`: public Issue opened trigger, GitHub-hosted Windows owner/sender/actor/exact-request/freshness/attempt admission, then **only if approved** self-hosted `mcp-gateway-hostops` runner.
- Hosted Windows CI [PR run #43686257233](https://github.com/trung-via/mcp-gateway-hostops/actions/runs/43686257233) **SUCCESS**; main push run [#43686308673](https://github.com/trung-via/mcp-gateway-hostops/actions/runs/43686308673) **SUCCESS**, testing offline fixtures and static host admission.
- Negative live transport test: owner-created malformed [Issue #2](https://github.com/trung-via/mcp-gateway-hostops/issues/2), body `{"probe":"deny"}`; [workflow run #43686329911](https://github.com/trung-via/mcp-gateway-hostops/actions/runs/43686329911) **SUCCESS**; hosted job output `MCP_HOSTOPS_HOSTOPS_AUTH=DENY`, native job **SKIPPED**. This proves GitHub event and rejection, **not** laptop execution.
- Repository Settings → Actions → Runners observed: **There are no runners configured**. `MCP_HOSTOPS_NATIVE_ROUTE=BLOCKED_NO_RUNNER`.

## Public runner constraints

GitHub documents risks of public-repository self-hosted runners. Owner chose Public despite that tradeoff; maintain exact-operation allowlists, authenticated owner admission and dedicated runner isolation. Public Issues must never carry secrets, IPv6 addresses, token values or arbitrary shell. Do not permit PR or fork code to run on the native laptop. Do not expose CDP 9444 or AI Commerce. No unrestricted command-exec tool is installed by this ADR.

## Next acceptance gate

1. Establish a distinct Windows host execution/enrollment mechanism and register runner `mcp-gateway-hostops` against the new repository; no human diagnostic PowerShell as fallback.
2. Independently verify runner online, owner identity and dedicated execution context.
3. Create a **new** exact owner request `MCP_P2_IPV6_PROVIDER_CONTROL_READONLY_V1` body `{}` and observe GitHub admission PASS, native job and sanitized Issue receipt.
4. Only after that proof, introduce separately registered, reviewed write/admin operations as requested by the owner. A claimed "full rights" label without a native grant is `UNVERIFIED`, not permission escalation.

No fourth ACME trial or public TLS/443 service is implied by this decision.
