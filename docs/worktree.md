# MCP Gateway — canonical Work Tree

Reconciled: **2026-11-14**. Canonical source: [`trung-via/mcp-gateway`](https://github.com/trung-via/mcp-gateway) on `main`. Read current GitHub Issue/PR/CI before claiming any newer status.

## Verified records

| Task | Status / evidence | Exact record |
| --- | --- | --- |
| `GATEWAY-P0-001` | VERIFIED / CODE | Public repo + baseline `90206124c1c04e754028a85a258ebcaee4b05e1c` |
| `GATEWAY-P0-002` | VERIFIED / DESIGN | ADR-0001 and ADR-0002 accepted for bounded read-only MVP only |
| `GATEWAY-P0-003` | VERIFIED / CODE (plugin source) | MCP Gateway Brain v0.1.1; cross-chat sync unverified |
| `GATEWAY-P0-004` | BLOCKED / LOCAL LIVE MCP, not external/ChatGPT LIVE | [Issue #2 OPEN](https://github.com/trung-via/mcp-gateway/issues/2). Human laptop probe: **PASS discovery + `gateway_health` + `INVALID_PARAMS` against `127.0.0.1:8000/mcp`** (2026-11-14); [PR #5](https://github.com/trung-via/mcp-gateway/pull/5) merged and [40 Windows CI tests PASS](https://github.com/trung-via/mcp-gateway/actions/runs/43587666927). **Still no direct inbound IPv6/HTTPS, plugin registration or ChatGPT Chat call.** Laptop-first; Render optional, not deployed. |
| `GATEWAY-P1-001` | VERIFIED / DESIGN | `mcp==2.3.0`, [gateway_health contract](../contracts/tools/gateway_health.v1.md) |
| `GATEWAY-P1-002` | VERIFIED / CODE + TEST | [Issue #1 closed](https://github.com/trung-via/mcp-gateway/issues/1); [PR #3 merged](https://github.com/trung-via/mcp-gateway/pull/3); merge commit `cabdb994bcb342d4b258adc468eafda2c40c3501` |
| `GATEWAY-P1-003` | VERIFIED / TEST | [Windows PR CI PASS](https://github.com/trung-via/mcp-gateway/actions/runs/43583208001) and [main CI PASS](https://github.com/trung-via/mcp-gateway/actions/runs/43583364258): 6 tests + Streamable HTTP positive/invalid-params smoke |

## Result for completed P1 Engineering task

```yaml
kind: GATEWAY_RESULT_V1
task_id: GATEWAY-P1-002
source: trung-via/mcp-gateway
issue: https://github.com/trung-via/mcp-gateway/issues/1
pr: https://github.com/trung-via/mcp-gateway/pull/3
head_sha: a8d1f419eb3fa6b014f6a3a1499d45187bd1cf84
merge_sha: cabdb994bcb342d4b258adc468eafda2c40c3501
tests:
  python_in_process: "6 passed on Windows"
  streamable_http: "PASS (positive and INVALID_PARAMS)"
  ci_pr: https://github.com/trung-via/mcp-gateway/actions/runs/43583208001
  ci_main: https://github.com/trung-via/mcp-gateway/actions/runs/43583364258
proven: SOURCE_AND_CI_ONLY
not_proven:
  - live user laptop MCP server
  - public HTTPS endpoint, deployed service or tunnel
  - connected ChatGPT plugin and normal Chat tool invocation
  - Windows/GitHub adapter, write/host permissions or exact Chat A wake
```

## User-confirmed integration constraints (2026-11-14)

- **Required target:** ChatGPT ordinary Chat, not Work.
- **Required connection mode:** **Server URL**, not Tunnel or any tunnel-like laptop forwarding.
- **Primary architecture (user-directed):** laptop Windows hosts the read-only MCP server behind a local HTTPS reverse proxy; normal ChatGPT Chat connects via public HTTPS **Server URL**. Public inbound reachability, DNS and routing are **not yet proven**. A managed-host Render Blueprint exists in source as **optional fallback only**, not the chosen route.
- User has supplied a screenshot that confirms the custom MCP creation form and both connection tabs are visible. This proves UI availability only, not tool-call success.
- Keep Windows/CDP 9444/private host services unreachable from public endpoint; future laptop agent linkage is separate P3.
- Source of decision: [Issue #2](https://github.com/trung-via/mcp-gateway/issues/2) user-constraint correction.

## Verified local-runtime milestone — 2026-11-14

User-observed Windows PowerShell evidence (local laptop; not GitHub runner):
- Python 3.11 + pinned MCP SDK dependencies installed and `src.gateway.server` started on `http://127.0.0.1:8000/mcp`.
- A separate local client ran `tests/probe_mcp_endpoint.py --url http://127.0.0.1:8000/mcp` and returned exactly **`PASS: MCP endpoint discovery, health response and INVALID_PARAMS`**.
- This verifies **LOCAL_LIVE_MCP**: localhost transport, tool discovery, read-only tool invocation and rejection of unexpected arguments.
- It **does not** verify the process remains running, public IPv6 ingress, HTTPS/TLS, DNS AAAA, router/Windows firewall, ChatGPT Plugin registration, or a native tool call from normal Chat.
- Prior user-observed tests also found IPv6 default route count 1 and outbound `curl.exe -6` HTTPS status 200. The user has not provided full IPv6 addresses; never store them in this public worktree.
- Next security-first steps: identify a non-temporary IPv6 address via privacy-preserving metadata; choose exact hostname/AAAA and local HTTPS reverse-proxy design; assess router/Windows IPv6 inbound firewall before any external test. Windows/CDP 9444 remains private; no Tunnel, Work or default Render hosting.

## Laptop-first connectivity diagnosis — 2026-11-14

Source: Human-supplied read-only PowerShell diagnostic output. **Avoid publishing exact user WAN/LAN IPs in this public repo.**

- Confirmed: a private IPv4 Wi-Fi address, home router as default gateway, public IPv4 egress, and no TCP listeners on the candidate 80/443/8000/18080 ports.
- `WAN_UNVERIFIED`: UPnP yielded no usable WAN address; cannot establish WAN=egress or whether router is behind CGNAT.
- `INBOUND_UNTESTED`: no listener and no known router port-forward. A TCP test of the egress IP or a self-hairpin test would not prove external reachability.
- A traceroute with one private address at an upstream ISP hop is **not proof of CGNAT**.
- `NEXT_READONLY`: inspect global IPv6 availability and confirm local MCP readiness (loopback) without opening network ports.
- `NETWORK_DEPENDENCY`: if IPv4 is required, check actual WAN assignment and arrange *authorized* 443 port forwarding via router access/ISP after a secured HTTPS-only endpoint is prepared; IPv6 likewise requires DNS, TLS, and perimeter firewall permit. Dynamic IP may need DDNS.
- `SECURITY_STOP`: do not expose MCP via raw HTTP, automatically enable UPnP mapping, disable Windows firewall, or expose Chrome CDP 9444/host admin. Only public static `gateway_health` is allowed in this phase.
- `LIVE_ACCEPTANCE`: from a truly external network, verify HTTPS MCP discovery/health and then a real tool call in **ordinary ChatGPT Chat**; the CI tests and any local tool calls do not satisfy this acceptance.

### Current owner action

**Local MCP discovery and call PASS.** Next: inspect stable versus temporary IPv6 assignment (without exposing full IPv6), review hostname/AAAA and TLS reverse proxy, and read existing firewall policies. Do not open ports, spend money, create Render hosting, set up Tunnel/Work, or grant unrestricted host privileges until a scoped security review and explicit approval.

## Active task — GATEWAY-P0-004 / Issue #2

```yaml
kind: GATEWAY_TASK_V1
task_id: GATEWAY-P0-004
owner: MCP Gateway Brain + Integration
source: trung-via/mcp-gateway
issue: https://github.com/trung-via/mcp-gateway/issues/2
goal: Verify how this account can connect a real MCP tool in normal ChatGPT Chat
allowed:
  - source-led capabilities research
  - read-only eligibility / available ChatGPT connection UI assessment
  - laptop-hosted HTTPS reverse-proxy feasibility (primary) and bounded security review
  - normal ChatGPT Chat only, using **Server URL**
forbidden_without_separate_approval:
  - deploy any public endpoint or register paid hosting without a scoped approval
  - use Tunnel, Secure MCP Tunnel, ngrok, Cloudflare Tunnel or ChatGPT Work for P2
  - expose Windows/CDP/host-admin ports or secrets
  - alter AI Commerce/CDP Host
  - mark P2 LIVE without an observed ChatGPT tool call
acceptance:
  - exact account/surface entitlement evidence
  - approved reachable HTTPS Streamable HTTP endpoint on laptop, with actual WAN routing/DNS/TLS proof (no Tunnel)
  - discovered gateway_health in connected plugin
  - successful ChatGPT Chat tool call with receipt
status: BLOCKED_LIVE_PROOF
```

## Continuity rules

- Task `NOT_STARTED | IN_PROGRESS | BLOCKED | VERIFIED | RETIRED`; ADR `PROPOSED | ACCEPTED | SUPERSEDED`; evidence `DESIGN | CODE | TEST | LIVE | UNVERIFIED`. These fields are separate.
- Do not infer executor dispatch from Issue creation, merge from PR creation, live deployment from CI, or Chat A wake from a synchronous tool reply.
- Capture exact GitHub revision, date and non-secret test receipt; unknown effect = `UNKNOWN_EFFECT_NO_RETRY` until read-only reconciliation.
- No active work should remain assigned to an already closed Issue #1. Next focus is [Issue #2](https://github.com/trung-via/mcp-gateway/issues/2).
