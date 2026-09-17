<#
.SYNOPSIS
    Removes the Policy Driven Agent Azure VM deployment by deleting its resource
    group. Idempotent: succeeds whether or not the group still exists.

.DESCRIPTION
    Deletes the resource group created by Deploy-AzureVM.ps1, which removes the VM,
    disk, network, public IP and staging storage. It does not affect the local
    (startdemo.ps1) deployment.

.EXAMPLE
    ./Remove-AzureVM.ps1
    ./Remove-AzureVM.ps1 -Force   # skip the confirmation prompt
#>

[CmdletBinding()]
param(
    [string] $ConfigPath = (Join-Path $PSScriptRoot 'pda-vm.config.json'),
    [string] $ResourceGroup,
    [switch] $Force
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Module -ListAvailable -Name Az.Resources)) {
    throw "Required module 'Az.Resources' is not installed. Run: Install-Module Az -Scope CurrentUser"
}

if (-not $ResourceGroup) {
    if (Test-Path $ConfigPath) {
        $config = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
        if ($config.PSObject.Properties.Name -contains 'resourceGroup' -and $config.resourceGroup) {
            $ResourceGroup = $config.resourceGroup
        }
    }
    if (-not $ResourceGroup) { $ResourceGroup = 'pda-vm-rg' }
}

if (-not (Get-AzContext)) { Connect-AzAccount | Out-Null }

$rg = Get-AzResourceGroup -Name $ResourceGroup -ErrorAction SilentlyContinue
if (-not $rg) {
    Write-Host "Resource group '$ResourceGroup' does not exist. Nothing to remove."
    return
}

if (-not $Force) {
    $answer = Read-Host "Delete resource group '$ResourceGroup' and ALL its resources? Type 'yes' to confirm"
    if ($answer -ne 'yes') { Write-Host 'Aborted.'; return }
}

Write-Host "Deleting resource group '$ResourceGroup'..."
Remove-AzResourceGroup -Name $ResourceGroup -Force | Out-Null
Write-Host 'Removal complete.'
