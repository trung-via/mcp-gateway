# P2 Windows direct IPv6 — no-router-login HTTPS preflight

**Status:** PREPARATION / not deployed or approved for Internet exposure. This document belongs to Issue #2 (GATEWAY-P0-004). It does **not** claim external IPv6 ingress or a ChatGPT tool-call witness.

## Immutable operator constraints and current observations

- No administrator login to the home router. **Never request router settings, router credentials, or port forwarding again.** Router IPv6 ingress remains UNKNOWN.
- Primary path: normal ChatGPT Chat custom MCP Server URL -> HTTPS over direct IPv6 -> laptop Caddy -> read-only `src.gateway.public_server` at `127.0.0.1:18080`.
- No Tunnel, Render, Work, 9444 CDP exposure, broad Windows host permissions, or access to GitHub/other private project adapters. Public service exposes only `gateway_health` static data in this proof.
- User-observed PASS: public dynv6 AAAA matches preferred Wi-Fi global IPv6 with `SuffixOrigin=Link`; IPv6 outbound Internet; Wi-Fi network category Private; ActiveStore inbound default Block across profiles; Caddy loopback `127.0.0.1:8443` to MCP loopback `127.0.0.1:18080`; MCP initialize HTTP 200 / ready 202 / `gateway_health` HTTP 200 through local HTTPS. **This local test used an internal CA with curl `-k`.**
- Unverified: public TLS trust, actual off-LAN IPv6 ingress, NAT/router IPv6 filtering, ChatGPT remote IPv6-only connectivity, plugin registration, and native ChatGPT Chat MCP call.
- A dynv6 credential appeared in a prior screenshot. Rotation/revocation has **not** been confirmed. Do not place new credentials, personal IPv6, user hostname, certificate keys or outputs containing them into this PUBLIC repo.

## Laptop DNS provider module check — 2026-11-15

Human ran `caddy list-modules | Select-String "dns.providers.dynv6"` on Windows PowerShell and observed **no matching output**. Interpret as **CADDY_DYNV6_MODULE_ABSENT / USER_OBSERVED** in the currently selected Caddy executable (not evidence of a broken gateway).

**Decision for now:** Do **not** replace the working Caddy executable, install an unaudited custom binary, handle any dynv6 secrets, or attempt automatic DNS-01 issuance. Continue with the existing stock Caddy and first finish dry-run syntax/network checks; a later independently approved IPv6 443 probe will determine whether the ingress path can work at all. DNS-01 is an optional later step if ingress is viable and it is worth the third-party module+token overhead. A publicly trusted DNS-01 certificate alone cannot bypass upstream IPv6 firewall filtering.

If custom DNS-01 becomes required, review the Caddy community module `github.com/caddy-dns/dynv6`, source dependencies, build/upgrade strategy, and freshly rotated token. Do not remove or replace the tested `127.0.0.1:8443` internal TLS setup during dry-run. No router login requirement and no external listener/firewall changes.

## Two independent gates

**TLS gate** — A publicly trusted HTTPS certificate can be obtained either through:
1. **DNS-01 (preferred research path with no router access):** Use a Caddy build that includes the community `dns.providers.dynv6` module, a **freshly rotated, privately stored** dynv6 API token, and a DNS challenge. DNS-01 does not require an inbound listener. The stock Caddy binary may not contain this module. The third-party module must be reviewed before downloading/building; `caddy list-modules` is a safe local capability check. See [Caddy automatic HTTPS](https://caddyserver.com/docs/automatic-https), [dynv6 Caddy module](https://github.com/caddy-dns/dynv6). **Do not start DNS-01 or provide tokens to chat/GitHub as part of this dry-run.**
2. **TLS-ALPN-01 on public TCP 443:** Stock Caddy supports it, but issuance requires the public CA to reach TCP 443. Keep HTTP-01 disabled so no TCP 80 listener is required. If the upstream router blocks unsolicited IPv6, this cannot succeed without assistance from ISP/router operator.

**Ingress gate** — Separate from certificate issuance. An off-LAN IPv6-capable client must independently connect to the actual public FQDN/TCP 443. Router upstream filtering cannot be bypassed from Windows; if it blocks, stop and document the confirmed or probable boundary. Do not use Wi-Fi hairpin/localhost tests as remote proof. No Tunnel/Render/Work fallback unless the user explicitly changes the architecture.

## Safe preparation (NO listener / firewall / router changes)

In a PowerShell 7 terminal on the laptop, with the repo checked out and the existing localhost backend running:

```powershell
# Use the real hostname **locally**; never paste its IPv6 or private tokens to GitHub.
.\scripts\p2-windows-ipv6-preflight.ps1 -Hostname "your-hostname.dynv6.net"
```

The script checks preferred `SuffixOrigin=Link` global IPv6 against public AAAA, Wi-Fi profile, effective Private firewall, absence of a TCP 443 listener, the loopback-only MCP backend, and the Caddy executable. It creates **two preview Caddyfiles in the user's home directory only** (see printed paths):
- `Caddyfile.ipv6-443.preview`: **NOT ACTIVATE**. Binds specifically to the current preferred global IPv6 using `tcp6/[...]`; explicitly disables HTTP-01, forwards only to `127.0.0.1:18080`, disables Admin API/HTTP redirects. Requires scoped approval and ingress before certificate issuance. If the ISP renumbers IPv6, regenerate; update dynv6 AAAA separately with a private credential after rotation.
- `Caddyfile.dns01-loopback.preview`: **NOT ACTIVATE**. Binds only to `127.0.0.1:443`, uses dynv6 DNS-01 provider for a publicly trusted certificate, but requires a separately audited custom Caddy build and freshly rotated token. Cert issuance on loopback does **not** prove public ingress.

The script does **not** start Caddy, install plugins, build code, request certificates, change firewall, update DNS, read private tokens, or modify the router. The `Caddyfile` previews are not operative until manually activated after a separate scoped authorization and safety review.

## Production activation is a future separate approval

Only after code review, token rotation, and explicit owner permission to make a time-bounded security-sensitive change:

1. Backup current local `Caddyfile.local`, preserve current internal-CA test Caddy if needed, and ensure backend exposes only `gateway_health`.
2. Select public CA path. If DNS-01, audit provider and binary module, use rotated token through protected process env, verify certificate with a **normal** TLS client (**no `-k`**). If TLS-ALPN-01, temporarily bind Caddy only to the selected global IPv6/TCP 443 and authorize a **narrow** Windows Private inbound TCP 443 rule (prefer program-specific and exact LocalAddress if supported), not other ports.
3. Obtain **independent** off-LAN IPv6 evidence. Check TCP 443 separately from HTTPS/MCP protocol, record tool-call proof or failure boundary, not raw residential IPv6 or secrets in public docs.
4. If router drops inbound, remove only the scoped rule and stop only the new public Caddy instance. Do **not** disable Windows Firewall, use DMZ/UPnP, or launch a broad listener; seek ISP/router-owner assistance or separately approve an architecture change.
5. Only after public certificate **trusted without `-k`** and independent external MCP `gateway_health` PASS: attempt actual regular ChatGPT MCP Server URL registration and tool invocation. Issue #2 stays OPEN until this witness.

## Provider and implementation references

- [Caddy interface binding](https://caddyserver.com/docs/caddyfile/directives/bind)
- [Caddy network-address conventions / tcp6](https://caddyserver.com/docs/conventions)
- [Caddy automatic HTTPS / ACME challenges](https://caddyserver.com/docs/automatic-https)
- [Caddy TLS ACME configuration](https://caddyserver.com/docs/caddyfile/directives/tls)
- [Community dynv6 DNS-01 module](https://github.com/caddy-dns/dynv6)
- [Windows firewall resultant policy](https://learn.microsoft.com/en-us/powershell/module/netsecurity/get-netfirewallprofile)
