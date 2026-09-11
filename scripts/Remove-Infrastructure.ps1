<#
.SYNOPSIS
    Tears down the PDA deployment.
.DESCRIPTION
    Deletes the resource group. Key Vault has purge protection enabled, so the vault
    is recoverable (not purgeable) until its soft-delete retention elapses. Run this
    only against disposable demo environments.
#>

. "$PSScriptRoot/_Common.ps1"

$config = Get-PdaConfig

Write-Step "Deleting resource group $($config.ResourceGroup)"
Invoke-Az group delete `
    --name $config.ResourceGroup `
    --yes `
    --no-wait

Write-Step "Delete requested for $($config.ResourceGroup) (running asynchronously)."
