# GATEWAY-P0-004: temporary direct IPv6 TCP 443 HTTPS probe

Status: SOURCE ONLY. The owner approved a short, bounded external IPv6/TCP443 test. This script has NOT yet been executed on the Windows host.

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
