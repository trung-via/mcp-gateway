# ADR-0003 (ACCEPTED DESIGN): Dedicated private MCP Gateway HostOps

Status: **ACCEPTED (architecture only); RUNTIME=BLOCKED_NO_PRIVATE_RUNNER**
Date: 2026-11-15
Decision authority: MCP Gateway owner explicitly authorized a **dedicated private HostOps channel separated from AI Commerce** on 2026-11-15.
Related: [Issue #9](https://github.com/trung-via/mcp-gateway/issues/9), [PR #10](https://github.com/trung-via/mcp-gateway/pull/10), [ADR-0002](0002-mcp-mvp-security-and-evidence.md).

## Decision and boundaries

The public `trung-via/mcp-gateway` repository owns source, contracts, mocked Windows CI and independently reviewed public, **sanitized** status reports. It MUST NOT connect a self-hosted Windows runner or trigger native actions, including via PR, issue-comment, issue-opened or workflow_dispatch.

Create a **separate GitHub PRIVATE** owner-controlled execution repository, proposed locator `trung-via/mcp-gateway-hostops-private` (only an intended name, **NOT confirmed created**). HostOps state, workflows, native binding and any private receipt must stay there. Do not reuse or alter AI Commerce, CDP Host, or another project's runner, tokens, secrets, permits, labels or work directory.

GitHub cautions against self-hosted runners in public repos: https://docs.github.com/en/actions/reference/security/secure-use

### Initial operation

- Operation ID: `MCP_P2_IPV6_PROVIDER_CONTROL_READONLY_V1`.
- Input: exact empty object `{}`; no URL, command, path, script, host, target or port inputs.
- Effect: non-elevated Windows 11 / PowerShell 7, HTTPS requests only to the documented TCPData and Check-Host APIs for fixed public `ipv6.google.com:443`. No local endpoint probing.
- Return: bounded, enumerated counts and failure-stage code; no raw JSON, IP, hostname, private filesystem path, environment variable, access token or device identity.
- Native execution uses a **separate private-repo runner**, not an existing AI Commerce runner. No broad host shell, long-running listener, browser CDP or administrator grant.
- Review and pin the exact public diagnostic source and tests at a full commit SHA before copying/promoting any code to the private transport. No executing an untrusted PR checkout or arbitrary Issue content.

### Private dispatch design (implementation still pending)

1. Enroll an owner-controlled, single-purpose, non-administrator Windows runner in the **private repository only**, using an independent runner directory and Windows identity. Do not inherit AI Commerce runner labels or service state. Validate repository visibility and policy before enrollment.
2. Register exactly one operation with immutable workflow code and explicit owner authorization. Private Issue/event dispatch is acceptable only if actor/repository identity, operation ID, duplicate nonce and freshness are checked **before** any self-hosted job; untrusted Issue text MUST NOT become shell arguments or code. Provide deny tests for foreign actor, wrong operation, malformed schema, replay, expired request and unreviewed source.
3. Execute the fixed script with absolute timeouts, bounded outputs and a single-run concurrency lock. No public release token or cross-repository write secret is required for the first proof.
4. Persist a sanitized, correlated receipt **in the private control repository**. The MCP Gateway Brain may read that receipt via the authorized GitHub connector and separately summarize a safe count-only status in public Issue #9; do not grant a private workflow broad write authority to the public source repository.
5. Accept operation only after the sequence `PRIVATE_REPO_VERIFIED -> RUNNER_REGISTERED -> OWNER_AUTH_VERIFIED -> PRIVATE_DISPATCH_ACK -> WINDOWS_NATIVE_RECEIPT -> RECEIPT_INDEPENDENTLY_READ`. Each is independently evidenced; GitHub-hosted source CI is `TEST`, not `LIVE`.

## Explicit exclusions

No shared AI Commerce HostOps credentials/runner, GitHub App or PAT creation without a separate scoped enrollment, public self-hosted runners, arbitrary shell or input, admin privilege, Windows firewall, inbound TCP443, Caddy, router, DNS, Let's Encrypt/ACME, public MCP endpoint, CDP 9444, tunnels, network disclosure, or background service installation without an approved native enrollment method.

## Status as of decision

- Source/fixtures: [draft PR #10](https://github.com/trung-via/mcp-gateway/pull/10), Windows hosted CI passed at historical head `10a1edbed4eeaa607ab0c15df99e82e4dd1086b2`; this ADR update changes the branch SHA, so re-run/re-pin exact-head CI before any acceptance.
- Private repository: **NOT VERIFIED CREATED**.
- Native Windows runner, private dispatch and live receipt: **NOT ESTABLISHED**.
- The GitHub connector available to this Brain exposes file/Issue/PR writes but no `create_repository`, native runner enrollment or native Windows execution. Any browser UI repository creation needs an authenticated GitHub owner session. Host enrollment remains a separate one-time authorization/connectivity blocker.
- No Human-run PowerShell diagnostic requested; IPv6 P2 ingress/ACME trial remains prohibited without separately scoped authorization.
