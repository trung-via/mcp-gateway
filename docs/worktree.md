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

## IPv6 address-selection evidence — 2026-11-14

Human-provided Windows read-only metadata for two preferred global IPv6 candidates on Wi-Fi (full addresses omitted):

- Candidate 1: `PrefixOrigin=RouterAdvertisement`, `SuffixOrigin=Link`, `PrefixLength=64`, `SkipAsSource=False`, preferred and valid lifetimes ~12h21m. **Better candidate for receiving traffic/DNS** because its suffix derives from a link-layer address; **not proven stable across RA prefix changes, reconnection or ISP renumbering**.
- Candidate 2: `PrefixOrigin=RouterAdvertisement`, `SuffixOrigin=Random`, `PrefixLength=128`, same observed lifetimes, `SkipAsSource=False`. Avoid using this randomly derived candidate for static DNS AAAA.
- Neither entry proves external IPv6 ingress. Inbound router/Windows filtering, a reachable hostname and public TLS remain **UNVERIFIED**; do not expose ports from this metadata.
- The ~12h lifetime is a remaining validity/preference window and may be refreshed by router advertisement; it is not a hard expiry or a guarantee of prefix persistence.
- Next bounded engineering preparation: locally scoped HTTPS reverse proxy on laptop (Caddy or equivalent), using `src.gateway.public_server` bound to `127.0.0.1` with exact `MCP_PUBLIC_HOSTNAME`; collect a real DNS name and decide how AAAA updates on prefix change. The P1 localhost `src.gateway.server` must not be exposed as raw HTTP. Limit to `gateway_health` until ChatGPT Chat tool-call verification.
- Do **not** open IPv6 80/443, alter home-router firewall, publish full personal IPv6 addresses to the public repo, use Tunnel/Work or deploy Render without a scoped approval.

## Local HTTPS MCP protocol and tool-call witness — 2026-11-15

Human PowerShell `curl.exe --resolve <registered-dynv6-host>:8443:127.0.0.1 -k` (internal CA test only) posted the following **actual HTTP+JSON-RPC responses through Caddy 8443 → read-only `src.gateway.public_server` loopback 18080**:

- `MCP_INIT`: **HTTP 200**, `jsonrpc=2.0`, `id=1`, `result.protocolVersion=2025-11-25`, serverInfo.name=`mcp-gateway` (serverInfo.version presently empty string; nonblocking metadata discrepancy).
- `MCP_READY`: **HTTP 202**, notification accepted.
- `MCP_HEALTH`: **HTTP 200**, `jsonrpc=2.0`, `id=2`, `isError=false`, and exact `structuredContent={"service":"mcp-gateway","version":"0.1.0","status":"ok"}`.

**Evidence:** `LOCAL_HTTPS_MCP_TOOL_CALL_PASS / USER_LIVE` — handshake, readiness notification, real tool invocation and deterministic structured result crossed Caddy + MCP public entrypoint via HTTPS on the laptop. Distinct from the prior P1 direct HTTP port 8000 and CI results. Tests used `-k` for **private Caddy internal CA**, which is not a publicly trusted ChatGPT endpoint. Do not mistake local `--resolve` override for IPv6 inbound proof.

**Remaining blockers (not yet verified):**
1. Production public trust chain / ACME certificate for the registered hostname; no `-k` override.
2. Server binding on intended public interface/443 and separately approved Windows inbound + router IPv6 firewall rule (no changes yet).
3. Independent external-network IPv6 HTTPS+MCP test, especially ChatGPT remote client's ability to connect to IPv6-only DNS.
4. ChatGPT regular Chat Server URL plugin registration and actual `gateway_health` invocation.
5. Dynv6 update token seen in earlier screenshot must be revoked/rotated privately (confirmation unobserved); DDNS automatic refresh still not implemented.

**Next safe read-only work:** inspect current firewall **policy only** (`Get-NetFirewallProfile` and scoped existing rules) and confirm Caddy only listens 127.0.0.1:8443, MCP at 127.0.0.1:18080. Prepare separate production Caddy config, user authorization and rollback before any public listener/firewall/router mutation. Keep Chrome CDP 9444 private. Repo is public; never paste residential IPv6 or token.

## Local TLS reverse proxy HEAD proof — 2026-11-15

Human observed `HTTPS_PROXY_HTTP: 405` from bounded curl HEAD to `https://<registered-dynv6-hostname>:8443/mcp`, explicitly resolved to `127.0.0.1` with `--resolve`, using `-k` solely to accept the Caddy **internal test CA**. Previous live listener inspection showed `127.0.0.1:8443 LISTEN`, and P2 local backend Host security returned valid Host HEAD 405 / forged Host 421.

**LOCAL_TLS_ROUTING_SMOKE_PASS**: the test reached an HTTPS HTTP handler compatible with backend HEAD 405 through the configured local route. It does **NOT** prove tool discovery/tool call over that route, publicly trusted TLS, router/Windows IPv6 ingress, or ChatGPT Chat access. Avoid overclaiming HTTP 405 as full MCP protocol success.

**NEXT** (completed 2026-11-15): local HTTPS JSON-RPC init, ready notification and `tools/call gateway_health` each succeeded through Caddy, with HTTP 200 / 202 / 200. Production still requires public certificate validation (never `-k`), explicitly approved inbound 443 security, and separately proven ChatGPT tool invocation. Prior dynv6 token rotation not confirmed.

## Host allowlist localhost proof — 2026-11-15

**User-observed PowerShell curl proof against running `src.gateway.public_server` on loopback `127.0.0.1:18080` with the dynv6 hostname configured**:
- HTTP HEAD request with DNS/SNI override `--resolve <hostname>:18080:127.0.0.1` and correct Host: **`ALLOWED_HOST_HTTP: 405`**. Expected because HEAD method is unsupported by MCP; proof that Host passed allowlist.
- HTTP HEAD request with fake Host `unauthorized.example.org`: **`DENIED_HOST_HTTP: 421`**, reproduced; server correctly rejects unapproved Host.
- An initial GET had stalled; it was replaced by short-timeout HEAD. No inference of server defect or of MCP tool-call protocol acceptance from this probe.

**Evidence status**: `LOCAL_HOST_ALLOWLIST_PASS` (user-observed). Separate localhost `gateway_health` invocation was previously proven on P1 port 8000; no direct `gateway_health` from the P2 18080 entrypoint yet.

**NEXT strictly local (2026-11-15):** Caddy listener `127.0.0.1:8443` and HTTPS HEAD `405` were observed. Now run an actual bounded MCP JSON-RPC tool invocation through local Caddy, then consider external IPv6 security review. Internal CA and `-k` are testing-only; never a ChatGPT public endpoint. No public ingress, firewall/router mutation, tunnel, Work or Render.

External production TLS requires a publicly trusted certificate and authorized inbound rules after separate approval; local `tls internal` does not satisfy the public ChatGPT MCP endpoint gate. Prior leaked dynv6 token rotation remains human-private and not yet evidenced.

## AAAA public DNS resolution observed — 2026-11-15

**User-observed Windows PowerShell output:** the user's registered dynv6 hostname resolves successfully to **one public IPv6 AAAA record, TTL 60**, using a query explicitly sent to `1.1.1.1`. Exact home IPv6 address and hostname are intentionally **not** copied into this public repo.

- **DNS_RESOLUTION_PASS** only: public DNS advertises an IPv6 destination. This is a new verified step after the previously observed `AAAA records: 0`; the old zero-record observation is historical.
- **IP_MATCH_PASS / USER-OBSERVED 2026-11-15:** Human ran the privacy-preserving local comparison of DNS AAAA against the preferred Wi-Fi global IPv6 with `SuffixOrigin=Link`; output was exactly `DNS_TO_LAPTOP: MATCH`. This supersedes `IP_MATCH_UNVERIFIED`; no full IPv6 was disclosed in repo.
- **INGRESS_UNVERIFIED**: the home router may still block unsolicited IPv6 inbound; Windows firewall, certificate issuance, TLS listener, external Streamable HTTP transport and normal ChatGPT Chat MCP tool call are also unverified. IPv6 outbound 200 and localhost MCP client PASS remain separately proven, not a substitute for ingress.
- **NEXT** (2026-11-15 after Host allowlist PASS): set up Caddy local-only TLS on `127.0.0.1:8443` reverse proxy to existing P2 `127.0.0.1:18080`; test TLS and correct/invalid Host via `curl --resolve`. Do not open public 443, modify Windows/router firewall, or expose CDP 9444. Confirm privately that leaked dynv6 token was revoked.
- For ACME HTTP-01/TLS-ALPN-01, required public ingress on 80/443 respectively must be tested; DNS-01 may avoid inbound issuance but not solve the remote MCP ingress problem. Direct IPv6-only reachability from the ChatGPT MCP integration surface remains to be proven.

## DDNS hostname creation observed — 2026-11-14

User shared a screenshot of the dynv6 zone instructions page, demonstrating **dynv6 account signup and a zone hostname have been created**. Exact user hostname/zone ID deliberately omitted from this PUBLIC repository. **This was true when the zone was created; a later 2026-11-15 AAAA query succeeded, but external inbound IPv6 remains untested** and zone activation status not independently queried.

**Security incident / local operator action:** screenshot visibly includes a DDNS update credential/token in router setup instructions. Treat the token as compromised; **rotate/revoke it in the private dynv6 account**, update only privately stored local configuration, and avoid posting future credential-bearing screenshots. No token or fragment should be copied to issue, repo, chat outputs, scripts, or test logs.

Safe next gate: after revoking the token, inspect zone records (A/AAAA) in the account; do not guess or publish residential IPv6 address on public GitHub. With token rotation complete, plan the auto-update client to select the global `SuffixOrigin=Link` address and use the official HTTPS update API (`ipv6` explicit) without using the random/privacy IPv6 address. A dynamic /64 prefix still requires periodic reconciliation. Check real router and Windows IPv6 inbound firewall, certificate issuance, and ChatGPT remote ability to reach IPv6-only hostname before LIVE acceptance. No automatic firewall change or public MCP exposure.

## DDNS provider research — 2026-11-14

**User confirmed no existing DNS name or DDNS hostname.** Proposed free provider: [dynv6](https://dynv6.com/), **PROPOSED / DOC**, not an account/hostname already created. The [official update API](https://dynv6.com/docs/apis) supports explicit `ipv6` AAAA record updates for `zone` and private `token` over HTTPS. This is appropriate for a globally routed IPv6 laptop whose ISP may renumber the /64 prefix. Alternate: [DuckDNS IPv6 update](https://www.duckdns.org/spec.jsp). A hostname example like `mcp-example.dynv6.net` is hypothetical and **not a deployed endpoint**.

Operator-owned creation only: user may register a free dynv6 account and reserve a hostname. No secret/token should be posted to a ChatGPT message, GitHub issue, public repo or log. Do not publish an AAAA record pointing to the laptop until the bounded read-only HTTPS service and ingress security are reviewed. IPv4 A record is not recommended until actual inbound IPv4 routing is established.

**Critical unsolved gates:** router IPv6 inbound firewall, Windows inbound firewall, DNS AAAA propagation, ACME TLS challenge (HTTP-01 requires inbound 80, TLS-ALPN-01 requires inbound 443; DNS-01 needs supported DNS API+credentials), and **unverified remote ChatGPT client reachability to an IPv6-only hostname**. The user previously saw a custom MCP create UI, but account-specific permissions and a real tool invocation remain unverified; OpenAI's current public help describes restrictions by plan.

Status remains `GATEWAY-P0-004 BLOCKED / LOCAL LIVE MCP`; no Render, Tunnel or Work as default.

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
