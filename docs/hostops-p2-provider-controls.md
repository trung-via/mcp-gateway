# P2 HostOps IPv6 provider controls — private execution transport required

Status: **SOURCE ONLY / NOT REGISTERED / NO NATIVE EFFECT**.
Related: [Issue #9](https://github.com/trung-via/mcp-gateway/issues/9), [draft PR #10](https://github.com/trung-via/mcp-gateway/pull/10), [PR #7](https://github.com/trung-via/mcp-gateway/pull/7).

## Purpose and current evidence

The approved PR #7 one-time multi-source ingress attempt failed CLOSED during public provider preflight. Laptop port 443 and temporary firewall postcheck were 0/0, cleanup PASS. A subsequent manually relayed read-only public Check-Host control selected eight nodes but produced zero verifiable IPv6 node successes and zero distinct ASNs. This is **not** a router/ISP negative.

Owner directed MCP Gateway to use HostOps and not ask Human to run or relay any more PowerShell checks.

## Explicit operation contract

Source: scripts/hostops/p2-ipv6-provider-controls-readonly.ps1
Machine-readable contract: contracts/hostops/mcp-p2-ipv6-provider-control.v1.json

- Exact zero-argument operation MCP_P2_IPV6_PROVIDER_CONTROL_READONLY_V1.
- Only fixed public positive-control target ipv6.google.com:443 via TCPData/Check-Host. Providers may observe outbound source IP as an inherent property of HTTPS traffic, but the script never sends the laptop IPv6/hostname as the query target.
- At most 8 Check-Host nodes, 6 bounded result polls; classify remote IPv6/IPv4, errors, pending and malformed schema. Do not reinterpret zero nodes as a negative host ingress proof.
- Script outputs one sanitized MCP_P2_HOSTOPS_RECEIPT_V1 line. No raw response JSON, IP addresses, node identities, personal paths, usernames, tokens or secrets.
- No argument for arbitrary URL, IP, command, filesystem path or process; no Windows host inventory, Caddy, listener, Windows firewall, router access, ACME, DNS, MCP, CDP or private project data.

## Security: NEVER attach a self-hosted laptop runner directly to this public repository

GitHub explicitly cautions that self-hosted runners are generally unsuitable for public repositories because forked or untrusted code may compromise the machine and runner environment:

- https://docs.github.com/en/actions/reference/security/secure-use
- https://docs.github.com/en/actions/how-tos/manage-runners/self-hosted-runners/add-runners

The initial draft proposal to use a public-repo issue_comment-triggered self-hosted Windows runner was **REMOVED BEFORE MERGE** after security review. Source-only Windows CI on github-hosted windows-latest is allowed; it never contacts the laptop or a real external provider.

The authorized native path must be a separately secured, **private, owner-controlled HostOps execution transport** with its own checked source registration and least-privilege Windows runner, or an independently reviewed bounded adapter in an already trusted private HostOps service. **Do not silently reuse AI Commerce HostOps** or expand its standing read operation, which is not an arbitrary network shell.

## Gate to a real HostOps measurement

A live diagnostic may begin only after all gates are proven:
1. Private execution-transport ownership, runner registration, repo access and process identity verified independently. A public GitHub issue or PR alone is not dispatch.
2. Exact zero-argument operation registered and pinned to reviewed script SHA. Private dispatcher authenticates caller and enforces allowlisted operation, not prompt text or arbitrary GitHub Issue commands.
3. Host native policy admits the reviewed, non-elevated read-only script; no policy bypass, new credentials or unrestricted host grants.
4. Sanitized signed/correlated request and completed native receipt flow back to Issue #9, including run/job identifier, source SHA and enum-only public fields. Do not publish raw runner paths or network results.
5. No automatic IPv6/443 ingress trial, firewall change or fourth ACME attempt follows this control result.

Until a private HostOps transport has been **actually** registered, status is BLOCKED_NO_REGISTERED_PRIVATE_HOSTOPS. Brain must not ask Human to run PowerShell as a fallback.

## Source-only CI

- tests/hostops/test-p2-provider-controls.ps1 (offline mocks only)
- .github/workflows/p2-hostops-source-ci.yml (GitHub-hosted Windows; denies native self-hosted triggers in this public repository)

Success of these proves CODE/TEST only, not Windows native runtime. Public laptop ingress, public CA trust and normal ChatGPT MCP tool invocation are separate evidence objectives.
