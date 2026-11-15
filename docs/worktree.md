# MCP Gateway — canonical Work Tree

**Latest HostOps 2026-11-15:** Owner switched dedicated MCP Gateway HostOps to **Public** repo [`trung-via/mcp-gateway-hostops`](https://github.com/trung-via/mcp-gateway-hostops), separate from AI Commerce. [Bootstrap PR #1 merged](https://github.com/trung-via/mcp-gateway-hostops/pull/1), exact main `ed3b6fc8aa495a1625495ed754c87e9180c6b256`; Windows hosted CI PR/main PASS. Negative [Issue #2 → run #43686329911](https://github.com/trung-via/mcp-gateway-hostops/actions/runs/43686329911) proved owner-gate DENY and native job SKIPPED. Runner Settings reports **none configured**: `MCP_HOSTOPS_NATIVE_ROUTE=BLOCKED_NO_RUNNER`. [ADR-0004](adr/0004-public-hostops-authorization.md) supersedes the earlier private visibility decision. No native or public TLS proof.

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

## PR #7 multi-source IPv6 ingress diagnostic PREPARED, no CA (2026-11-15)

**Human decision:** the user explicitly consented to **PREPARE** a non-CA, static-only TCP443 multi-source IPv6 diagnostic, with temporary firewall open at most **180 seconds**. This source-preparation approval **does not authorize an actual native Windows execution** or any fourth public ACME CA attempt.

**Implementation in [PR #7](https://github.com/trung-via/mcp-gateway/pull/7), OPEN / UNMERGED, head `626b753ded514cb15a32ea1af3eed8b2832014b8`:** extended existing Caddy `tls internal` static-only script instead of adding another agent. Added `-UseMultiSourceIPv6Probe`, `-ApproveTemporaryIngress`, `-ApproveRemoteProbeDisclosure`. Multi-source mode checks positive control IPv6-only `ipv6.google.com:443` via TCPData + at least two Check-Host remote nodes with IPv6-confirmed destination and **distinct ASNs before creating a listener/firewall**. If capability cannot be demonstrated, STOP with no host exposure. Then within same window and exact selected Wi-Fi global IPv6 TCP443/Private ActiveStore firewall scope, check local static HTTPS body and remote TCP status from TCPData/selected Check-Host nodes. Only results carrying **exact matching target IPv6** qualify as remote TCP PASS. This does not claim remote TLS SNI/ALPN/HTTP, CA issuance or ChatGPT MCP. Optional independently IPv6-capable remote `curl -6 -k` runbook step would supply remote TLS static-body witness if available.

**Bounded rollback**: duration validation **60–180 seconds**, independent watchdog spawned before rule creation and scheduled at DurationSeconds (not +30). Main finally closes rule/isolated Caddy normally **15 seconds before** watchdog ceiling; independent 0/0 postcheck required. No port80, router login, DNS token, public ACME, MCP proxy, CDP 9444, Tunnel/Render/Work.

**CI VERIFIED at exact head:** [Windows PS7 AST & static safety #43676212340](https://github.com/trung-via/mcp-gateway/actions/runs/43676212340) SUCCESS; [MCP read-only suite #43676212343](https://github.com/trung-via/mcp-gateway/actions/runs/43676212343) SUCCESS. Real Check-Host API response shape, remote node IPv6 availability, in-window TCP/TLS outcomes and native cleanup for the *new* flow are **NOT YET USER_LIVE verified**. Earlier GitHub CI failures during source assembly were repaired; final head PASS.

**Next**: independent Brain review and **separately approved native one-off run** pinned to exact PR7 head, or no network action. If run, log preflight receipts/ready time, TCPData/Check-Host source status, `FIREWALL_TEST_RULE=REMOVED`, `TEMP_CADDY=STOPPED`, and postcheck TCP443 listener=0 / ActiveStore rule=0. Further ACME attempts remain unauthorized. [Runbook](https://github.com/trung-via/mcp-gateway/blob/p2/ipv6-443-temporary-ingress-probe-20261115/docs/p2-ipv6-443-temporary-ingress-probe.md).

## Three-resolver AAAA matches laptop — 2026-11-15

**USER_LIVE read-only DNS test (Windows laptop, no hostname/IP published):**
```text
LOCAL_GLOBAL_IPV6_COUNT=1
1.1.1.1 AAAA_COUNT=1 MATCH_LOCAL=True
8.8.8.8 AAAA_COUNT=1 MATCH_LOCAL=True
9.9.9.9 AAAA_COUNT=1 MATCH_LOCAL=True
```

Current selected global Wi-Fi IPv6 equals the unique public AAAA returned by Cloudflare, Google and Quad9 resolvers. **DNS_AAAA_3_RESOLVERS_MATCH_LOCAL / USER_LIVE PASS**, but this does not establish authoritative/CA-perspective DNS state **during expired third CA trial**.

**Remaining diagnostic**: CA's `Unable to contact <HOST> at <IPV6>` is a separate runtime ingress issue, despite an earlier off-LAN TCPData TCP443 `OPEN` in another trial. The next falsifiable experiment would be a **bounded, static-only, no-CA** IPv6 TCP443 ingress test from *at least two independent IPv6-capable external networks* during **the same window**, recording exact listener/firewall-ready timing and comparing basic TCP with (if possible) TLS SNI/ALPN outcomes. It requires new explicit scope approval to temporarily open a public IPv6 listener and Windows Private ActiveStore firewall; no license to retry ACME, deploy public MCP/CDP, change router, or reveal secrets. If this passes from multiple networks but CA still cannot contact, prioritize CA-specific reachability/path behavior and validation protocol, without asserting causality until live proof.

Official references: https://letsencrypt.org/docs/ipv6-support/ ; https://caddyserver.com/docs/automatic-https . Current P0-004 remains BLOCKED; trusted HTTPS and ChatGPT native MCP invocation still UNVERIFIED.

## Third ACME trial: CA IPv6 endpoint unreachable (authorization failed) — 2026-11-15

**New direct CA authorization failure detail, USER_LIVE:** newest third-trial Caddy stderr `tls.obtain` reported `authorization failed: HTTP 400 urn:ietf:params:acme:error:malformed - Unable to contact "<HOST>" at "<IPV6>", no IPv4 addresses to try as fallback`. Three `CHALLENGE_STARTED` events and non-empty `OTHER_ACME_ERROR` were observed prior to extracting literal error. This is the *ACME server response status* to a **TLS-ALPN-01 TCP443** validation attempt, not evidence that the HTTP-01 challenge was used. Public HTTPS certificate **NOT verified**.

**Earliest confirmed failure boundary:** external Let's Encrypt CA reachability to the domain's public IPv6 during authorization failed. The prior `missing port in address` IPv6 challenge embedded-listener errors were NOT present in these third-attempt messages. Raw unbracketed `bind $ipv6` and adapted `challenges.bind_host` preflight passed, and isolated TCP443 Caddy + exact IPv6 Windows Private ActiveStore rule were reported ACTIVE for the 300s trial. User independently confirmed clean rollback with `PORT443_LISTENERS=0`, `ACME_TEST_RULES=0`.

**Underlying root still UNKNOWN**: Do **not** infer a router/ISP block just from the CA error; an earlier external IPv6 TCP443 checker observed OPEN on a different window, not necessarily from all CA validation networks. Competing branches include current/recent public AAAA consistency, exact IPv6 address on laptop, ingress filtering/routing across different IPv6 remote sources, profile/program firewall behavior, listener readiness/timing and ALPN-specific response issues. No definitive source attribution from an ACME API error string alone.

**Citable vendor docs:** https://letsencrypt.org/docs/ipv6-support/ (LE prefers AAAA and IPv4 fallback is limited, cannot force IPv4 for this TLS-ALPN path), https://caddyserver.com/docs/automatic-https (TLS-ALPN-01 requires public access to TCP443).

**NEXT ALLOWED**: read-only compare preferred single global Wi-Fi IPv6 against public AAAA across independent resolvers without revealing addresses in the public repo. DNS state now is not a historical DNS snapshot. If all match, seek *separate approval* for a short **non-CA** static IPv6:443 multi-perspective connectivity test before any further CA attempts. Keep the main test-only rule/isolated Caddy/watchdog bounds, never expose `/mcp`, CDP, other processes, or port80. **NO FOURTH ACME RETRY** authorized. Issue #2 remains BLOCKED pending trusted TLS and ChatGPT Chat tool-call witness.

## Third ACME trial log classifier returned unspecified errors; rollback 0/0 — 2026-11-15

Operator executed read-only newest Caddy error log categorization after third 300-second ACME trial. `ACME_LOG=FOUND`; output showed **three `CERTIFICATE_REQUEST_STARTED` and three `CHALLENGE_STARTED` events**, with **six `OTHER_ACME_ERROR`** records (two errors following each challenge start). The classifier's `OTHER_ACME_ERROR` is a catchall for **any nonempty error string** not recognized by its patterns. This **does not establish the underlying error**, a return of prior `missing port in address`, a specific CA denial, or certificate issuance. No `CERTIFICATE_OBTAINED` event observed in the inspected log segment.

Independent Windows postcheck **`PORT443_LISTENERS=0`** and **`ACME_TEST_RULES=0`** now confirms full cleanup after trial #3. Prior attempt output also had `FIREWALL_TEST_RULE=REMOVED`, `TEMP_CADDY=STOPPED`. No public MCP or other host service was exposed.

**Next authorized action**: read-only review of the **first few unique sanitized literal Caddy `error` messages from newest log**, with domain, global IPv6/IP, CA order/account URLs, paths, emails, credentials redacted. Do not put sensitive raw log into public GitHub. Do not start a fourth ACME request or open firewall; existing consent exhausted. Keep P0-004 public TLS / real ChatGPT Chat MCP tool call `UNVERIFIED` until actual trusted HTTPS and client proof.

## Third public ACME TLS-ALPN-01 trial: trusted HTTPS NOT VERIFIED — 2026-11-15

**USER_LIVE Windows operator receipt, after explicit one-off third trial consent:** `CADDY_HTTP_IPV6_LISTENER=PASS`, `CADDY_ACME_BIND_HOST_RAW_IPV6=PASS`, `CADDY_BIND_IPV6_HOST_ONLY=PASS`, `TEMP_IPV6_443_LISTENER=BOUND`, `FIREWALL_TEST_RULE=SCOPED_ACTIVE`, `TLS_CERTIFICATE=PUBLIC_ACME_PENDING`, `MCP_BACKEND_EXPOSED=NO`, `WINDOW_SECONDS=300`, `ACME_CHALLENGE=TLS_ALPN_01_TCP443_ONLY`, **`PUBLIC_TLS_TRUST=NOT_VERIFIED_WITHIN_WINDOW`**, expiry completed, `FIREWALL_TEST_RULE=REMOVED`, `TEMP_CADDY=STOPPED`.

**Meaning:** `TRIAL_3_USER_LIVE` with raw IPv6 ACME bind-host adapted preflight PASS, temporary IPv6/443 listener and firewall ACTIVE during test, then reported cleanup PASS. **No proof of externally trusted certificate or successful ACME challenge.** Script only verifies that curl returns the exact static body over publicly trusted TLS; per-request curl stderr is suppressed. Cause of this trial's failure is **UNKNOWN** until the newest `%TEMP%\mcp-p2-443-*\caddy-stderr.log` is read (not previous trials' logs). Do not assert previous malformed listener bug recurred, public CA rejected issuance or upstream inbound blocked from this status alone.

**Safety/next:** Single third CA attempt authorization has been **CONSUMED**. **NO FOURTH CA RETRY**. Next read-only check: sanitized new Caddy `tls.obtain`, `http.acme_client` challenge, error or certificate-obtained messages, plus independent port443 listener count and temporary firewall rule count (expected 0/0, not yet supplied this trial). No new network/port/firewall/DNS effects or public MCP. If Caddy log shows certificate obtained, separate client TLS/static response issue must be diagnosed without requesting another cert. Public ChatGPT `gateway_health` invocation remains unverified.

## ACME trial #3: explicit bounded human approval — 2026-11-15

**Human explicit acceptance:** user replied `ok đồng ý` to the question authorizing **exactly ONE third** real public ACME TLS-ALPN-01 static-only test after independent Windows raw-IPv6 `-CheckBindOnly` showed `CADDY_HTTP_IPV6_LISTENER=PASS`, `CADDY_ACME_BIND_HOST_RAW_IPV6=PASS`, `CADDY_BIND_IPV6_HOST_ONLY=PASS`, `PUBLIC_ACME_CA_CONTACT=NO`, `NO_FIREWALL_CHANGE=YES`. Approval includes the previously disclosed CA contact/Certificate Transparency and potentially persistent Caddy certificate/private-key material, not public MCP/service deployment.

**Pinned PR:** [PR #8](https://github.com/trung-via/mcp-gateway/pull/8) head `bf60dc6c8ba3d2b7bc4bcce12c733c0dfcf50f90`. [CI MCP #43667100706](https://github.com/trung-via/mcp-gateway/actions/runs/43667100706) PASS at this head; the later revised PowerShell-only regression workflow is not independently CI-proven at exactly this head. **Windows host dry-run is actual native proof; source/static CI does not substitute for CA challenge runtime.**

**Permission / safety:** operator may run **once** on Windows elevated PS7 with `-DurationSeconds 300 -ApprovePublicACME`, pinned Git SHA, static-only Caddy, exact selected global IPv6:443, firewall ActiveStore Private scoped exact Caddy program/IP/443, watchdog+finally. No port80, DNS plugin/token, router login, MCP backend, CDP 9444, Tunnel, Render, Work, or AI Commerce host control. Script reports trusted certificate only on curl without `-k`. User-local execution only; no Windows effects made in the GitHub approval update.

**State before run:** third CA attempt `NOT_STARTED`; live trusted public TLS `UNVERIFIED`; ChatGPT `/mcp` actual tool call `UNVERIFIED`. After one run, capture trust verdict, Caddy cleanup receipts, independent 0/0 listener/firewall rule checks. If failure, no fourth retry without log RCA and new approval.

## Windows raw IPv6 ACME bind_host check PASS — 2026-11-15

**USER_LIVE native Windows PowerShell witness:** operator fetched pinned [PR #8](https://github.com/trung-via/mcp-gateway/pull/8) commit `bf60dc6c8ba3d2b7bc4bcce12c733c0dfcf50f90` and ran the non-public-CA `-CheckBindOnly` preflight:

```text
CADDY_HTTP_IPV6_LISTENER=PASS
CADDY_ACME_BIND_HOST_RAW_IPV6=PASS
CADDY_BIND_IPV6_HOST_ONLY=PASS
PUBLIC_ACME_CA_CONTACT=NO
NO_FIREWALL_CHANGE=YES
```

**Acceptance:** `ACME_RAW_BIND_HOST_PREFLIGHT_PASS / USER_LIVE`. The local Caddy adapted HTTP TCP443 listen address was accepted **and** issuer `challenges.bind_host` was confirmed to be selected **raw unbracketed global IPv6**. This closes the ACME-field verification gap behind the previous two `missing port in address` errors. The dry-run returned **before** starting public Caddy, opening Windows Firewall or calling the CA. No new public certificate or CT record from this dry-run.

**CI precision:** PR branch raw IPv6 script and raw ACME challenge guard verified CODE; [MCP protocol CI #43667100706](https://github.com/trung-via/mcp-gateway/actions/runs/43667100706) SUCCESS at above head. Previous [PS7 AST/static check #43666748884](https://github.com/trung-via/mcp-gateway/actions/runs/43666748884) SUCCESS at script change commit `1f56fe7`, but a new dedicated PS7 static-safety run covering the subsequently revised workflow was **not independently confirmed**; do not claim new-workflow CI PASS.

**State boundary:** `PUBLIC_TLS_TRUST=UNVERIFIED`; TLS-ALPN runtime behavior not yet observed for corrected unbracketed bind; ChatGPT IPv6-only public endpoint and `gateway_health` actual call not proven. The first two ACME test authorizations have been used; **new explicit one-off permission** is needed before another real public-CA TLS-ALPN-01 trial (max 300sec, static-only, exact IPv6 TCP443, Caddy-scoped Private ActiveStore firewall, watchdog, normal rollback). No unlimited retries, no public MCP/CDP, router login, port80, DNS token, Tunnel/Render/Work.

## ACME TLS-ALPN DOUBLE-BRACKET bind_host RCA from second live stderr — 2026-11-15

**USER_LIVE second-attempt native Caddy stderr:** while corrected `bind [$ipv6]` gave `CADDY_BIND_IPV6_HOST_ONLY=PASS` for the *HTTP* listener, the ACME TLS-ALPN embedded solver failed to create its independent listener: **`could not start listener for challenge server ... listen tcp: address [[<IPV6>]]... missing port in address`** (multiple production and staging issuer attempts). This is not a CA authorization rejection or network route test; it is a local ACME `bind_host` text-format failure. Caddy formatting and admin-disabled warnings are noncausal. After the 300-second trial, independent Windows postcheck **`PORT443_LISTENERS=0` / `ACME_TEST_RULES=0`** verified full rollback.

**External upstream corroboration**: https://github.com/caddyserver/caddy/issues/7399 (Dec 27, 2025 comment, IPv6 bind addresses must NOT use `[]` for ACME due unconditional bracket insertion), and code model https://pkg.go.dev/github.com/caddyserver/caddy/v2/modules/caddytls (ACME `challenges.bind_host`). Normal listener `bind` docs show brackets (https://caddyserver.com/docs/caddyfile/directives/bind), but they do not account for observed ACME embedded challenge bug.

**Root cause / previous false PASS**: initial source `bind tcp6/[$ipv6]` leaked protocol + brackets; first attempted repair `bind [$ipv6]` removed network prefix but left brackets, which were added again by ACME. Earlier dry-run only checked adapted HTTP server `listen` and could not detect malformed ACME `challenges.bind_host`.

**PR #8 SOURCE updated** (OPEN/UNMERGED): replace `bind [$ipv6]` with **raw `bind $ipv6`**, still exact selected global IPv6 and TCP443; strengthened no-CA `-CheckBindOnly` now requires BOTH adapted HTTP listener `[IPv6]:443` and ACME challenge `bind_host == raw, unbracketed IPv6`, otherwise STOP before listener/firewall/CA. CI rejects `bind tcp6/`, `bind [`, `bind ::` and missing ACME bind_host guard. Existing Windows Private ActiveStore scoped firewall, independent cleanup, 300-second upper scope, static-only no-MCP route all retained.

**EVIDENCE STATE:** `DOUBLE_BRACKET_ACME_BIND_HOST_ROOT_CAUSE_CONFIRMED / USER_LIVE_LOG`. `RAW_BIND_FIX=CODE`, CI and new laptop `-CheckBindOnly` result must be checked separately. No third CA trial authorized (two completed trials consumed previous approvals). **Next**: run only pinned new source **`-CheckBindOnly`** on laptop, expect `CADDY_HTTP_IPV6_LISTENER=PASS`, `CADDY_ACME_BIND_HOST_RAW_IPV6=PASS`, `PUBLIC_ACME_CA_CONTACT=NO`, `NO_FIREWALL_CHANGE=YES`; do not call CA until root cause fix has actual Windows no-CA acceptance and an independently approved bounded new attempt. ChatGPT MCP `/mcp` still CLOSED/UNVERIFIED, no router login/Tunnel/Render/Work/CDP exposure.

## Public ACME trial #2 attempted; public trust unverified — 2026-11-15

**Actual operator Windows 300-second test after Caddy host-only bind fix:** `CADDY_BIND_IPV6_HOST_ONLY=PASS`, `TEMP_IPV6_443_LISTENER=BOUND`, `FIREWALL_TEST_RULE=SCOPED_ACTIVE`, `TLS_CERTIFICATE=PUBLIC_ACME_PENDING`, `MCP_BACKEND_EXPOSED=NO`, `WINDOW_SECONDS=300`, `ACME_CHALLENGE=TLS_ALPN_01_TCP443_ONLY`, but `PUBLIC_TLS_TRUST=NOT_VERIFIED_WITHIN_WINDOW`. Window ended normally; `FIREWALL_TEST_RULE=REMOVED`, `TEMP_CADDY=STOPPED`. Additional independent postcheck 0/0 not yet provided for this specific trial.

**Correct classification:** `PUBLIC_TLS_TRUST=UNVERIFIED`, **CA issuance state unknown**. The source suppresses local curl error output, so the failure may be CA validation/challenge or client-side certificate/HTTP validation. Do not assume original `missing port in address` recurred without the latest Caddy process stderr. Previous direct IPv6 TCP443 inbound OPEN remains separate evidence.

**Authorization:** this consumed the single agreed additional ACME trial; **NO THIRD RETRY** pending diagnosis and new scoped permission. Read-only next step: safely extract relevant JSON fields from newest `%TEMP%\mcp-p2-443-*\caddy-stderr.log`, sanitizing private hostname, IPv6, ACME account/order URLs/paths; independent port443 listener and exact scoped rule count. No CA calls, router changes, DNS plugin, public MCP or CDP.

## Approved single public ACME TLS-ALPN-01 retry #2 — awaiting operator Windows live proof

**OWNER AUTHORIZATION / 2026-11-15:** after native Caddy `-CheckBindOnly` no-CA/no-firewall PASS, user explicitly approved **exactly ONE further 300-second** public CA ACME TLS-ALPN-01 test, with consent to previously disclosed CT transparency/persistent Caddy certificate material. This is not open-ended retry permission. No Windows run was performed by ChatGPT tools; the next action requires operator's elevated PowerShell 7 on laptop.

**Pinned source:** [PR #8](https://github.com/trung-via/mcp-gateway/pull/8) branch `p2/trusted-tls-alpn-01-static-probe-20261115`, known reviewed head `382e7882ffd3a72c8f2954c204c7312c6985e624`; script corrected to `bind [$ipv6]` (host-only). [PS7 static-safety CI #43664753050](https://github.com/trung-via/mcp-gateway/actions/runs/43664753050) PASS, [MCP CI #43664753051](https://github.com/trung-via/mcp-gateway/actions/runs/43664753051) PASS. The operator will reject a mismatched fetched Git SHA.

**Boundaries:** `-ApprovePublicACME -DurationSeconds 300`; test Caddy only serves fixed response at `/__mcp_p2_public_tls_probe`, does not proxy to MCP/CDP/Windows, binds only selected global IPv6 443, scoped temporary Windows Private ActiveStore allow and independent +30-second watchdog. No router login, HTTP80, DNS plugin, dynv6 token, Tunnel/Render/Work. Real CA issuance may persist ACME key/certificate; no CA contact yet in current user message.

**Evidence to accept:** `CADDY_BIND_IPV6_HOST_ONLY=PASS`, `PUBLIC_TLS_TRUST=PASS_VALIDATED_WITHOUT_INSECURE`, `FIREWALL_TEST_RULE=REMOVED`, `TEMP_CADDY=STOPPED`, postcheck TCP443 listeners 0 / temporary firewall rules 0. If unverified after one attempt, DO NOT RETRY: inspect redacted local Caddy stderr. Public trusted TLS still `UNVERIFIED`, ChatGPT IPv6-only cloud reachability and tool invocation still `UNVERIFIED`.

## Windows no-CA bind preflight of repaired PR #8 PASS — 2026-11-15

**USER_LIVE operator Windows PowerShell output** after fetching PR #8 reviewed branch head `382e7882ffd3a72c8f2954c204c7312c6985e624` and invoking `p2-public-tls443-static-probe.ps1 -CheckBindOnly`:

```text
CADDY_BIND_IPV6_HOST_ONLY=PASS
PUBLIC_ACME_CA_CONTACT=NO
NO_FIREWALL_CHANGE=YES
```

**EVIDENCE:** `WINDOWS_NO_CA_BIND_PREFLIGHT_PASS / LIVE`. The Caddyfile now has host-only `bind [$ipv6]`; script parsed adapted JSON and confirmed the selected global IPv6/443 listener address (no `tcp6/` prefix), then returned before `Start-Process`, `New-NetFirewallRule`, ACME issuance or public CA contact. [PR #8 Windows PowerShell AST/static CI #43664753050](https://github.com/trung-via/mcp-gateway/actions/runs/43664753050) and [MCP protocol CI #43664753051](https://github.com/trung-via/mcp-gateway/actions/runs/43664753051) both SUCCESS at reviewed head.

**Remaining boundary:** Caddy's *runtime embedded TLS-ALPN-01 solver* was not invoked during this dry-run. **Trusted public HTTPS certificate remains UNVERIFIED.** Before one further 300-second static-only CA trial, obtain explicit separately scoped operator consent to recontact a public CA with potential CT log/certificate persistence effects; do not infer unlimited retry authorization from previous consent. Keep prior exact IPv6 TCP443/ActiveStore Private firewall/isolated Caddy + watchdog restrictions and no MCP/CDP/host access. No router login, DNS token, port80, Tunnel/Render/Work. On any retry failure, read redacted Caddy stderr first.

## ACME TLS-ALPN bind-host root cause confirmed and PR #8 repaired — 2026-11-15

**Native laptop diagnosis (USER_LIVE log):** ACME production/staging accounts were registered; `http.acme_client` started TLS-ALPN-01 challenge, but `tls.obtain` failed at `presenting with embedded solver` because it attempted a **malformed TCP listen address missing a port**, derived from original `bind tcp6/[$ipv6]`. The site server did bind IPv6/443, but the embedded ACME solver's **bind host** could not accept the `tcp6/` network-prefixed representation in the observed Caddy runtime. **Root cause CONFIRMED: gateway Caddyfile bind-host construction, not upstream router/ISP and not CA authorization reject**. First-time missing ACME account file is informational; accounts were successfully registered. Caddy source: https://caddyserver.com/docs/caddyfile/directives/bind .

**Exact PR repair:** [PR #8](https://github.com/trung-via/mcp-gateway/pull/8) updated to **`bind [$ipv6]` (host only)** while keeping exact selected global IPv6 TCP443, TLS-ALPN-01 only, static-only response, scoped Windows Private ActiveStore rule and independent cleanup watchdog. Added **`-CheckBindOnly`** no-CA/no-firewall path: local Caddy `adapt` parse and exact adapted listener check; expected `CADDY_BIND_IPV6_HOST_ONLY=PASS`, `PUBLIC_ACME_CA_CONTACT=NO`, `NO_FIREWALL_CHANGE=YES`. CI regression rejects `bind tcp6/` and requires read-only branch before Caddy start.

**[Windows CI #43664753050](https://github.com/trung-via/mcp-gateway/actions/runs/43664753050) PASS** on PR #8 updated head `382e7882ffd3a72c8f2954c204c7312c6985e624` (PS7 AST + static safety only). **Windows no-CA `-CheckBindOnly` NOT YET EXECUTED**, repaired ACME issuance NOT YET ATTEMPTED. User already confirmed **post-cleanup 443 listeners=0, temp ACME rules=0**. No public MCP, cert, DNS plugin or CDP exposure.

**Next:** user fetches updated PR #8 branch pinned to reviewed head, runs `-CheckBindOnly` (NO `-ApprovePublicACME`), provides output. Only after live preview PASS consider a **separately scoped retry authorization**, because the first approved CA attempt already contacted production and staging. Avoid automatic retries and certificate rate limits. Router login remains unavailable/unneeded; no Tunnel/Render/Work.

## Public ACME certificate trust attempt #1 unverified — 2026-11-15

**Owner USER_LIVE Windows evidence from approved PR #8**:
- `TEMP_IPV6_443_LISTENER=BOUND`, `FIREWALL_TEST_RULE=SCOPED_ACTIVE`, `MCP_BACKEND_EXPOSED=NO`, `TLS_CERTIFICATE=PUBLIC_ACME_PENDING`, `WINDOW_SECONDS=300`, `ACME_CHALLENGE=TLS_ALPN_01_TCP443_ONLY`.
- `PUBLIC_TLS_TRUST=NOT_VERIFIED_WITHIN_WINDOW`, `TEST_WINDOW=EXPIRED_OR_VERIFIED`.
- Cleanup receipts `FIREWALL_TEST_RULE=REMOVED` and `TEMP_CADDY=STOPPED` observed. Independent no-listener/no-rule postcheck not yet submitted for this attempt.
- **Classification**: `PUBLIC_TLS_TRUST_UNVERIFIED / USER_LIVE`; **NOT** `ACME_CA_REJECTED` and **NOT** a public trusted certificate PASS. Could be CA issue, ACME validation challenge/network path, issuance/storage timing, or local `curl.exe` result. Actual cause UNKNOWN pending Caddy process log (script suppresses curl stderr). Previous independent external IPv6 TCP443 OPEN remains valid as a separate network-path proof.

**Next ONLY read-only actions** (no further certificate issuance, avoid CA rate limits): inspect latest `%TEMP%\mcp-p2-443-*\caddy-stderr.log` (and stdout if needed). Extract `tls.obtain` and `http.acme_client` issuance attempts, `challenge failed`, `problem.type/detail`, `certificate obtained successfully`, `authorization failed`, `rateLimited` and any Caddy error message. Redact residential domain/IPv6/account URLs/credentials before sharing; never publish full local logs to this public repo. Verify Windows post-check scoped firewall and TCP443 listener counts read-only. Source: Caddy official troubleshooting https://caddyserver.com/docs/troubleshooting .

**STOP:** Do not rerun PR #8 until specific root cause is established. Public-CA/CT consent covered one time-boxed test, not unlimited retries. ChatGPT regular Chat MCP `/mcp` remains CLOSED/UNVERIFIED, no public proxy deployed.

## Public CA certificate test: explicit owner approval — 2026-11-15

- Owner directly **APPROVED** the separate stock-Caddy public **ACME TLS-ALPN-01 static-only certificate test**, after being notified that registered hostname may appear in **Certificate Transparency logs** and CA account/certificate/key storage can persist. Scope: exact laptop IPv6 TCP443 only, Windows Private ActiveStore rule scoped to Caddy executable, **300 seconds** bounded exposure and independent expiry watchdog. **No public MCP**, no CDP 9444, no router login, no port80/DNS provider/token.
- [PR #8](https://github.com/trung-via/mcp-gateway/pull/8) moved DRAFT → **READY FOR REVIEW**, still OPEN / **UNMERGED**, observed head `5ca05e345389e42ab94388ba24672513acbba836`.
- Both relevant PR-head CI runs PASS: [PS7 AST+static safety](https://github.com/trung-via/mcp-gateway/actions/runs/43661218609) and [MCP protocol/ASGI](https://github.com/trung-via/mcp-gateway/actions/runs/43661218555). **Neither executed ACME/Windows firewall on laptop.**
- **Next LIVE proof owner:** operator runs `p2-public-tls443-static-probe.ps1` from PR #8 in elevated PowerShell 7, with `-Hostname` set locally, `-DurationSeconds 300 -ApprovePublicACME`, and reports `PUBLIC_TLS_TRUST=PASS_VALIDATED_WITHOUT_INSECURE` or failure, normal cleanup `FIREWALL_TEST_RULE=REMOVED` and `TEMP_CADDY=STOPPED`, independent 0 listener/0 rule check. Logs (if any) must be redacted before sharing. **PUBLIC_CA_ISSUANCE_UNVERIFIED** until those receipts.
- Permission only covers bounded certificate/static route proof. A future public `/mcp` reverse proxy and real ChatGPT caller need separate security/reachability verification.

## Public CA TLS-ALPN-01 static-only staging PR #8 — 2026-11-15

- **SOURCE preparation only**: [Draft PR #8](https://github.com/trung-via/mcp-gateway/pull/8), branch `p2/trusted-tls-alpn-01-static-probe-20261115`, head last observed `5ca05e345389e42ab94388ba24672513acbba836`, **OPEN / DRAFT / UNMERGED**.
- Reuses the tested isolated Caddy/exact-global-IPv6 TCP443 + scoped Windows Private ActiveStore rule and detached cleanup watchdog, but **replaces `tls internal` with public ACME `issuer acme { disable_http_challenge }`** to force **TLS-ALPN-01** validation on **443 only**. **NO port80; NO dynv6 DNS module/token; NO MCP reverse proxy**. Test route serves a fixed static body, 404 otherwise; existing localhost Caddy 8443 / MCP 18080 untouched.
- New PowerShell `scripts/p2-public-tls443-static-probe.ps1` **fails closed without explicit `-ApprovePublicACME`** and only marks `PUBLIC_TLS_TRUST=PASS_VALIDATED_WITHOUT_INSECURE` when local curl validates the exact hostname and static response using normal OS certificate trust (no `-k` or `--insecure`). 300s default bounded exposure, watchdog at +30s, rollback scoped firewall rule/process only. Caddy ACME account and cert/key might persist in default Caddy storage.
- **Risk/approval:** contacting a public CA and obtaining a trusted certificate is a new external effect. The home hostname may enter public Certificate Transparency logs. This requires **separate explicit operator approval** before running on laptop. Earlier dynv6 API token must be rotated privately if ever used in another DNS update; no API token is needed for TLS-ALPN-01.
- **[Windows CI run 43661218609](https://github.com/trung-via/mcp-gateway/actions/runs/43661218609) SUCCESS**: PS7 AST parse of the script and watchdog plus static fail-closed/no-proxy/firewall constraints. CI does **not** issue cert or prove live TLS. Runbook in `docs/p2-public-tls-alpn01-static-gate.md`.
- **State:** direct IPv6 TCP443 ingress from independent source **LIVE PASS** (prior trial), **public CA issuance NOT_STARTED**, **normal ChatGPT IPv6-only server /mcp invocation NOT_STARTED**. Issue #2 stays OPEN. No router login/Tunnel/Render/Work, no CDP 9444 or private data exposed.

## IPv6 direct inbound PASS with independent remote checker — 2026-11-15

Human actually ran enhanced [PR #7](https://github.com/trung-via/mcp-gateway/pull/7) 180-second script on the Windows laptop. **Source:** operator PowerShell transcript, not CI-only:

```text
REMOTE_IPV6_CHECKER_CONTROL=PASS
LOCAL_IPV6_HTTPS_STATIC=PASS
REMOTE_IPV6_TCPDATA_STATUS=OPEN
TEMP_IPV6_443_LISTENER=BOUND
FIREWALL_TEST_RULE=SCOPED_ACTIVE
MCP_BACKEND_EXPOSED=NO
TLS_CERTIFICATE=INTERNAL_TEST_ONLY
TEST_WINDOW=EXPIRED
FIREWALL_TEST_RULE=REMOVED
TEMP_CADDY=STOPPED
```

**ACCEPTED EVIDENCE**: `DIRECT_IPV6_TCP443_INGRESS_PASS / USER_LIVE` for a bounded external TCPData check reporting **OPEN** via an IPv6-capable source, after successful known IPv6 positive control and exact local global-IPv6 HTTPS response. This is stronger than prior invalid phone probe (no IPv6 capability). **Previous router IPv6 ingress UNKNOWN is updated: in this specific trial inbound TCP443 was reachable.** Router admin access remains unavailable and unnecessary. **No HTTP static body was observed from the external checker**, only its reported TCP/HTTPS port OPEN status.

**Safety evidence:** isolated static-only Caddy with internal, untrusted test certificate; MCP backend EXPOSED=NO; firewall scope ACTIVE during test; 180-second expiry with `FIREWALL_TEST_RULE=REMOVED`, `TEMP_CADDY=STOPPED`. Additional independent 0/0 post-check is not in this turn's transcript, so do not assert it was rerun for trial #2. No permanent 443 service or firewall approval from this test.

**Next gate (proposed, separate approval):** stock Caddy **ACME TLS-ALPN-01** to obtain a real publicly trusted certificate using only inbound TCP443. No DNS-01 plugin, dynv6 API token or port 80 needed; use a **static-only** Caddy proof route first and no MCP reverse proxy. Verify certificate with a normal TLS client **without `-k`** and capture issuer/chain/expiry without sharing residential IPv6. Use scoped ActiveStore firewall, watchdog, bounded expiry and safe rollback; ACME issuance may persist Caddy certificate material and contact public CA, so do not execute until explicitly approved. Then a separately authorized read-only `gateway_health` public MCP + ChatGPT Chat actual tool call. **ChatGPT ability to connect to IPv6-only endpoint is still UNVERIFIED**.

Official background: https://caddyserver.com/docs/automatic-https (TLS-ALPN-01 requires 443), https://caddyserver.com/docs/caddyfile/directives/tls and https://developers.openai.com/plugins/deploy/connect-chatgpt . The PUBLIC repo must not include residential global IPv6, hostname, local Windows username or earlier dynv6 token.

## P2 trial #2 independent TCPData IPv6 checker code ready — 2026-11-15

**Reason:** first external mobile phone test was INVALID_REMOTE_PROBE_CLIENT_NO_IPV6 (human screenshot: mobile IPv6 unavailable, 0/10); no evidence yet that upstream router passes or blocks inbound IPv6. User approved continuing with a third-party IPv6-aware TCP checker knowing it may receive/store the residential destination IPv6/hostname.

**GitHub CODE update (not laptop execution):** updated existing [PR #7](https://github.com/trung-via/mcp-gateway/pull/7) PowerShell script to add explicit `-UseTcpDataIPv6Probe`. Before opening any listener/firewall, a remote checker positive control to `ipv6.google.com:443` must return OPEN; if it fails, STOP with no Windows mutation. During the previously approved isolated static-only HTTPS TCP443 test window, curl self-checks exact host global IPv6 via test-only `--insecure`; if local static response does not match, cleanup occurs before remote scan. If it matches, TCPData receives the laptop's literal IPv6 for external check and only status is printed (OPEN/CLOSED/TIMEOUT/INCONCLUSIVE_PROVIDER_ERROR), never the raw IP. The existing ActiveStore scoped firewall rule, 180s window, isolated Caddy and expiry watchdog remain unchanged. No MCP/backend, CDP, router or DNS changes.

[Windows CI run 43659758085](https://github.com/trung-via/mcp-gateway/actions/runs/43659758085) **PASS** for PowerShell parse and static safety checks at updated PR head `9753377a81777f719f48c5df50f03b3d378f4fc5`; **NOT A LIVE provider/Windows network test**. TCPData [docs](https://tcpdata.com/docs/port-check) say accepts IPv6 literals but uses HTTPS for port443, so non-open outcomes can be **ambiguous due untrusted internal CA**. No proof of upstream router blocking is permitted from such result alone.

**Next:** elevated Windows PowerShell fetch updated branch into temporary local script paths; rerun with `-UseTcpDataIPv6Probe` once, read positive control/local HTTP/external status and cleanup receipts; abort before exposure on third-party control failure. Prior windows trial cleanly rolled back, current port 443 closed. Public TLS/ChatGPT native MCP still unverified; no router login, Tunnel/Render/Work.

## Mobile IPv6 source failure diagnosed — 2026-11-15

Human screenshot of **test-ipv6.com via the mobile-data test connection** showed **no client IPv6 address detected**, **IPv6-only sites time out**, and **IPv6 readiness 0/10**. Ordinary IPv4 connectivity works; resolver IPv6 availability does not prove the phone has usable IPv6. Never copy the displayed public phone IPv4 into this public repo.

**Reclassification:** mobile browser `ERR_CONNECTION_TIMED_OUT` for the IPv6-only dynv6 URL occurred with a demonstrated **CLIENT_WITHOUT_IPV6**. The 180-second external trial #1 is **INVALID_REMOTE_PROBE_CLIENT_NO_IPV6**, **not** evidence of home router/ISP IPv6 filtering. Windows limited test Caddy bind/rule/cleanup receipts remain PASS, postcheck 0 listener + 0 rule. **Direct IPv6 inbound from a properly capable remote peer remains UNVERIFIED**.

**Next minimal independent validation:** use only a remote source known to have IPv6, e.g. a trusted remote machine or a third-party IPv6-supported TCP443 checker (public documentation example: https://tcpdata.com/docs/port-check). A public web checker may learn the target hostname/residential IPv6: secure the operator's consent and do not publish its results verbatim in public GitHub. If/when a repeat probe is approved, keep its isolated static HTTPS/443, time limit and rollback; no public MCP, CDP, router login, Tunnel/Render/Work. Trusted TLS and ChatGPT normal Chat remain separate gates. Existing phone cannot be used for this direct IPv6 verification until its mobile IPv6 capability changes.

## Ingress trial #1 mobile timeout diagnostic — 2026-11-15

Owner reported the actual phone browser error **`ERR_CONNECTION_TIMED_OUT`** for the previous static HTTPS IPv6 TCP443 test. This is **not** a certificate-authority error and supplies no evidence that TLS handshake succeeded. **REMOTE_IPV6_443=FAILED_TO_CONNECT / ROOT_CAUSE_UNKNOWN**. Earlier Windows test process started, bound global IPv6 TCP443 and installed scoped rule, then expired and cleaned up with postcheck 0 listeners / 0 rules.

Two missing qualifiers before assigning blame:
1. Phone mobile-data IPv6 capability (Wi-Fi OFF; `https://test-ipv6.com/` gives IPv6 connectivity summary; do NOT collect phone/home IP values).
2. Did browser attempt occur during live 180-second window when `FIREWALL_TEST_RULE=SCOPED_ACTIVE` or after `TEST_WINDOW=EXPIRED`?

If either is unconfirmed, this test cannot isolate router/ISP blocking. If both PASS, investigate Windows host-side IPv6 listener/response path and an independent off-LAN packet witness in a **separately controlled, explicitly scoped** test. Caddy logs alone may not log dropped TCP SYN. No router login, no new firewall opening, no Tunnel/Render/Work; public trusted HTTPS and ChatGPT tool-call remain UNVERIFIED.

## IPv6 TCP443 ingress trial #1 — operator Windows witness 2026-11-15

**USER_LIVE actual laptop test via PR #7**: isolated static-only Caddy on selected global IPv6 TCP443 started with `TEMP_IPV6_443_LISTENER=BOUND`, narrow ActiveStore firewall rule `SCOPED_ACTIVE`, internal/test-only certificate, and `MCP_BACKEND_EXPOSED=NO`. Window was 180 seconds. Main process and independent watchdog design supplied; observed normal termination `TEST_WINDOW=EXPIRED`, `FIREWALL_TEST_RULE=REMOVED`, `TEMP_CADDY=STOPPED`. Final read-only PowerShell counts: **443 listeners=0 and temporary firewall rules=0**. **LOCAL_START_CLEANUP_PASS**.

**External phone report:** *could not connect to URL*. **REMOTE_INGRESS_NOT_CONFIRMED / FAILURE_CAUSE_UNKNOWN**; no exact browser failure, phone cellular IPv6 status, TLS cert warning, off-LAN IPv6 evidence or inbound packet trace supplied. Do not claim router blockage based on one ambiguous phone attempt. Browser certificate warning is expected for the intentionally untrusted test CA and is a different diagnostic class from timeout/refused. DNS AAAA+local IPv6 MATCH before start is not proof that a remote phone resolves/routes IPv6.

**Next no-mutation triage:** with Wi-Fi OFF and mobile data ON, test phone IPv6 connectivity via test-ipv6.com and report only IPv6 readiness (no personal IP). Recover exact mobile browser error for attempted test (timeout, unreachable, certificate invalid, refused, etc); note test window must have been active when URL was opened. If phone IPv6 PASS but no remote contact, plan a new separately scoped host-side local public-IPv6 self-check and independent off-LAN SYN/HTTPS witness, with packet capture or Windows firewall log ONLY if approved, to distinguish host filtering from router/ISP filtering. Keep firewall/443 fully closed meanwhile. No router login requests, Tunnel/Render/Work, or exposure of CDP 9444 or MCP backend 18080.

## Temporary IPv6 443 ingress probe PR #7 — approved scope, unexecuted (2026-11-15)

- **Human approval:** user explicitly approved proceeding with the previously defined bounded IPv6 inbound TCP443 test that requires no router login. Approval is for this temporary, single-port, test-only exposure, NOT permanent public MCP, unrestricted host permissions, or production rollout.
- **[PR #7](https://github.com/trung-via/mcp-gateway/pull/7) READY FOR REVIEW / OPEN / UNMERGED**, isolated branch `p2/ipv6-443-temporary-ingress-probe-20261115`; current observed head `054063dbc30de621f2ba2e4a95e72024a71feab8`.
- Source: `scripts/p2-ipv6-443-temporary-probe.ps1`, companion detached cleanup watchdog, operator instructions `docs/p2-ipv6-443-temporary-ingress-probe.md`, and Windows AST/static security workflow.
- **[Windows CI 43656736822](https://github.com/trung-via/mcp-gateway/actions/runs/43656736822) SUCCESS** at this head: PowerShell AST parse for both scripts and static safety markers. This does **NOT** prove actual Windows firewall or Caddy execution.
- Bounded effect on laptop when **operator runs it**: new Caddy instance only, `tls internal`, single fixed static response at test path, exact global IPv6 TCP443, `admin off`, no `reverse_proxy`; one unique temporary ActiveStore Windows Private allow rule limited to exact local IPv6, 443 and Caddy program; 180-second limit + independent +30-second watchdog; emergency scoped cleanup. Existing 127.0.0.1:8443 Caddy, 127.0.0.1:18080 MCP and CDP 9444 never exposed or stopped.
- **CURRENT EVIDENCE:** SCRIPT CODE+CI PASS; **WINDOWS_EXECUTION_UNVERIFIED, INGRESS_EXTERNAL_UNVERIFIED**. User must run from elevated PowerShell 7 and test via mobile cellular data (Wi-Fi OFF), with IPv6-capable operator network. Internal self-issued certificate warning is expected. Return exact static HTTP response vs certificate warning vs timeout; do not infer router block if phone has no IPv6.
- **STILL REQUIRED** after ingress success: publicly trusted TLS, rotated dynv6 credential if provider API ever used, and real normal ChatGPT custom MCP Server URL tool-call witness. Never claim public MCP live from this static probe alone. No router login, Tunnel, Work or Render.

## Windows no-mutation IPv6 preflight PASS — 2026-11-15

**Human actual laptop execution (PowerShell 7):** fetched Draft [PR #6](https://github.com/trung-via/mcp-gateway/pull/6) script `scripts/p2-windows-ipv6-preflight.ps1` via Git `FETCH_HEAD` into local temp location (without switching the repo branch); executed with the operator's actual dynv6 hostname. Output was exactly:

```text
WIFI_PROFILE=Private
IPV6_INTERNET=PASS
EFFECTIVE_INBOUND_DEFAULT=Block
DNS_TO_LAPTOP=MATCH
PORT_443=NOT_LISTENING
MCP_BACKEND_18080=LOOPBACK_ONLY
CADDY_ALPN_PREVIEW_ADAPT=PASS
CADDY_DYNV6_DNS_MODULE=ABSENT
NO_MUTATION=No listeners, firewall rules, DNS records, router settings or certificates changed
SECURITY_STOP=Do not run either preview without separate scoped approval
```

The script also wrote two inert `Caddyfile.*.preview` files under the **user's home directory**. Exact home path and current global IPv6 bind value intentionally omitted from public GitHub. These previews are **NOT** permission to run a public listener. No token was used/read. This is **WINDOWS_P2_PREFLIGHT_PASS / USER_LIVE**, and a separate, current GitHub [CI run 43654864139](https://github.com/trung-via/mcp-gateway/actions/runs/43654864139) was reported SUCCESS on the PR branch's latest known commit; **CI only runs Python MCP/ASGI tests, not the Windows PowerShell script**, so user-observed Windows preflight is the direct witness.

**Gate complete:** source and dry-run preflight readiness. **Still BLOCKED**: public trusted TLS cert, router IPv6 ingress (router login unavailable), IPv6 external-network reachability to laptop, ChatGPT normal Chat plugin tool invocation, prior exposed dynv6 token rotation confirmation.

**NEXT / security review before any public change:** audit current active TCP 443 allow rules (read-only), define one temporary Caddy IPv6/443 listener and narrowly scoped Windows Private inbound rule with explicit user approval, set an external IPv6 client and a bounded time/rollback procedure. Do not run the preview nor install DNS module yet. If router firewall drops unsolicited IPv6, no host-side workaround can fix it within the accepted direct-no-tunnel architecture.

## Caddy dynv6 module absent (user observed) — 2026-11-15

- Human ran `caddy list-modules | Select-String "dns.providers.dynv6"` on their Windows laptop and returned **no matching output**. Current Caddy binary does not include the optional dynv6 DNS provider. **NOT A GATEWAY FAILURE**; previous local HTTPS MCP JSON-RPC `gateway_health` remains PASS.
- DNS-01 via Caddy currently requires an independently audited custom provider build and a **rotated** dynv6 API credential; neither is authorized or installed. **Defer DNS-01 plugin installation** until external IPv6 inbound viability is established and the added complexity is justified.
- Draft PR #6 runbook updated to log this evidence; PR remains unmerged and its preflight PowerShell remains unexecuted on Windows. Next safe step: fetch only the PR script into a temporary location without switching the active working branch; inspect/run dry-run to check binding and Caddyfile syntax. It makes no firewall/router/listener/credential changes; only writes inert previews in user's home directory.
- The user cannot log in to router and must not be asked again. No Tunnel/Render/Work as default. Separate scoped approval needed before any public 443 listener/firewall change.

## P2 no-router direct IPv6 preflight draft PR #6 — 2026-11-15

- [Draft PR #6](https://github.com/trung-via/mcp-gateway/pull/6) OPEN / **UNMERGED**, branch `p2/windows-ipv6-no-router-preflight-20261115`, latest observed PR head `d2d6a04819d4517e8d383a3718d39eb63b525465`.
- New runbook `docs/p2-windows-no-router-ipv6.md`: distinguishes certificate issuance by dynv6 DNS-01 **without** router/ingress from actual external IPv6 reachability test. Caddy dynv6 plugin exists as a community module and needs independent security review and rotated token; stock Caddy may lack it.
- New Windows PowerShell 7.0 dry-run preflight `scripts/p2-windows-ipv6-preflight.ps1`: reads DNS AAAA, `SuffixOrigin=Link` selected local IPv6, effective Private inbound Block, backend loopback listener, absence of TCP 443 listener and Caddy DNS module presence; writes only two inert preview Caddyfiles locally with exact IPv6 TCP 443 ALPN or loopback-only DNS-01; **no router login/port edits, Firewall edits, listener startup, certificate requests, DNS updates or secrets**.
- **Evidence tier: SOURCE preparation only; draft PR script has not been executed on Windows or reviewed by CI; it is not deployed.** User-proven local HTTPS MCP protocol/tool call remains PASS. Public TLS trust, router IPv6 ingress, external MCP, and ChatGPT Chat tool call remain UNVERIFIED.
- Next: operator read-only `caddy list-modules | Select-String dns.providers.dynv6`, independent PR review and dry-run on Windows. Do not activate any public port without separately scoped human approval and rollback. No Tunnel, Render, Work or CDP 9444 exposure.

## Router administration unavailable — fixed user constraint (2026-11-15)

**Explicit Human correction:** The owner previously stated and reiterated they **cannot log in to the home router `192.168.1.1`**. Previous Brain guidance incorrectly requested router login again. **Do not ask again for router admin UI, credentials, model/settings requiring authentication, port forwarding or IPv6 firewall changes inside the router.** Treat this as a hard operator constraint.

- **Accepted direction unchanged:** MCP Gateway self-hosted on Windows laptop, public dynv6 hostname → direct IPv6 HTTPS → Caddy → read-only MCP; no Tunnel, Work, Render, or CDP 9444 exposure as default.
- **Observed:** DNS AAAA to laptop MATCH; IPv6 outbound Internet; local Caddy TLS/JSON-RPC initialize+ready+gateway_health PASS; Wi-Fi Private; effective Windows firewall default inbound Block; only `127.0.0.1:8443` and `127.0.0.1:18080` listeners. These **do not** prove upstream router IPv6 inbound policy.
- **Feasible no-router-login probe, NOT yet authorized or executed:** prepare a production-ready narrow Caddy public IPv6/443 listener hosting only `gateway_health`; require public CA validation (TLS-ALPN-01 on 443 if router permits; DNS-01 only with suitable provider); temporarily add one Windows Private inbound TCP 443 allow rule tied to expected Caddy process/program, with explicit Human approval, duration, external test plan and rollback. Independently test IPv6/443 from an off-LAN IPv6-capable client (e.g., phone cellular or trusted external probe). No router access is needed **to attempt** this test.
- **Crucial conditional blocker:** If router's inbound IPv6 firewall blocks unsolicited traffic, **Windows-side changes cannot bypass it**. Classify `ROUTER_IPV6_INGRESS_BLOCKED_OR_UNKNOWN` until independent test. The remaining routes then require ISP/router operator cooperation or an **explicit separate user architecture decision**, not repeated router-admin requests or silent Tunnel/Render deployment.
- **Safety**: existing dynv6 token had previously appeared in a screenshot; rotation remains unverified and must happen privately. No public port exposure or firewall changes without scoped approval. No unrestricted Windows rights.

## Effective Windows firewall ActiveStore and Wi-Fi category — 2026-11-15

User provided **read-only Windows PowerShell** output (actual laptop, Wi-Fi interface):
- `Get-NetConnectionProfile -InterfaceAlias Wi-Fi`: **`NetworkCategory=Private`**, **`IPv6Connectivity=Internet`**.
- `Get-NetFirewallProfile -PolicyStore ActiveStore`: **Domain, Private, Public all `Enabled=True` and `DefaultInboundAction=Block`**.
- This resolves the earlier `PersistentStore=NotConfigured` ambiguity. **Effective default unsolicited inbound traffic is blocked unless a more specific allow rule applies**. IPv6 Internet connectivity only establishes network connectivity and does **not** imply unsolicited WAN IPv6 ingress.
- Previous listener snapshot: `127.0.0.1:8443` (Caddy test CA), `127.0.0.1:18080` (MCP read-only backend); **no listeners on 80/443**. Full local HTTPS MCP initialize/ready/`gateway_health` already PASS.
- **Remaining gate:** router's IPv6 WAN inbound security/filtering and support for a host-specific TCP 443 rule are **UNVERIFIED**. No Windows allow rule, WAN-facing Caddy listener, router exception or public CA certificate exists in observed evidence.
- **Superseded by Human constraint:** router login/UI inspection is unavailable and must never be requested again. Next is a Windows-side narrow external IPv6/443 reachability probe only after explicit scoped approval; if upstream router IPv6 firewall blocks it, Windows alone cannot fix that.
- **Future bounded exposure proposal, NOT approved/implemented**: Caddy-only IPv6 TCP 443 listener; narrow Windows Private inbound allow for only that TCP port and application, no 18080/8443/9444 exposure; router host-specific IPv6 exception if needed; publicly trusted TLS via Caddy ACME TLS-ALPN-01 on 443 (or HTTP-01 needing additional port 80, or DNS-01 with separate DNS integration). Prefer proof through independent external IPv6 and normal ChatGPT plugin before calling P2 DONE. Human must explicitly approve scoped changes and rollback. No Tunnel, Work or Render as default.

## Windows firewall and listener preflight — 2026-11-15

Human-provided Windows PowerShell read-only `Get-NetFirewallProfile` and listener outputs:
- Three firewall profiles **Domain, Private, Public `Enabled=True`**, each showed `DefaultInboundAction=NotConfigured` in the query's default/persistent policy store. **Do not infer an allow-all or block-all effective result from `NotConfigured`.** Default action in the actually applied profile and any effective inbound allow rules remain unverified; Microsoft recommends `Get-NetFirewallProfile -PolicyStore ActiveStore` for resultant effective policy.
- `Get-NetTCPConnection -State Listen` filtered to 80/443/8443/18080 returned **only** `127.0.0.1:8443 Listen` (Caddy test TLS) and `127.0.0.1:18080 Listen` (read-only MCP backend). No listeners on **80 or 443** at this observation. This is an expected safe baseline, **not** proof of public IPv6 reachability. No public listener or inbound firewall/router change was made.
- Existing direct local HTTPS MCP `initialize 200` + `ready 202` + `gateway_health 200` **PASS** still stands.
- **Next read-only Windows evidence COMPLETED (2026-11-15):** Wi-Fi Private + IPv6 Internet; `ActiveStore` Domain/Private/Public Enabled True, DefaultInboundAction Block. Next inspect router IPv6 WAN firewall and existing effective inbound TCP 443 rules; no mutation.
- **Next router evidence**: IPv6 WAN inbound/perimeter firewall support and per-device exceptions for TCP 443; as yet **UNVERIFIED**. Without router access, user-provided router UI details are needed before any targeted ingress plan.
- **Public certificate consideration**: Caddy automatic TLS normally needs externally reachable port 80 for HTTP-01 or 443 for TLS-ALPN-01; separate DNS-01 challenge needs supported DNS API module/secret. No ACME/public TLS attempts before an approved network plan. Scope is HTTPS port 443 to Caddy only; never open CDP 9444 or backend 18080, disable Windows Firewall, or use Tunnel/Render/Work as primary.

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
