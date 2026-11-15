# P2 Public TLS-ALPN-01 static-only certificate gate

Status: SOURCE ONLY / PUBLIC CERTIFICATE NOT ISSUED. GATEWAY-P0-004, Issue #2. This is a separate security approval gate after demonstrated direct IPv6 TCP443 ingress PASS.

## Live evidence establishing prerequisites (2026-11-15)

- Operator ran PR #7's isolated 180-second test Caddy on global IPv6 TCP443. Independent IPv6-capable TCPData returned REMOTE_IPV6_TCPDATA_STATUS=OPEN after a positive-control PASS. LOCAL_IPV6_HTTPS_STATIC=PASS. Scoped inbound Windows rule ACTIVE then REMOVED; Caddy STOPPED. No MCP exposure.
- Prior mobile 5G test was invalid because test-ipv6.com found NO IPv6 (0/10); it is not evidence of a router block.
- Laptop MCP JSON-RPC initialize, initialized notification, gateway_health over private/loopback HTTPS already PASS. This does NOT prove the public trust chain or ChatGPT origin.
- Existing Caddy command lacks optional dynv6 DNS module, but stock Caddy supports ACME TLS-ALPN-01 (public inbound 443 now has a positive test). No dynv6 update token required.

## Historical: first ACME attempt fix (bracketed bind now SUPERSEDED) — 2026-11-15

**USER_LIVE Windows run of PR #8 attempt #1**: Caddy selected global IPv6 TCP443 listener bound; Windows temporary Private ActiveStore allow rule ACTIVE; 300-second window expired and both Caddy and the rule cleaned up. `PUBLIC_TLS_TRUST=NOT_VERIFIED_WITHIN_WINDOW`. Independent follow-up confirmed **`PORT443_LISTENERS=0` and `ACME_TEST_RULES=0`**.

**Root cause CONFIRMED from sanitized Caddy stderr**: ACME account registration succeeded; `http.acme_client` attempted TLS-ALPN-01 but `tls.obtain` failed when the embedded challenge solver tried creating a malformed address containing `tcp6/[<IPv6>]` as its **bind-host component**. Reported `missing port in address` occurred before any successful ACME validation. A second staging CA attempt failed the same way. This is a **local listener-address construction failure**, not evidence of router ingress block, insufficient IPv6 mobile access, CA rejection, CAA, invalid password, or dynv6 API module error. The initial missing `default.json` account file was an ordinary new-account state and subsequently `new ACME account registered`.

**Historical intermediate repair (SUPERSEDED by second-attempt diagnosis above)**: replaced `bind tcp6/[$ipv6]` with **bracketed** `bind [$ipv6]`, keeping the site address `https://<registered-hostname>` to supply TCP443. Caddy [bind docs](https://caddyserver.com/docs/caddyfile/directives/bind) specify a host/interface argument with port from the site address; the challenge solver must not receive a `tcp6/` network prefix as its host. Add PowerShell CI regression that rejects this prefix and a **no-CA `-CheckBindOnly`** preflight which reads the adapted Caddy JSON and rejects any listener other than exactly `[selected-ipv6]:443` (or its `tcp/` spelling).

**Next safe test** (user laptop, elevated PowerShell 7): fetch the *newly reviewed PR #8 commit*, copy the script+watchdog, invoke:

```powershell
& (Join-Path $testDir 'p2-public-tls443-static-probe.ps1') -Hostname '<registered-hostname>' -CheckBindOnly
```

Expected in the CURRENT unbracketed revision: `CADDY_HTTP_IPV6_LISTENER=PASS`, `CADDY_ACME_BIND_HOST_RAW_IPV6=PASS`, `CADDY_BIND_IPV6_HOST_ONLY=PASS`, `PUBLIC_ACME_CA_CONTACT=NO`, `NO_FIREWALL_CHANGE=YES`; **no Caddy listener is started and no public CA is contacted**, irrespective of previous certificate status. This is a read-only network preflight plus an inert local temporary Caddyfile write/parse. `-ApprovePublicACME` is NOT needed for `-CheckBindOnly`.

**STOP**: do not immediately re-run ACME; review the new local preflight and latest CI result first. A new CA issuance attempt is a **separate retry** with potential rate limiting/CT effects and must be scoped explicitly; earlier approval of a single time-boxed attempt does not silently become authorization for unlimited attempts.

## Second ACME attempt: double-bracket bind-host root cause and repaired preflight — 2026-11-15

**USER_LIVE operator report** after fixed `bind [$ipv6]` script in PR #8: `CADDY_BIND_IPV6_HOST_ONLY=PASS`, Caddy 443 BOUND, firewall ACTIVE, no public MCP, but `PUBLIC_TLS_TRUST=NOT_VERIFIED_WITHIN_WINDOW`. Read-only Caddy stderr showed `tls.obtain` `presenting with embedded solver` failed `missing port in address` with malformed address starting **`[[IPv6]]`**. Multiple production/staging challenge attempts hit the *same local malformed bind-host*. The script did remove firewall and stop the isolated Caddy, and owner independent postcheck confirmed `PORT443_LISTENERS=0`, `ACME_TEST_RULES=0`. Neither CA validation nor a trusted certificate succeeded.

**Upstream evidence directly matches this specific bug:** [caddyserver/caddy#7399](https://github.com/caddyserver/caddy/issues/7399) comment dated 2025-12-27 reports ACME IPv6 `bind` addresses **must not include square brackets**, because Caddy's ACME address construction adds them again, causing missing-port errors. Official [Caddy bind docs](https://caddyserver.com/docs/caddyfile/directives/bind) show bracketed IPv6 for normal listeners, so this represents a **runtime ACME exception/bug** in the observed binary, not generic Caddyfile syntax error. Certmagic TLS-ALPN-01 uses `challenges.bind_host` as a raw host input; adapted HTTP `listen: ["[IPv6]:443"]` alone is **not an adequate preflight**.

**Current corrected PR #8 source (NOT YET tested on laptop):**
- Use `bind $ipv6` **without brackets or `tcp6/` prefix** in the Caddyfile. Preserve exact Wi-Fi global IPv6 and port443; Windows temporary firewall rule remains restricted to exact IPv6/Caddy binary.
- Strengthen `-CheckBindOnly`: inspect BOTH adapted HTTP server listener for exact `[IPv6]:443` and ACME `apps.tls.automation.policies[*].issuers[*].challenges.bind_host` which **must equal raw unbracketed selected IPv6**; otherwise hard STOP before any Caddy start, external CA contact or firewall mutation.
- Add regression CI: forbid bracketed/network-prefixed bind inputs, require raw `bind $ipv6` and separate `CADDY_ACME_BIND_HOST_RAW_IPV6=PASS` guard before exiting no-CA preview.
- **NO THIRD PUBLIC CA ATTEMPT** is authorized. First run `-CheckBindOnly` with a freshly pinned, reviewed PR head (no `-ApprovePublicACME`); the preview exits before any listener/firewall/CA effect. If it does not PASS, keep stop and audit adapted JSON locally (redact IP and hostname). If it does PASS, it remains **not** full ACME runtime proof; obtain new limited approval before any CA retry, consider staging-first to minimize production CA limits.

Ignore harmless Caddyfile formatting warning or `admin endpoint disabled` warning; they did not cause `listen tcp ... missing port`. **No router login, no Tunnel/Render/Work, no dynv6 module/token, no port80, no MCP/CDP exposure.**

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
