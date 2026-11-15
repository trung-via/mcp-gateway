#Requires -Version 7.0
# Source-only security contract for a private-repository workflow TEMPLATE.
# Never executes private workflow, registers a runner or contacts external providers.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../..')).Path
$templatePath = Join-Path $root 'templates/private-hostops/workflows/mcp-p2-provider-readonly.yml'
$readmePath = Join-Path $root 'templates/private-hostops/README.md'
$sourcePath = Join-Path $root 'scripts/hostops/p2-ipv6-provider-controls-readonly.ps1'
foreach ($path in @($templatePath, $readmePath, $sourcePath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw 'PRIVATE_TEMPLATE_FILE_MISSING' }
}
$workflow = Get-Content -LiteralPath $templatePath -Raw
$readme = Get-Content -LiteralPath $readmePath -Raw
$sourceBlob = (& git -C $root rev-parse 'HEAD:scripts/hostops/p2-ipv6-provider-controls-readonly.ps1').Trim()
if ($LASTEXITCODE -ne 0 -or $sourceBlob -ne '1172099c35eccb56d694d9a3c2f4fa3a145aced5') {
    throw 'PRIVATE_TEMPLATE_SOURCE_BLOB_NOT_PINNED'
}
if ($workflow -notmatch [regex]::Escape($sourceBlob)) { throw 'PRIVATE_WORKFLOW_SOURCE_BLOB_NOT_PINNED' }
$mustContain = @(
    'issues:', 'types: [opened]', 'authorize-on-github-hosted:',
    'runs-on: windows-latest', 'execute-on-dedicated-windows:',
    'runs-on: [self-hosted, windows, X64, mcp-gateway-hostops-private]',
    'needs: authorize-on-github-hosted',
    "needs.authorize-on-github-hosted.outputs.approved == 'true'",
    'trung-via/mcp-gateway-hostops-private', 'GITHUB_RUN_ATTEMPT',
    'TotalSeconds -le 300', 'GITHUB_ACTOR', 'event.sender.login',
    'issue.user.login', "issue.body -ceq '{}'",
    'MCP_P2_IPV6_PROVIDER_CONTROL_READONLY_V1',
    'MCP_P2_HOSTOPS_RECEIPT_V1=', 'RECEIPT_SCHEMA_DENY',
    'PRIVATE_RECEIPT_POST_FAILED', 'persist-credentials: false',
    'permissions:', 'contents: read', 'issues: write'
)
foreach ($clause in $mustContain) {
    if (-not $workflow.Contains($clause)) { throw ('PRIVATE_TEMPLATE_REQUIRED_CLAUSE_MISSING_' + $clause) }
}
if ($workflow -match '(?im)^\s*(?:issue_comment|pull_request|pull_request_target|workflow_dispatch|repository_dispatch):\s*$') {
    throw 'PRIVATE_TEMPLATE_DYNAMIC_TRIGGER_DENIED'
}
if ($workflow -notmatch 'uses:\s+actions/checkout@[0-9a-f]{40}') {
    throw 'PRIVATE_TEMPLATE_CHECKOUT_NOT_IMMUTABLY_PINNED'
}
if ($workflow -match '(?i)ai-commerce|cdp.?9444|new-netfirewallrule|start-process|invoke-expression') {
    throw 'PRIVATE_TEMPLATE_FORBIDDEN_EFFECT_OR_CROSS_PROJECT'
}
if ($workflow -match '(?im)^\s+run:\s*\$\{\{') { throw 'PRIVATE_TEMPLATE_DYNAMIC_RUN_DENIED' }
if ($readme -notmatch 'NOT deployed' -or $readme -notmatch 'private' -or $readme -notmatch 'non-admin') {
    throw 'PRIVATE_TEMPLATE_NOT_MARKED_SOURCE_ONLY'
}
if (Test-Path -LiteralPath (Join-Path $root '.github/workflows/mcp-p2-provider-readonly.yml')) {
    throw 'PRIVATE_TEMPLATE_ACTIVE_IN_PUBLIC_REPO'
}
Write-Output 'MCP_PRIVATE_HOSTOPS_TEMPLATE_STATIC_TESTS=PASS'
