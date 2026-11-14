# MCP Gateway — canonical Work Tree

Reconciled: **2026-11-14**. Canonical source: [`trung-via/mcp-gateway`](https://github.com/trung-via/mcp-gateway) on `main`. Read current GitHub Issue/PR/CI before claiming any newer status.

## Verified records

| Task | Status / evidence | Exact record |
| --- | --- | --- |
| `GATEWAY-P0-001` | VERIFIED / CODE | Public repo + baseline `90206124c1c04e754028a85a258ebcaee4b05e1c` |
| `GATEWAY-P0-002` | VERIFIED / DESIGN | ADR-0001 and ADR-0002 accepted for bounded read-only MVP only |
| `GATEWAY-P0-003` | VERIFIED / CODE (plugin source) | MCP Gateway Brain v0.1.1; cross-chat sync unverified |
| `GATEWAY-P0-004` | BLOCKED / CODE + TEST + DOC (not LIVE) | [Issue #2 OPEN](https://github.com/trung-via/mcp-gateway/issues/2), [PR #5 merged](https://github.com/trung-via/mcp-gateway/pull/5) at `088b513362121913e432cac5a1cd69e6a22ef243`; [Windows CI 40 tests PASS](https://github.com/trung-via/mcp-gateway/actions/runs/43587666927). Render Blueprint, exact Host/Origin allowlist and direct HTTPS runbook ready. **No external service deployed, URL registered, or ChatGPT Chat tool invocation observed.** |
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

Perform **read-only IPv6 inspection** and a **local-only MCP process test**. Do not spend money, create Render hosting, set up Tunnel/Work, or request unrestricted host permissions as a workaround for WAN uncertainty.

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
