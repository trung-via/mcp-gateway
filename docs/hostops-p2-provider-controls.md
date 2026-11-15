# P2 HostOps read-only IPv6 provider controls

Status: **SOURCE CANDIDATE ONLY** in Issue [#9](https://github.com/trung-via/mcp-gateway/issues/9). Not yet installed or executed on the laptop.

## Why this exists

The one-time non-CA multi-source laptop test at [PR #7](https://github.com/trung-via/mcp-gateway/pull/7) stopped before ingress because its remote positive controls were unavailable. A separate read-only human Windows run returned Check-Host selected=8, IPv6 success=0, distinct ASN=0. That result does not prove anything about inbound router/ISP filtering.

The owner instructed the project to use HostOps for further checks, with no more Human-run PowerShell diagnostics.

## Operation and risk boundaries

- Exact operation: MCP_P2_IPV6_PROVIDER_CONTROL_READONLY_V1; **zero arguments**.
- Exact external test target: public ipv6.google.com:443, checked by TCPData and Check-Host. Provider HTTPS API connections themselves may disclose the outbound public source IP to those providers, as with any HTTP request. No user hostname or laptop destination IPv6 is placed in the request query.
- Never accept arbitrary Issue body commands, URLs, scripts, file paths or user IP addresses. No Windows host inventory, local listening, DNS mutation, firewall changes, router access, Caddy/ACME, certificate writes, MCP/CDP adapter access or tunneling.
- Timeout and work bounds: TCPData 12 sec max; Check-Host start 8 sec max; up to six result polls with 5 sec max each; at most 8 nodes. Workflow runtime <=3 minutes.
- One machine-readable result line (MCP_P2_HOSTOPS_RECEIPT_V1) contains only enums/counts, timestamp and non-sensitive error stages. No raw provider JSON, returned destination addresses, node metadata, tokens, IPs, local paths or secrets.
- All public receipts must be validated against the allowlisted JSON schema before the GitHub issue comment is created.

## Source-owned trigger and runner authority

Workflow: .github/workflows/p2-hostops-provider-controls-readonly.yml.

A job may be queued **only** for:
- GitHub event issue_comment.created on **Issue #9** of repo trung-via/mcp-gateway;
- authenticated actor **trung-via**;
- exact body: /mcp-gateway-hostops-p2-readonly-v1.

The job executes checkout of **main** (not a PR head) on a dedicated Windows self-hosted runner with the exact custom label **mcp-gateway-hostops**. The runner must be verified as belonging to and being authorized for this repository; a runner attached only to AI Commerce is NOT implicitly available. GitHub-hosted windows-latest CI tests source and mocked provider responses only, and must not be treated as native laptop evidence.

**Do not send the trigger comment until ALL gates below pass:**
1. Independent review and merge of the approved PR source into main.
2. Owner/Engineering independently verifies a registered, online, correctly scoped laptop Windows runner with the mcp-gateway-hostops label and exact repository access. Never silently reconfigure or share AI Commerce HostOps runner.
3. The Windows host's execution policy and egress allow the reviewed script; do not bypass a managed policy, alter security controls, or request secrets. A failing gate is BLOCKED.
4. Request provenance/authorization and expected effect are explicitly reconciled; issue/comment activity is not proof of runner execution.

A result is LIVE only after the Actions run shows the selected self-hosted runner executed the fixed script and Issue #9 received a validated, sanitized receipt referencing that run and source SHA. If no registered runner exists, status remains BLOCKED_NO_NATIVE_ROUTE. Repeated trigger attempts do not prove success.

## Source validation

Offline Windows-hosted tests (no provider network, no laptop contact):
- tests/hostops/test-p2-provider-controls.ps1
- .github/workflows/p2-hostops-source-ci.yml

Cases include positive two distinct IPv6 ASNs and negative same ASN / IPv4-only / provider timeout / request failure / response schema failure / pending node. Static deny tests cover process, firewall, DNS, remote command and dynamic execution primitives.

## Interpretation

- CONTROLS_PASS: TCPData public IPv6-only control OPEN **and** >=2 Check-Host IPv6-success nodes from distinct ASNs. This only establishes checker viability in that time window, not laptop ingress.
- CONTROLS_BLOCKED: at least one prerequisite fails or is inconclusive; inspect sanitized per-provider category before revising provider selection. No ingress test follows automatically.
- Public IPv6 TCP443 ingress, public certificate trust and ChatGPT MCP tools all remain separate unverified acceptance objectives.

This HostOps diagnostic does NOT authorize another static ingress or Let's Encrypt attempt.
