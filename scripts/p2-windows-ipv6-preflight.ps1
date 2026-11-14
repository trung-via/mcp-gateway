#Requires -Version 7.0
<#
.SYNOPSIS
  Read-only network preflight and Caddyfile previews for a direct IPv6 MCP proof.
.DESCRIPTION
  Does NOT start listeners, issue certificates, access routers, change firewall
  rules, update DNS, or read dynv6 credentials. Home IPv6 stays on this laptop.
  Generates only two inert local Caddyfile previews, never activates them.
.EXAMPLE
  .\scripts\p2-windows-ipv6-preflight.ps1 -Hostname "your-host.dynv6.net"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^(?=.{1,253}$)(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z]{2,63}$')]
    [string] $Hostname,

    [string] $InterfaceAlias = "Wi-Fi",

    [string] $OutputDirectory = (Join-Path $HOME ".mcp-gateway\previews")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Hostname = $Hostname.ToLowerInvariant()
$profile = Get-NetConnectionProfile -InterfaceAlias $InterfaceAlias
if ($profile.NetworkCategory -ne 'Private') {
    throw "STOP: Expected a Private network profile on selected interface."
}
if ($profile.IPv6Connectivity -ne 'Internet') {
    throw "STOP: IPv6 Internet connectivity not reported on selected interface."
}

$firewall = Get-NetFirewallProfile -PolicyStore ActiveStore -Name Private
if (-not $firewall.Enabled -or $firewall.DefaultInboundAction -ne 'Block') {
    throw "STOP: Effective Private firewall profile is not Enabled + Block inbound."
}

$localCandidates = @(
    Get-NetIPAddress -InterfaceAlias $InterfaceAlias -AddressFamily IPv6 |
        Where-Object {
            $_.AddressState -eq "Preferred" -and
            $_.SuffixOrigin -eq "Link" -and
            $_.IPAddress -match '^[23][0-9a-fA-F]{0,3}:'
        }
)
if ($localCandidates.Count -ne 1) {
    throw "STOP: Expected exactly one preferred globally scoped IPv6 (SuffixOrigin=Link)."
}

$dnsCandidates = @(
    Resolve-DnsName -Name $Hostname -Type AAAA -Server '1.1.1.1' -DnsOnly |
        Where-Object { $_.Type -eq 'AAAA' } |
        Select-Object -ExpandProperty IPAddress
)
$ip = $localCandidates[0].IPAddress
if ($ip -notin $dnsCandidates) {
    throw "STOP: Public AAAA does not match the current preferred Link-origin laptop IPv6."
}

$listeners443 = @(
    Get-NetTCPConnection -LocalPort 443 -State Listen -ErrorAction SilentlyContinue
)
if ($listeners443.Count -gt 0) {
    throw "STOP: TCP 443 is already in use; will not prepare a conflicting public listener."
}

$backend = @(
    Get-NetTCPConnection -LocalPort 18080 -State Listen -ErrorAction SilentlyContinue
)
if ($backend.Count -ne 1 -or $backend[0].LocalAddress -ne '127.0.0.1') {
    throw "STOP: MCP backend should be listening only on 127.0.0.1:18080."
}

$caddy = Get-Command caddy -CommandType Application -ErrorAction SilentlyContinue
if (-not $caddy) {
    throw "STOP: Caddy command not found. Install/review it separately; no installation attempted."
}

# No secrets, no browser/CDP access, no firewall or listener changes.
$modules = @(& $caddy.Source list-modules 2>$null)
$hasDynv6 = [bool](@($modules | Where-Object { $_ -match '(^|\s)dns\.providers\.dynv6(\s|$)' }).Count -gt 0)

[System.IO.Directory]::CreateDirectory($OutputDirectory) | Out-Null
$alpnPath = Join-Path $OutputDirectory 'Caddyfile.ipv6-443.preview'
$dnsPath = Join-Path $OutputDirectory 'Caddyfile.dns01-loopback.preview'

# Bind one current IPv6 only; not ::, 0.0.0.0 or 127.0.0.1.
$ipv6Bind = "tcp6/[$ip]"
$alpnPreview = @"
{
    admin off
    auto_https disable_redirects
    skip_install_trust
}

https://$Hostname {
    bind $ipv6Bind
    tls {
        issuer acme {
            disable_http_challenge
        }
    }
    reverse_proxy 127.0.0.1:18080
}
"@

# Token remains an environment variable reference, never written or read.
# Requires a separately audited Caddy build with the community dynv6 module.
$dnsPreview = @"
{
    admin off
    auto_https disable_redirects
    skip_install_trust
}

https://$Hostname {
    bind 127.0.0.1
    tls {
        dns dynv6 {env.DYNV6_API_TOKEN}
    }
    reverse_proxy 127.0.0.1:18080
}
"@

$utf8 = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllText($alpnPath, $alpnPreview, $utf8)
[System.IO.File]::WriteAllText($dnsPath, $dnsPreview, $utf8)

# Syntax adaptation is read-only; no configuration activation.
& $caddy.Source adapt --config $alpnPath --adapter caddyfile *> $null
if ($LASTEXITCODE -ne 0) {
    throw "STOP: Caddy could not adapt the TCP 443 preview; no server started."
}

Write-Output 'WIFI_PROFILE=Private'
Write-Output 'IPV6_INTERNET=PASS'
Write-Output 'EFFECTIVE_INBOUND_DEFAULT=Block'
Write-Output 'DNS_TO_LAPTOP=MATCH'
Write-Output 'PORT_443=NOT_LISTENING'
Write-Output 'MCP_BACKEND_18080=LOOPBACK_ONLY'
Write-Output 'CADDY_ALPN_PREVIEW_ADAPT=PASS'
Write-Output "CADDY_DYNV6_DNS_MODULE=$(if ($hasDynv6) { 'PRESENT' } else { 'ABSENT' })"
Write-Output "PUBLIC_PREVIEW_PATH=$alpnPath"
Write-Output "DNS01_PREVIEW_PATH=$dnsPath"
Write-Output 'NO_MUTATION=No listeners, firewall rules, DNS records, router settings or certificates changed'
Write-Output 'SECURITY_STOP=Do not run either preview without separate scoped approval'
