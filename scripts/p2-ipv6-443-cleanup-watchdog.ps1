#Requires -Version 7.0
<#
.SYNOPSIS
  Detached expiry failsafe for the explicitly authorized, temporary P2 IPv6
  inbound connectivity test. This is intentionally not a general host agent.
.DESCRIPTION
  Removes ONLY a unique test firewall rule from ActiveStore and stops ONLY
  the matching newly launched Caddy process after a fixed delay.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string] $RuleName,
    [Parameter(Mandatory)][int] $CaddyPid,
    [Parameter(Mandatory)][string] $ExpectedExe,
    [Parameter(Mandatory)][string] $ExpectedConfigPath,
    [ValidateRange(20,600)][int] $DelaySeconds = 215
)

$ErrorActionPreference = 'Continue'
Start-Sleep -Seconds $DelaySeconds

try {
    Remove-NetFirewallRule -PolicyStore ActiveStore -Name $RuleName -ErrorAction SilentlyContinue
} catch {}

# Safeguard against PID reuse: never kill a different process, even if a PID
# has been recycled. The expected executable AND unique config must match.
try {
    $p = Get-CimInstance Win32_Process -Filter "ProcessId=$CaddyPid" -ErrorAction SilentlyContinue
    if ($p -and $p.ExecutablePath -and $p.CommandLine) {
        $sameExe = [System.IO.Path]::GetFullPath($p.ExecutablePath) -ieq
            [System.IO.Path]::GetFullPath($ExpectedExe)
        $sameConfig = $p.CommandLine.Contains($ExpectedConfigPath)
        if ($sameExe -and $sameConfig) {
            Stop-Process -Id $CaddyPid -Force -ErrorAction SilentlyContinue
        }
    }
} catch {}
