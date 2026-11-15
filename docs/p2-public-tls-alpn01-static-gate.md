# P2 Public TLS-ALPN-01 static-only certificate gate

Status: SOURCE ONLY / PUBLIC CERTIFICATE NOT ISSUED. GATEWAY-P0-004, Issue #2. This is a separate security approval gate after demonstrated direct IPv6 TCP443 ingress PASS.

## Live evidence establishing prerequisites (2026-11-15)

- Operator ran PR #7's isolated 180-second test Caddy on global IPv6 TCP443. Independent IPv6-capable TCPData returned REMOTE_IPV6_TCPDATA_STATUS=OPEN after a positive-control PASS. LOCAL_IPV6_HTTPS_STATIC=PASS. Scoped inbound Windows rule ACTIVE then REMOVED; Caddy STOPPED. No MCP exposure.
- Prior mobile 5G test was invalid because test-ipv6.com found NO IPv6 (0/10); it is not evidence of a router block.
- Laptop MCP JSON-RPC initialize, initialized notification, gateway_health over private/loopback HTTPS already PASS. This does NOT prove the public trust chain or ChatGPT origin.
- Existing Caddy command lacks optional dynv6 DNS module, but stock Caddy supports ACME TLS-ALPN-01 (public inbound 443 now has a positive test). No dynv6 update token required.

## Scope and risk consent

Only after explicit operator approval for PUBLIC CA ISSUANCE, invoke scripts/p2-public-tls443-static-probe.ps1 with -ApprovePublicACME in an elevated PowerShell 7 session on the Windows laptop. The switch is fail-closed if omitted.

**This contacts a public certificate authority. A certificate can persist in local Caddy storage; its hostname may appear in public Certificate Transparency (CT) logs.** This is not a no-mutation dry run. It may perform ACME account registration/challenges and certificate issuance. Do not execute merely because the script/PR exists. CA rate limits apply; avoid repeated probes.

The test must serve only a fixed static body at /__mcp_p2_public_tls_probe, with 404 elsewhere. No reverse_proxy to MCP, Windows, GitHub, CDP 9444 or any private adapter. The Caddy instance is NEW and separate from the existing Caddy localhost 8443; the MCP backend remains on localhost 18080.

TLS configuration: native Caddy ACME issuer with disable_http_challenge. TLS-ALPN-01 is enabled on 443. No port 80, no DNS challenge, no DNS provider plugin, no credential rotation required for this ACME test (but previously exposed dynv6 token should still be privately rotated if ever used).

Network and rollback: bind only one preferred global Wi-Fi IPv6 address on TCP443, with a unique Windows Firewall Private ActiveStore allow rule limited to exactly that address, Caddy executable and port. No persistent firewall rule. Default duration 300 seconds, limit 180..480. Main process try/finally cleanup + detached watchdog at duration+30s. No router administration available or requested.

## Review-only commands; not an authorization to execute

Obtain both source files from isolated PR branch into local temp without checking out a branch. Run only after operator explicitly consents to the public-CA and CT-log implications:

```powershell
Set-Location "$HOME\mcp-gateway"
git fetch --no-tags origin p2/trusted-tls-alpn-01-static-probe-20261115
$testDir = Join-Path $env:TEMP 'mcp-p2-public-tls-trial'
New-Item -ItemType Directory -Force $testDir | Out-Null
$files = @('p2-public-tls443-static-probe.ps1','p2-tls443-cleanup-watchdog.ps1')
foreach ($file in $files) {
    git show "FETCH_HEAD:scripts/$file" | Set-Content -Path (Join-Path $testDir $file) -Encoding utf8
}
# EXECUTE ONLY AFTER SEPARATE APPROVAL:
# & (Join-Path $testDir 'p2-public-tls443-static-probe.ps1') -Hostname '<your-registered-hostname>' -DurationSeconds 300 -ApprovePublicACME
```

The operator can inspect Caddyfile and script code before approval. There is no reason to install the optional community dynv6 DNS module for the primary TLS-ALPN-01 path.

## Acceptance evidence and failure interpretation

- PUBLIC_TLS_TRUST=PASS_VALIDATED_WITHOUT_INSECURE: localhost Caddy served the exact known static body over the chosen *global IPv6*, and curl validated public-CA TLS chain and hostname **without -k or --insecure**. This proves public trust from the laptop and successful ACME issuance, NOT independently validated public HTTPS from OpenAI or remote MCP calls.
- PUBLIC_TLS_TRUST=NOT_VERIFIED_WITHIN_WINDOW: issuer may not have completed, ACME challenge may be blocked, DNS/CAA/certificate issuance could fail, or local curl might fail. Inspect Caddy logs *locally* with secrets and personal addresses redacted; do not guess root cause from this alone.
- Any startup or firewall error: fail closed, leave existing localhost Caddy and MCP untouched.
- After test: FIREWALL_TEST_RULE=REMOVED and TEMP_CADDY=STOPPED, and check no scoped test rule/no TCP443 listener remains. This test does NOT install certificate into the Windows trust store.
- Public cert/account/key may remain in Caddy's standard persistent storage. Keep keys private, never commit them to public GitHub. Periodic renewal requires a future continuously available Caddy service and renewed approval.

## Next gate

Only after public trusted certificate PASS and cleanup: review opening a *separate*, limited public MCP reverse proxy (only gateway_health, no other adapters) and independently call MCP JSON-RPC from an outside IPv6-capable network. Then test normal ChatGPT Chat custom server URL via https://<hostname>/mcp. OpenAI source docs do not independently prove that ChatGPT supports IPv6-only endpoints, so this needs an actual tool invocation witness.

## Authoritative documentation

- https://caddyserver.com/docs/automatic-https (TLS-ALPN-01 on TCP443)
- https://caddyserver.com/docs/caddyfile/directives/tls (issuer acme and disable_http_challenge)
- https://developers.openai.com/plugins/deploy/connect-chatgpt (public HTTPS /mcp and tool invocation)
- https://letsencrypt.org/docs/rate-limits/ (CA rate limits)
