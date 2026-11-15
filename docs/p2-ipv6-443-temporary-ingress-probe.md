# GATEWAY-P0-004: temporary direct IPv6 TCP 443 HTTPS probe

Status: SOURCE ONLY. The owner approved a short, bounded external IPv6/TCP443 test. This script has NOT yet been executed on the Windows host.

## Source-only preparation: multi-source IPv6 reachability after CA failure (2026-11-15)

**Current source stage: PREPARED IN PR #7, NOT EXECUTED FOR THIS NEW TEST.** After three bounded ACME issuance trials, the latest Caddy TLS-ALPN-01 challenge was rejected by the CA with "Unable to contact <HOST> at <IPV6>, no IPv4 addresses to try as fallback". A previous independent TCPData IPv6/443 static probe reported OPEN in a *different* trial window. Three external DNS resolvers currently return one AAAA each matching the laptop, but that does not reconstruct the CA-time DNS. The next meaningful test isolates **remote source-dependent TCP connectivity from certificate issuance**, without any ACME contact.

### Explicit authorization and strict timing

The owner approved **source preparation** of a static-only, non-CA, multi-source IPv6/443 measurement with a temporary Windows rule lasting **no more than 180 seconds**. That decision does **not** authorize an unreviewed Windows execution or repeated CA attempts. Script changes are PR-only; no router/firewall/DNS/laptop mutation occurred by writing these files.

- PowerShell script requires **-ApproveTemporaryIngress** before any listener/rule and **-ApproveRemoteProbeDisclosure** when using the new remote checkers. The services may record or retain the public IPv6 and test metadata. No secret token is sent.
- **-DurationSeconds** is now constrained to **60–180**, and independent watchdog starts *before* the temporary ActiveStore rule with delay **DurationSeconds** (not duration+30). Main script attempts cleanup **15 seconds earlier** than this ceiling. The watchdog only removes the test rule and stops the exact matching temporary Caddy executable/config, and cannot change other Caddy services. This is best-effort fail-safe; independent 0/0 postcheck remains mandatory.
- Caddy still serves **only one fixed static body** on exact selected global Wi-Fi IPv6 TCP443 using **tls internal**, no public ACME, no HTTP80, no MCP reverse proxy, no CDP/HostOps/Windows adapters, and no changes to existing 8443/18080 endpoints.
- Before exposure, the script validates Private firewall default inbound Block, unique preferred global IPv6, matching public AAAA, absence of TCP443 listener and a companion watchdog. The multi-source mode also demands TCPData can reach IPv6-only \`ipv6.google.com:443\` **and two Check-Host nodes in distinct ASNs** can prove their successful destination addresses were IPv6. If controls fail, it **aborts before opening TCP443**.
- During the **same** short window, Caddy's HTTPS static response is locally checked with curl using only **test-specific** \`--insecure\` for the intentionally untrusted internal CA. The script queries TCPData and Check-Host target **IPv6 literal:443**; a Check-Host node counts as PASS only when its result includes the exact selected target IPv6 and TCP connection time. Otherwise status remains FAILED_OR_INCONCLUSIVE. Provider timeout/schema changes must **not** be interpreted as a definitive router/ISP block. This is **TCP evidence**, not independent remote TLS-SNI/ALPN proof.

### Operator command (review-only, not permission to run)

After exact PR #7 HEAD and Windows CI are reviewed and a separate native host execution approval is confirmed, run once from elevated PowerShell 7, with both scripts fetched from pinned commit without changing the checked-out branch:

~~~~powershell
# Example ONLY. Fetch and PIN the reviewed Git commit before execution.
& (Join-Path $testDir "p2-ipv6-443-temporary-probe.ps1") -Hostname "your-host.dynv6.net" -DurationSeconds 180 -UseMultiSourceIPv6Probe -ApproveTemporaryIngress -ApproveRemoteProbeDisclosure
~~~~

Expected safe markers: REMOTE_TCPDATA_IPV6_CONTROL=PASS, REMOTE_CHECKHOST_IPV6_DISTINCT_ASN_CONTROL=PASS, FIREWALL_READY_UTC, MAX_FIREWALL_WINDOW_SECONDS=180, LOCAL_IPV6_HTTPS_STATIC=PASS, REMOTE_IPV6_TCPDATA_STATUS, REMOTE_CHECKHOST_NODE statuses / REMOTE_CHECKHOST_IPV6_SUCCESS_COUNT, and cleanup \`FIREWALL_TEST_RULE=REMOVED\`, \`TEMP_CADDY=STOPPED\`. **Confirm after return**: 0 local TCP443 listeners; 0 ActiveStore rules with exact display name. No TCP OPEN outcome can establish a public CA certificate, HTTP trust or normal ChatGPT MCP tool-call.

### How to distinguish TCP from full TLS remotely

For **remote TLS/HTTP SNI** evidence, a separately controlled machine with known IPv6 egress (not the phone previously shown IPv6-incapable) can, during the active window, run the command below. The \`--insecure\` applies **only** to this test-only private Caddy CA. The hostname preserves SNI and the resolved IPv6 pins the destination, with no system-wide trust-store changes:

~~~~bash
# Run on an independently IPv6-capable remote machine while test is active.
curl -6 --insecure --http1.1 --resolve 'your-host.dynv6.net:443:[YOUR_LAPTOP_GLOBAL_IPV6]' --connect-timeout 3 --max-time 8 'https://your-host.dynv6.net/__mcp_p2_ipv6_ingress_probe'
~~~~

Expected literal response: \`MCP_P2_IPV6_TCP443_REACHABLE\`. If no such independent remote machine exists, mark \`REMOTE_TLS_SNI_HTTP=UNVERIFIED\` rather than substituting a local curl PASS. **The previous mobile data connection has no IPv6** and must not be treated as an external IPv6 TLS client. Remote IP/hostname must not be published to GitHub.

### Interpretation and response to ambiguity

1. At least two Check-Host ASN-distinct IPv6 nodes plus TCPData OPEN, same window => multiperspective **TCP443 ingress** observed; does not prove Let's Encrypt validation.
2. Mixed success/timeouts across checkers => source-/path-dependent filtering or provider artifacts are hypotheses; investigate read-only firewall/profile/capture and network behavior before another test.
3. All sources fail but local HTTPS passes => externally visible path likely blocked during that window, but root (router/ISP/firewall/filter) still **UNKNOWN**.
4. Remote verified IPv6 curl with exact body => external TLS SNI + HTTPS static endpoint PASS **for that specific source and window**, not public certificate trust. If it times out, verify that remote client has IPv6 and test window is active.
5. Failed provider positive control => script exits before public exposure; no negative claim about laptop ingress.

**Hard STOP:** no fourth ACME test, no router access, no Tunnel/Render/Work, no dynv6 API token, no blanket firewall allowance, no public MCP/CDP route. Review the new Windows CI before proposing any native run.

Sources: [TCPData documented IPv6 port-check API](https://tcpdata.com/docs/port-check) and [Check-Host multi-node TCP API](https://check-host.net/about/api). Check-Host node ASN/IPv6 support is verified at runtime; not assumed from provider documentation.

## Trial #2: externally sourced IPv6 check (2026-11-15)

**Observed trial #1:** laptop's test Caddy listener and exact scoped ActiveStore firewall rule started, then cleaned up with postcheck zero. However, mobile 5G could not reach the URL. A later human screenshot from test-ipv6.com showed mobile IPv6 **UNAVAILABLE / 0-of-10 readiness**. The phone cannot serve as an IPv6 inbound test client; router/ISP ingress is still **UNVERIFIED**, not blocked.

**Owner accepted continuing with a third-party IPv6-capable external checker** after being told the checker will learn the target's public hostname/IP. Optional command-line switch `-UseTcpDataIPv6Probe` turns this on; omitted switch performs *no third-party request*. The provider's [documented TCP/port endpoint](https://tcpdata.com/docs/port-check) supports IPv6 literals and reports `open`, `closed`, or `timeout`, but it **also attempts HTTPS on TCP 443**.

The enhanced script:
1. Checks a positive control `ipv6.google.com:443` through the provider **before starting Caddy/opening firewall**. If the provider cannot return `open` via IPv6, the test **aborts before exposure**.
2. Starts the same isolated static-response Caddy on the laptop's exact global IPv6/443 with the 180-second ActiveStore rule and existing expiry watchdog.
3. Validates local GET to that exact global IPv6 using curl with test-only `--insecure` (because `tls internal` is intentionally untrusted). `LOCAL_IPV6_HTTPS_STATIC=PASS` is required before remote attempt, reducing host-side ambiguity.
4. Sends the **literal public IPv6** only to `tcpdata.com` while the temporary listener is active. The third party may log/retain it; there is no confidentiality guarantee. Response is summarized as `REMOTE_IPV6_TCPDATA_STATUS=OPEN|CLOSED|TIMEOUT|INCONCLUSIVE_PROVIDER_ERROR` and raw IPv6/response is not printed to terminal or public GitHub.
5. Normal test cleanup and watchdog remove the rule/stop only the new Caddy. `0/0` postchecks are required. **OPEN** is a useful remote observation, but `CLOSED` and `TIMEOUT` are **not** definitive router evidence, because the provider attempts HTTPS and may reject the internal CA; use a plain TCP checker with confirmed IPv6 support if results remain ambiguous.

### Single-window operator run (only after reviewing this script)

Open PowerShell 7 **Run as Administrator**. Re-fetch the **updated** PR branch and copy both scripts using the commands in the next section, then invoke:

~~~~powershell
& (Join-Path $testDir "p2-ipv6-443-temporary-probe.ps1") -Hostname "your-hostname.dynv6.net" -DurationSeconds 180 -UseTcpDataIPv6Probe
~~~~

This does not require a phone or router login, Tunnel/Render/Work, dynv6 API token, custom Caddy DNS module, or public CA certificate. If external provider preflight fails, **stop** and diagnose checker access without opening a new firewall rule.

**Evidence at time of authoring:** code change prepared in branch; enhanced script **not yet executed on Windows** and remote public IPv6 result not yet obtained. Do not claim ingress PASS based on CI or local bind alone.

## Scope and safety

This test is not a public MCP server. A separate Caddy instance serves ONE fixed test-only body at /__mcp_p2_ipv6_ingress_probe and HTTP 404 elsewhere. There is no reverse proxy, no CDP 9444, no host adapter, no GitHub tool, and no private project data.

The test Caddy binds a single preferred IPv6 address of the laptop and port 443, not all interfaces. It uses tls internal; a test-only internal CA is not publicly trusted. Admin API and automatic HTTP redirect are disabled. The existing localhost Caddy 8443 and MCP backend 18080 are unchanged.

Windows Firewall grants only the currently selected IPv6, TCP 443, the exact Caddy binary, and Private profile. The firewall rule is created in ActiveStore (temporary/nonpersistent). The main script cleans it and the launched Caddy process after 180 seconds by default; a separate detached watchdog attempts cleanup 30 seconds later if the invoking PowerShell window closes.

No router login is possible and none is requested. No Tunnel, Work or Render. No dynv6 tokens, DNS updates, public certificate requests, trust-store changes or broad firewall modifications.

## How to run: PowerShell 7 as Administrator

Fetch both script files from the isolated GitHub branch without checking it out, so the current working tree is untouched:

~~~~powershell
Set-Location "C:\Users\TRUNG\mcp-gateway"
git fetch --no-tags origin p2/ipv6-443-temporary-ingress-probe-20261115

$testDir = Join-Path $env:TEMP "mcp-p2-443-run"
New-Item -ItemType Directory -Force -Path $testDir | Out-Null

git show "FETCH_HEAD:scripts/p2-ipv6-443-temporary-probe.ps1" |
    Set-Content -Encoding utf8 -Path (Join-Path $testDir "p2-ipv6-443-temporary-probe.ps1")
git show "FETCH_HEAD:scripts/p2-ipv6-443-cleanup-watchdog.ps1" |
    Set-Content -Encoding utf8 -Path (Join-Path $testDir "p2-ipv6-443-cleanup-watchdog.ps1")

& (Join-Path $testDir "p2-ipv6-443-temporary-probe.ps1") -Hostname "your-hostname.dynv6.net" -DurationSeconds 180
~~~~

Preflight checks: Wi-Fi Private with IPv6 Internet, effective firewall default inbound Block, a single preferred Link-origin IPv6, matching dynv6 public AAAA, and NO pre-existing TCP443 listener. Script also requires working Caddy and PowerShell 7. If checks fail, no firewall allow is created.

Expected activation output:

~~~~text
TEMP_IPV6_443_LISTENER=BOUND
FIREWALL_TEST_RULE=SCOPED_ACTIVE
MCP_BACKEND_EXPOSED=NO
TLS_CERTIFICATE=INTERNAL_TEST_ONLY
WINDOW_SECONDS=180
CLEANUP=Automatic at end; independent expiry failsafe armed
~~~~

During the 180-second window, turn OFF Wi-Fi on a mobile phone, use an IPv6-capable cellular data connection, and open the exact URL:

https://your-hostname.dynv6.net/__mcp_p2_ipv6_ingress_probe

An untrusted certificate warning is EXPECTED because this is deliberately not a production certificate. If browser permits proceeding for this test ONLY, the desired page body is:

MCP_P2_IPV6_TCP443_REACHABLE

Do NOT install a Caddy root certificate or disable browser security settings globally. If the phone browser blocks the certificate permanently, report the precise message. A certificate warning indicates that some remote TLS interaction happened, but is not equal to a verified HTTP 200/static body. A timeout is inconclusive unless mobile data really supports IPv6 and the script was listening successfully.

Expected cleanup output after expiry:

~~~~text
TEST_WINDOW=EXPIRED
FIREWALL_TEST_RULE=REMOVED
TEMP_CADDY=STOPPED
~~~~

Read-only post-check:

~~~~powershell
@(Get-NetTCPConnection -LocalPort 443 -State Listen -ErrorAction SilentlyContinue).Count
@(Get-NetFirewallRule -PolicyStore ActiveStore -DisplayName "MCP P2 TEMP IPv6 TCP 443 reachability probe" -ErrorAction SilentlyContinue).Count
~~~~

If the two values are zero and no other service uses port 443, cleanup succeeded.

## Emergency rule cleanup

If automatic cleanup reports a problem, run in elevated PowerShell:

~~~~powershell
Get-NetFirewallRule -PolicyStore ActiveStore -DisplayName "MCP P2 TEMP IPv6 TCP 443 reachability probe" -ErrorAction SilentlyContinue |
    Remove-NetFirewallRule -ErrorAction SilentlyContinue
~~~~

Do NOT run Stop-Process -Name caddy; that could kill the existing internal HTTPS Caddy. The independent watchdog stops only the process it launched after verifying the specific executable and unique test configuration path.

## Interpretation

- Exact page body from a phone using IPv6 cellular data: ingress to laptop TCP443 passes at that moment. Not a public-trust cert, not a ChatGPT MCP tool-call proof.
- Certificate warning only: probable remote TLS reachability but HTTP body not confirmed.
- Timeout: mobile IPv6, current DNS AAAA, host listener and router/ISP firewall all remain possible causes. Do not blame the router without further evidence.
- Preflight/launch error: local setup not complete; report script error and ensure the temporary firewall rule was removed.

Only after this independent ingress gate passes should we work on publicly trusted Caddy TLS and then a real ChatGPT Chat MCP tool invocation. The current Caddy does not have the optional dynv6 DNS-01 community plugin, and the previously exposed dynv6 token must be rotated privately before use.
