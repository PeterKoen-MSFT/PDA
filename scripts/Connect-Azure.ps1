<#
.SYNOPSIS
    Selects the target subscription for subsequent az commands.
.DESCRIPTION
    Authentication is performed by the workflow's OIDC login step. This script only
    pins the active subscription so the deployment scripts contain the az logic.
#>

. "$PSScriptRoot/_Common.ps1"

$config = Get-PdaConfig

Write-Step "Setting active subscription to $($config.SubscriptionId)"
Invoke-Az account set --subscription $config.SubscriptionId | Out-Null

Write-Step 'Ensuring the Bicep CLI is available'
try { Invoke-Az bicep version | Out-Null } catch { Invoke-Az bicep install | Out-Null }

Write-Step 'Azure context ready'
Invoke-Az account show --output table
