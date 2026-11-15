#Requires -Version 7.0
#Requires -RunAsAdministrator
<#
.SYNOPSIS
  One-time, operator-approved direct IPv6 TCP 443 ingress probe on Windows.
.DESCRIPTION
  Starts a NEW isolated Caddy instance serving only one static HTTP response
  over an INTERNAL test-only TLS certificate. A narrowly scoped Windows
  Private ActiveStore inbound TCP 443 rule is created temporarily.
  The original Caddy localhost 8443 and MCP localhost 18080 stay unchanged.
  A separate expiry watchdog removes the rule and kills only this test Caddy
  process even if the invoking PowerShell window is unexpectedly closed.
  Does not alter a router, DNS, certificate trust stores or MCP permissions.
.EXAMPLE
  .\p2-ipv6-443-temporary-probe.ps1 -Hostname "your-host.dynv6.net"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^(?=.{1,253}$)(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z]{2,63}$')]
    [string] $Hostname,

    [ValidateRange(60,180)]
    [int] $DurationSeconds = 180,

    [string] $InterfaceAlias = "Wi-Fi",

    # Explicit opt-in; third-party checker sees the laptop IPv6 during the test.
    [switch] $UseTcpDataIPv6Probe,

    # Explicit second independent provider and multi-node probes.
    [switch] $UseMultiSourceIPv6Probe,

    # Consent to opening ingress and sharing public IPv6 with remote checkers.
    [switch] $ApproveTemporaryIngress,
    [switch] $ApproveRemoteProbeDisclosure
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$Hostname = $Hostname.ToLowerInvariant()
$probePath = '/__mcp_p2_ipv6_ingress_probe'
$probeBody = 'MCP_P2_IPV6_TCP443_REACHABLE'
$process = $null
$firewallCreated = $false
$ruleName = "MCP-P2-IPv6-443-Temp-" + [guid]::NewGuid().ToString('N')

$cleanupPath = Join-Path $PSScriptRoot 'p2-ipv6-443-cleanup-watchdog.ps1'
if (-not $ApproveTemporaryIngress) { throw 'STOP: explicit -ApproveTemporaryIngress required.' }
if ($UseMultiSourceIPv6Probe -and $UseTcpDataIPv6Probe) { throw 'STOP: choose one remote mode.' }
if ($UseMultiSourceIPv6Probe -and -not $ApproveRemoteProbeDisclosure) { throw 'STOP: explicit -ApproveRemoteProbeDisclosure required.' }
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

# Remote checker preflight: prove the provider can reach a known IPv6-only
# public HTTPS endpoint BEFORE opening any local test port. No host IP is sent
# to the provider during this positive control.
function Get-TcpDataPortStatus {
    param([Parameter(Mandatory)][string] $Target)
    $uri = "https://tcpdata.com/port?host=$([uri]::EscapeDataString($Target))&port=443"
    $response = Invoke-WebRequest -Uri $uri -Headers @{ Accept = 'application/json' } -TimeoutSec 12 -ErrorAction Stop
    if ($response.StatusCode -ne 200) { throw 'PROVIDER_BAD_HTTP_RESPONSE' }
    $json = $response.Content | ConvertFrom-Json -ErrorAction Stop
    $value = [string]$json.status
    if ($value -notin @('open','closed','timeout')) {
        throw 'PROVIDER_UNEXPECTED_RESPONSE_SCHEMA'
    }
    return $value
}
# Check-Host public API: https://check-host.net/about/api
# This is TCP reachability only. A successful result MUST include a parsed
# remote destination IPv6; an IPv4 result or null is never IPv6 proof.
function Invoke-CheckHostTcp {
    param([Parameter(Mandatory)][string] $Target, [string[]] $Nodes = @())
    $query = 'host=' + [uri]::EscapeDataString($Target)
    if (@($Nodes).Count -eq 0) {
        $query += '&max_nodes=8'
    } else {
        foreach ($id in $Nodes) {
            if ($id -notmatch '^[a-z0-9-]+\.node\.check-host\.net$') {
                throw 'CHECKHOST_INVALID_NODE_ID'
            }
            $query += '&node=' + [uri]::EscapeDataString($id)
        }
    }
    $uri = 'https://check-host.net/check-tcp?' + $query
    $request = Invoke-RestMethod -Uri $uri -Headers @{ Accept='application/json' } -TimeoutSec 8 -ErrorAction Stop
    if ([int]$request.ok -ne 1 -or [string]::IsNullOrWhiteSpace([string]$request.request_id)) {
        throw 'CHECKHOST_BAD_START_RESPONSE'
    }
    if ($null -eq $request.nodes) { throw 'CHECKHOST_NO_NODES' }
    $ids = @($request.nodes.PSObject.Properties | ForEach-Object { $_.Name })
    if ($ids.Count -eq 0) { throw 'CHECKHOST_NO_NODES' }
    $pollUrl = 'https://check-host.net/check-result/' + [uri]::EscapeDataString([string]$request.request_id)
    $data = $null
    for ($i=0; $i -lt 6; $i++) {
        Start-Sleep -Seconds 1
        $data = Invoke-RestMethod -Uri $pollUrl -Headers @{ Accept='application/json' } -TimeoutSec 5 -ErrorAction Stop
        if ($null -eq $data) { continue }
        $pending = @(
            foreach ($id in $ids) {
                $p = $data.PSObject.Properties[$id]
                if ($null -eq $p -or $null -eq $p.Value) { $id }
            }
        )
        if ($pending.Count -eq 0) { break }
    }
    return [pscustomobject]@{ Nodes=$request.nodes; Ids=$ids; Results=$data }
}
function Test-CheckHostIPv6Hit {
    param([object] $Report, [string] $Node, [string] $ExpectedIPv6='')
    if ($null -eq $Report -or $null -eq $Report.Results) { return $false }
    $p = $Report.Results.PSObject.Properties[$Node]
    if ($null -eq $p -or $null -eq $p.Value) { return $false }
    foreach ($hit in @($p.Value)) {
        if ($null -eq $hit) { continue }
        $a = $hit.PSObject.Properties['address']
        $t = $hit.PSObject.Properties['time']
        if ($null -eq $a -or $null -eq $t) { continue }
        try {
            $ip = [System.Net.IPAddress]::Parse([string]$a.Value)
            if ($ip.AddressFamily -ne [System.Net.Sockets.AddressFamily]::InterNetworkV6) { continue }
            if ($ExpectedIPv6) {
                if (-not $ip.Equals([System.Net.IPAddress]::Parse($ExpectedIPv6))) { continue }
            }
            return $true
        } catch { continue }
    }
    return $false
}
$checkHostNodes = @()
if ($UseMultiSourceIPv6Probe) {
    # Positive controls are run BEFORE exposure, against a known IPv6-only
    # hostname. Require TWO confirmed IPv6 Check-Host nodes from distinct ASNs,
    # in addition to a separate independent TCPData IPv6 control.
    try {
        if ((Get-TcpDataPortStatus -Target 'ipv6.google.com') -ne 'open') {
            throw 'TCPDATA_CONTROL_NOT_OPEN'
        }
        $control = Invoke-CheckHostTcp -Target 'ipv6.google.com:443'
        $eligible = @(
            foreach ($id in $control.Ids) {
                if (-not (Test-CheckHostIPv6Hit -Report $control -Node $id)) { continue }
                $meta = @($control.Nodes.PSObject.Properties[$id].Value)
                $asn = if ($meta.Count -ge 5) { [string]$meta[4] } else { '' }
                if ($asn -match '^AS[0-9]+$') {
                    [pscustomobject]@{ Node=$id; Asn=$asn }
                }
            }
        )
        $checkHostNodes = @(
            $eligible | Group-Object Asn | ForEach-Object { $_.Group[0] } |
                Select-Object -First 3
        )
        if ($checkHostNodes.Count -lt 2) { throw 'CHECKHOST_TWO_IPV6_ASNS_REQUIRED' }
    } catch {
        throw 'STOP: multi-source remote IPv6 positive controls unavailable; no listener or firewall changes.'
    }
    Write-Output 'REMOTE_TCPDATA_IPV6_CONTROL=PASS'
    Write-Output 'REMOTE_CHECKHOST_IPV6_DISTINCT_ASN_CONTROL=PASS'
    Write-Output "REMOTE_CHECKHOST_CONTROL_NODE_COUNT=$($checkHostNodes.Count)"
}

if ($UseTcpDataIPv6Probe) {
    try {
        $control = Get-TcpDataPortStatus -Target 'ipv6.google.com'
    }
    catch {
        throw 'STOP: Third-party checker positive-control request failed. No listener or firewall change.'
    }
    if ($control -ne 'open') {
        throw 'STOP: Third-party checker did not demonstrate IPv6 TCP443 access to known public control. No listener or firewall change.'
    }
    Write-Output 'REMOTE_IPV6_CHECKER_CONTROL=PASS'
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
# A public CA certificate is NOT requested; no root CA is installed.
$config = @"
{
    admin off
    auto_https disable_redirects
    skip_install_trust
}

https://$Hostname {
    bind tcp6/[$ipv6]
    tls internal
    respond $probePath "$probeBody" 200
    respond "Not Found" 404
}
"@
[System.IO.File]::WriteAllText($configPath, $config, [System.Text.UTF8Encoding]::new($false))

try {
    & $caddyPath adapt --config $configPath --adapter caddyfile *> $null
    if ($LASTEXITCODE -ne 0) { throw 'STOP: Caddy config adaptation failed.' }
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
        '-DelaySeconds', [string]$DurationSeconds
    )
    $guard = Start-Process -FilePath $pwsh.Source -ArgumentList $watchdogArgs -WindowStyle Hidden -PassThru
    if ($guard.HasExited) {
        throw 'STOP: expiry watchdog failed to start; firewall remains unchanged.'
    }

    # ActiveStore avoids persistent rule across reboot. Exact IPv6 and Caddy only.
    $null = New-NetFirewallRule -PolicyStore ActiveStore -Name $ruleName -DisplayName 'MCP P2 TEMP IPv6 TCP 443 reachability probe' -Enabled True -Direction Inbound -Action Allow -Profile Private -Program $caddyPath -Protocol TCP -LocalPort 443 -LocalAddress $ipv6 -RemoteAddress Any
    $firewallCreated = $true
    $openedAtUtc = (Get-Date).ToUniversalTime()
    $deadline = (Get-Date).AddSeconds($DurationSeconds - 15)
    Write-Output ('FIREWALL_READY_UTC=' + $openedAtUtc.ToString('o'))
    Write-Output "MAX_FIREWALL_WINDOW_SECONDS=$DurationSeconds"

    # Independent local-IPv6 HTTPS check on the test-only static endpoint.
    # -k is strictly for this temporary internal CA; never for public MCP.
    $curl = Get-Command curl.exe -CommandType Application -ErrorAction Stop | Select-Object -First 1
    $testUrl = "https://$Hostname$probePath"
    $localResult = ((& $curl.Source --noproxy '*' --insecure --ipv6 --connect-timeout 2 --max-time 6 --resolve "${Hostname}:443:[$ipv6]" --silent $testUrl 2>$null) -join "`n").Trim()
    if ($LASTEXITCODE -ne 0 -or $localResult -ne $probeBody) {
        throw 'STOP: local static HTTPS response over selected global IPv6 failed; remote check cancelled.'
    }
    Write-Output 'LOCAL_IPV6_HTTPS_STATIC=PASS'

    # This is a limited diagnostic from an independent external IPv6 source.
    # TcpData documents IPv6 literal support but performs HTTPS on port 443:
    # a non-open result may reflect TLS trust policy rather than only TCP.
    # Never interpret timeout/closed by itself as a confirmed router block.
    if ($UseTcpDataIPv6Probe) {
        try {
            $remote = Get-TcpDataPortStatus -Target $ipv6
            Write-Output "REMOTE_IPV6_TCPDATA_STATUS=$($remote.ToUpperInvariant())"
        }
        catch {
            Write-Output 'REMOTE_IPV6_TCPDATA_STATUS=INCONCLUSIVE_PROVIDER_ERROR'
        }
        Write-Output 'REMOTE_IPV6_TCPDATA_NOTE=Non-open results may include untrusted test TLS; not router proof'
    }

    # Two-provider/three-node evidence collected in ONE firewall window.
    # Each Check-Host node is pretested IPv6-capable and from a distinct ASN.
    if ($UseMultiSourceIPv6Probe) {
        if ((Get-Date) -ge $deadline) {
            Write-Output 'MULTISOURCE_STATUS=INCONCLUSIVE_WINDOW_EXPIRED'
        } else {
            try {
                $status = Get-TcpDataPortStatus -Target $ipv6
                Write-Output "REMOTE_IPV6_TCPDATA_STATUS=$($status.ToUpperInvariant())"
            } catch {
                Write-Output 'REMOTE_IPV6_TCPDATA_STATUS=INCONCLUSIVE_PROVIDER_ERROR'
            }
            if ((Get-Date) -ge $deadline) {
                Write-Output 'REMOTE_CHECKHOST_STATUS=INCONCLUSIVE_WINDOW_EXPIRED'
            } else {
                try {
                    $ids = @($checkHostNodes | ForEach-Object { $_.Node })
                    $destination = '[' + $ipv6 + ']:443'
                    $remote = Invoke-CheckHostTcp -Target $destination -Nodes $ids
                    $pass = 0
                    foreach ($node in $checkHostNodes) {
                        $ok = Test-CheckHostIPv6Hit -Report $remote -Node $node.Node -ExpectedIPv6 $ipv6
                        if ($ok) { $pass++ }
                        $state = if ($ok) { 'TCP_IPV6_PASS' } else { 'FAILED_OR_INCONCLUSIVE' }
                        Write-Output "REMOTE_CHECKHOST_NODE=$($node.Node) ASN=$($node.Asn) STATUS=$state"
                    }
                    Write-Output "REMOTE_CHECKHOST_IPV6_SUCCESS_COUNT=$pass"
                } catch {
                    Write-Output 'REMOTE_CHECKHOST_STATUS=INCONCLUSIVE_PROVIDER_ERROR'
                }
            }
        }
        Write-Output 'REMOTE_PROBE_SCOPE=TCP_ONLY; external TLS-SNI/ALPN not established'
    }

    Write-Output 'TEMP_IPV6_443_LISTENER=BOUND'
    Write-Output 'FIREWALL_TEST_RULE=SCOPED_ACTIVE'
    Write-Output 'MCP_BACKEND_EXPOSED=NO'
    Write-Output 'TLS_CERTIFICATE=INTERNAL_TEST_ONLY'
    Write-Output "PROBE_URL=https://$Hostname$probePath"
    Write-Output "WINDOW_SECONDS_MAX=$DurationSeconds"
    Write-Output "WINDOW_SECONDS_NORMAL=$($DurationSeconds - 15)"
    Write-Output 'TEST_FROM=PHONE_MOBILE_DATA_WITH_WIFI_OFF; external IPv6 required'
    Write-Output 'BROWSER_CERTIFICATE_WARNING=EXPECTED; not production-safe'
    Write-Output 'CLEANUP=Automatic at end; independent expiry failsafe armed'
    Write-Output 'EMERGENCY: Ctrl+C triggers cleanup; if needed, reboot resets ActiveStore rule'

    # Main cleanup at least 15s before watchdog hard ceiling.
    while ((Get-Date) -lt $deadline) {
        if ($process.HasExited) { throw 'STOP: test Caddy process exited early.' }
        Start-Sleep -Seconds 2
    }
    Write-Output 'TEST_WINDOW=EXPIRED'
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
    # Local diagnostic files stay under TEMP; no IP or token is printed.
}
