#Requires -Version 7.0
#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Opt-in, time-bounded public-CA TLS-ALPN-01 static certificate proof.
.DESCRIPTION
  Starts a NEW isolated Caddy instance serving only a static HTTP response
  while obtaining a public ACME TLS-ALPN-01 certificate on TCP443.
  No MCP proxy. A narrowly scoped Windows
  Private ActiveStore inbound TCP 443 rule is created temporarily.
  The original Caddy localhost 8443 and MCP localhost 18080 stay unchanged.
  A separate expiry watchdog removes the rule and kills only this test Caddy
  process even if the invoking PowerShell window is unexpectedly closed.
  No router, DNS, trust-store, or MCP changes; may persist ACME cert/key data.
.EXAMPLE
  .\p2-public-tls443-static-probe.ps1 -Hostname "your-host.dynv6.net" -ApprovePublicACME
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^(?=.{1,253}$)(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z]{2,63}$')]
    [string] $Hostname,

    [ValidateRange(180,480)]
    [int] $DurationSeconds = 300,

    [switch] $ApprovePublicACME,

    # Safe preview: adapt Caddyfile, verify exact listener and exit BEFORE any CA call.
    [switch] $CheckBindOnly,

    [string] $InterfaceAlias = "Wi-Fi"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$Hostname = $Hostname.ToLowerInvariant()
$probePath = '/__mcp_p2_public_tls_probe'
$probeBody = 'MCP_P2_PUBLIC_CERT_TRUSTED'
$process = $null
$firewallCreated = $false
$ruleName = "MCP-P2-IPv6-443-Temp-" + [guid]::NewGuid().ToString('N')

$cleanupPath = Join-Path $PSScriptRoot 'p2-tls443-cleanup-watchdog.ps1'
if (-not $CheckBindOnly -and -not $ApprovePublicACME) { throw 'STOP: public CA issuance needs explicit -ApprovePublicACME; no effect.' }
if (-not (Test-Path -LiteralPath $cleanupPath -PathType Leaf)) {
    throw 'STOP: companion expiry-watchdog script is missing; nothing opened.'
}

$network = Get-NetConnectionProfile -InterfaceAlias $InterfaceAlias
if ($network.NetworkCategory -ne 'Private' -or $network.IPv6Connectivity -ne 'Internet') {
    throw 'STOP: selected Wi-Fi must be Private with IPv6 Internet.'
}
$fw = Get-NetFirewallProfile -PolicyStore ActiveStore -Name Private
if (-not $fw.Enabled -or $fw.DefaultInboundAction -ne 'Block') {
    throw 'STOP: effective Private firewall must be enabled with default inbound Block.'
}

$ipv6Candidates = @(
    Get-NetIPAddress -InterfaceAlias $InterfaceAlias -AddressFamily IPv6 |
        Where-Object {
            $_.AddressState -eq 'Preferred' -and
            $_.SuffixOrigin -eq 'Link' -and
            $_.IPAddress -match '^[23][0-9a-fA-F]{0,3}:'
        }
)
if ($ipv6Candidates.Count -ne 1) {
    throw 'STOP: need exactly one preferred global Link-origin Wi-Fi IPv6.'
}
$ipv6 = $ipv6Candidates[0].IPAddress
$aaaa = @(
    Resolve-DnsName $Hostname -Type AAAA -Server '1.1.1.1' -DnsOnly |
        Where-Object { $_.Type -eq 'AAAA' } |
        Select-Object -ExpandProperty IPAddress
)
if ($ipv6 -notin $aaaa) {
    throw 'STOP: public AAAA does not match selected global Wi-Fi IPv6.'
}
if (@(Get-NetTCPConnection -State Listen -LocalPort 443 -ErrorAction SilentlyContinue).Count -gt 0) {
    throw 'STOP: TCP 443 already has a listener. Do not interfere with it.'
}

$caddy = Get-Command caddy -CommandType Application -ErrorAction Stop | Select-Object -First 1
$caddyPath = $caddy.Source
$pwsh = Get-Command pwsh -CommandType Application -ErrorAction Stop | Select-Object -First 1
$dir = Join-Path $env:TEMP ("mcp-p2-443-" + [guid]::NewGuid().ToString('N'))
[System.IO.Directory]::CreateDirectory($dir) | Out-Null
$configPath = Join-Path $dir 'Caddyfile.test'
$stdout = Join-Path $dir 'caddy-stdout.log'
$stderr = Join-Path $dir 'caddy-stderr.log'

# No reverse_proxy or /mcp route: this listener contains NO MCP/Windows/CDP access.
# Real public ACME CA certificate IS requested. No trust roots installed.
# TLS-ALPN-01 uses port 443; HTTP-01 is explicitly disabled.
$config = @"
{
    admin off
    auto_https disable_redirects
    skip_install_trust
}

https://$Hostname {
    # Critical ACME runtime rule: use RAW IPv6 host text (no [] or tcp6/).
    # Caddy's TLS-ALPN solver adds IPv6 brackets when building host:port.
    # bind [$ipv6] passed HTTP adaptation but caused double brackets in ACME.
    bind $ipv6
    tls {
        issuer acme {
            disable_http_challenge
        }
    }
    respond $probePath "$probeBody" 200
    respond "Not Found" 404
}
"@
[System.IO.File]::WriteAllText($configPath, $config, [System.Text.UTF8Encoding]::new($false))

try {
    # Caddyfile adaptation is read-only. A syntactically valid config is not
    # proof that ACME challenges will succeed; enforce exact bind shape here.
    $adaptLines = @(& $caddyPath adapt --config $configPath --adapter caddyfile 2>$null)
    if ($LASTEXITCODE -ne 0 -or $adaptLines.Count -eq 0) { throw 'STOP: Caddy config adaptation failed.' }
    $adapted = ($adaptLines -join "`n") | ConvertFrom-Json -ErrorAction Stop
    $listeners = @(
        $adapted.apps.http.servers.PSObject.Properties |
            ForEach-Object { $_.Value.listen } | Where-Object { $_ }
    )
    $expected = "[$ipv6]:443"
    if ($listeners.Count -ne 1 -or [string]$listeners[0] -notin @($expected, "tcp/$expected")) {
        throw 'STOP: Caddy adapted listener is not exactly the selected IPv6 TCP443 host; no effects.'
    }
    # Validate the *ACME challenge bind host*, not just the HTTP listener.
    # Earlier HTTP listener checks passed while the embedded TLS-ALPN
    # solver failed at runtime with [[IPv6]] / missing port in address.
    # An absent or bracketed bind_host fails closed before any CA effects.
    $acmeBindHosts = @(
        foreach ($policy in @($adapted.apps.tls.automation.policies)) {
            foreach ($field in @('issuers', 'issuer')) {
                $issuerProperty = $policy.PSObject.Properties[$field]
                if ($null -eq $issuerProperty) { continue }
                foreach ($issuer in @($issuerProperty.Value)) {
                    if ($null -eq $issuer) { continue }
                    $moduleProperty = $issuer.PSObject.Properties['module']
                    if ($null -eq $moduleProperty -or $moduleProperty.Value -ne 'acme') { continue }
                    $challenges = $issuer.PSObject.Properties['challenges']
                    if ($null -eq $challenges -or $null -eq $challenges.Value) { continue }
                    $bindHost = $challenges.Value.PSObject.Properties['bind_host']
                    if ($null -ne $bindHost -and $null -ne $bindHost.Value) {
                        [string] $bindHost.Value
                    }
                }
            }
        }
    )
    if ($acmeBindHosts.Count -ne 1 -or $acmeBindHosts[0] -cne $ipv6) {
        throw 'STOP: ACME challenge bind_host is absent, bracketed or not the exact raw selected IPv6. No CA/firewall effects.'
    }
    Write-Output 'CADDY_HTTP_IPV6_LISTENER=PASS'
    Write-Output 'CADDY_ACME_BIND_HOST_RAW_IPV6=PASS'
    Write-Output 'CADDY_BIND_IPV6_HOST_ONLY=PASS'
    if ($CheckBindOnly) {
        Write-Output 'PUBLIC_ACME_CA_CONTACT=NO'
        Write-Output 'NO_FIREWALL_CHANGE=YES'
        return
    }
    if (@(Get-NetFirewallRule -PolicyStore ActiveStore -Name $ruleName -ErrorAction SilentlyContinue).Count -ne 0) {
        throw 'STOP: generated firewall rule name already exists.'
    }

    $process = Start-Process -FilePath $caddyPath -ArgumentList @('run', '--config', ('"{0}"' -f $configPath), '--adapter', 'caddyfile') -RedirectStandardOutput $stdout -RedirectStandardError $stderr -WindowStyle Hidden -PassThru

    $bound = $false
    for ($i = 0; $i -lt 20; $i++) {
        if ($process.HasExited) { break }
        $listen = @(
            Get-NetTCPConnection -State Listen -LocalPort 443 -ErrorAction SilentlyContinue |
                Where-Object { $_.LocalAddress -eq $ipv6 -and $_.OwningProcess -eq $process.Id }
        )
        if ($listen.Count -gt 0) { $bound = $true; break }
        Start-Sleep -Milliseconds 250
    }
    if (-not $bound) {
        throw 'STOP: isolated Caddy listener did not bind expected IPv6 TCP 443.'
    }

    # Independent expiry guard starts BEFORE the inbound firewall rule is created.
    $watchdogArgs = @(
        '-NoProfile', '-NonInteractive', '-File', ('"{0}"' -f $cleanupPath),
        '-RuleName', $ruleName,
        '-CaddyPid', [string]$process.Id,
        '-ExpectedExe', ('"{0}"' -f $caddyPath),
        '-ExpectedConfigPath', ('"{0}"' -f $configPath),
        '-DelaySeconds', [string]($DurationSeconds + 30)
    )
    $guard = Start-Process -FilePath $pwsh.Source -ArgumentList $watchdogArgs -WindowStyle Hidden -PassThru
    if ($guard.HasExited) {
        throw 'STOP: expiry watchdog failed to start; firewall remains unchanged.'
    }

    # ActiveStore avoids persistent rule across reboot. Exact IPv6 and Caddy only.
    $null = New-NetFirewallRule -PolicyStore ActiveStore -Name $ruleName -DisplayName 'MCP P2 TEMP ACME TLS443 static proof' -Enabled True -Direction Inbound -Action Allow -Profile Private -Program $caddyPath -Protocol TCP -LocalPort 443 -LocalAddress $ipv6 -RemoteAddress Any
    $firewallCreated = $true

    Write-Output 'TEMP_IPV6_443_LISTENER=BOUND'
    Write-Output 'FIREWALL_TEST_RULE=SCOPED_ACTIVE'
    Write-Output 'MCP_BACKEND_EXPOSED=NO'
    Write-Output 'TLS_CERTIFICATE=PUBLIC_ACME_PENDING'
    Write-Output "PROBE_URL=https://$Hostname$probePath"
    Write-Output "WINDOW_SECONDS=$DurationSeconds"
    Write-Output 'ACME_CHALLENGE=TLS_ALPN_01_TCP443_ONLY; port80 unused'
    Write-Output 'CERTIFICATE_STORAGE=CADDY_DEFAULT_PERSISTENT'
    Write-Output 'CLEANUP=Automatic at end; independent expiry failsafe armed'
    Write-Output 'EMERGENCY: Ctrl+C triggers cleanup; if needed, reboot resets ActiveStore rule'

    # Public trust check: no -k and no --insecure under any conditions.
    $curl = Get-Command curl.exe -CommandType Application -ErrorAction Stop | Select-Object -First 1
    $deadline = (Get-Date).AddSeconds($DurationSeconds)
    $trusted = $false
    while ((Get-Date) -lt $deadline) {
        if ($process.HasExited) { throw 'STOP: test Caddy process exited early.' }
        try {
            $body = ((& $curl.Source --noproxy '*' --ipv6 --fail --silent --connect-timeout 3 --max-time 8 --resolve ("{0}:443:[{1}]" -f $Hostname, $ipv6) ("https://{0}{1}" -f $Hostname, $probePath) 2>$null) -join "`n").Trim()
            $curlCode = $LASTEXITCODE
            if ($curlCode -eq 0 -and $body -ceq $probeBody) { $trusted = $true; break }
        } catch { }
        Start-Sleep -Seconds 6
    }
    if ($trusted) { Write-Output 'PUBLIC_TLS_TRUST=PASS_VALIDATED_WITHOUT_INSECURE' }
    else { Write-Output 'PUBLIC_TLS_TRUST=NOT_VERIFIED_WITHIN_WINDOW' }
    Write-Output 'TEST_WINDOW=EXPIRED_OR_VERIFIED'
}
finally {
    if ($firewallCreated) {
        try {
            Remove-NetFirewallRule -PolicyStore ActiveStore -Name $ruleName -ErrorAction Stop
            Write-Output 'FIREWALL_TEST_RULE=REMOVED'
        }
        catch {
            Write-Warning 'Test firewall rule removal failed; expiry watchdog will retry.'
        }
    }
    if ($null -ne $process) {
        try {
            if (-not $process.HasExited) {
                Stop-Process -Id $process.Id -Force -ErrorAction Stop
            }
            Write-Output 'TEMP_CADDY=STOPPED'
        }
        catch {
            Write-Warning 'Test Caddy stop failed; expiry watchdog will retry.'
        }
    }
    # Diagnostic logs stay local under TEMP; Caddy may persist ACME certificate/key material.
}
