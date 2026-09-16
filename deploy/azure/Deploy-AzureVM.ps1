<#
.SYNOPSIS
    Deploys the Policy Driven Agent to a single Azure Windows VM. Idempotent:
    re-running it converges the same resource group to the same running system.

.DESCRIPTION
    The script is safe to run repeatedly. It:
      * ensures the resource group exists and carries the SecurityControl tag;
      * derives deterministic resource names from the subscription + group, so
        every run targets the same resources instead of creating duplicates;
      * deploys the staging storage account (Azure Verified Module), uploads the
        bootstrap script and a fresh application package, and mints short-lived
        read-only SAS URLs;
      * deploys the network and VM (Azure Verified Modules) in incremental mode,
        which updates in place rather than recreating.

    It does not touch the local (startdemo.ps1) deployment.

.EXAMPLE
    ./Deploy-AzureVM.ps1
    Reads deploy/azure/pda-vm.config.json and prompts for the VM admin password.
#>

[CmdletBinding()]
param(
    [string] $ConfigPath = (Join-Path $PSScriptRoot 'pda-vm.config.json'),
    [securestring] $AdminPassword
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

foreach ($module in 'Az.Accounts', 'Az.Resources', 'Az.Storage') {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        throw "Required module '$module' is not installed. Run: Install-Module Az -Scope CurrentUser"
    }
}

if (-not (Test-Path $ConfigPath)) {
    throw "Configuration file not found: $ConfigPath. Copy pda-vm.config.example.json to pda-vm.config.json and edit it."
}
$config = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json

function Get-ConfigValue {
    param([string] $Name, [string] $Default, [switch] $Required)
    $value = if ($config.PSObject.Properties.Name -contains $Name) { $config.$Name } else { $null }
    if ([string]::IsNullOrWhiteSpace([string]$value)) {
        if ($Required) { throw "Configuration value '$Name' is required in $ConfigPath." }
        return $Default
    }
    return $value
}

$subscriptionId  = Get-ConfigValue -Name 'subscriptionId'
$resourceGroup   = Get-ConfigValue -Name 'resourceGroup' -Default 'pda-vm-rg'
$location        = Get-ConfigValue -Name 'location' -Default 'swedencentral'
$namePrefix      = Get-ConfigValue -Name 'namePrefix' -Default 'pda'
$vmSize          = Get-ConfigValue -Name 'vmSize' -Default 'Standard_E8s_v5'
$adminUsername   = Get-ConfigValue -Name 'adminUsername' -Default 'pdaadmin'
$allowedSource   = Get-ConfigValue -Name 'allowedSourceAddressPrefix' -Default '*'
$basicAuthUser   = Get-ConfigValue -Name 'basicAuthUsername' -Required
$basicAuthPass   = Get-ConfigValue -Name 'basicAuthPassword' -Required
$ollamaModel     = Get-ConfigValue -Name 'ollamaModel' -Default 'qwen2.5:7b'
$nodeVersion     = Get-ConfigValue -Name 'nodeVersion' -Default '22.11.0'
$dnsLabelConfig  = Get-ConfigValue -Name 'dnsLabel'

$tags = @{ SecurityControl = 'Ignore' }

# --- Azure context -------------------------------------------------------------
$context = Get-AzContext
if (-not $context) { Connect-AzAccount | Out-Null; $context = Get-AzContext }
if (-not $subscriptionId) { $subscriptionId = $context.Subscription.Id }
if ($context.Subscription.Id -ne $subscriptionId) {
    Set-AzContext -Subscription $subscriptionId | Out-Null
}
Write-Host "Subscription : $subscriptionId"

# --- Deterministic names (stable across runs => idempotent) --------------------
$seed   = "$subscriptionId/$resourceGroup".ToLowerInvariant()
$sha    = [Security.Cryptography.SHA256]::Create()
$hash   = ($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($seed)) | ForEach-Object { $_.ToString('x2') }) -join ''
$suffix = $hash.Substring(0, 10)
$storageAccountName = "pdastg$suffix"
$containerName      = 'stage'
$dnsLabel = if ($dnsLabelConfig) { $dnsLabelConfig } else { "$namePrefix-$suffix" }
Write-Host "Resource group : $resourceGroup ($location)"
Write-Host "Storage account: $storageAccountName"
Write-Host "DNS label      : $dnsLabel"

# --- VM admin password ---------------------------------------------------------
if (-not $AdminPassword) {
    $AdminPassword = Read-Host -AsSecureString -Prompt "Enter a password for VM administrator '$adminUsername'"
}

# --- Resource group (create if missing; always ensure the tag) -----------------
$rg = Get-AzResourceGroup -Name $resourceGroup -ErrorAction SilentlyContinue
if (-not $rg) {
    Write-Host 'Creating resource group...'
    $rg = New-AzResourceGroup -Name $resourceGroup -Location $location -Tag $tags
} else {
    if ($rg.Location -ne $location) {
        Write-Warning "Resource group '$resourceGroup' already exists in '$($rg.Location)', not '$location'. Using the existing location."
        $location = $rg.Location
        $dnsLabel = if ($dnsLabelConfig) { $dnsLabelConfig } else { "$namePrefix-$suffix" }
    }
    Set-AzResourceGroup -Name $resourceGroup -Tag $tags | Out-Null
}

# --- Staging storage account (AVM), then upload bootstrap + application ---------
Write-Host 'Deploying staging storage...'
New-AzResourceGroupDeployment `
    -Name ('pda-stage-' + (Get-Date -Format 'yyyyMMddHHmmss')) `
    -ResourceGroupName $resourceGroup `
    -Mode Incremental `
    -TemplateFile (Join-Path $PSScriptRoot 'stage.bicep') `
    -storageAccountName $storageAccountName `
    -containerName $containerName `
    -location $location `
    -tags $tags | Out-Null

$storageKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroup -Name $storageAccountName)[0].Value
$storageCtx = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageKey

# Build a fresh application package from the current working tree (source only).
$repoRoot = Resolve-Path (Join-Path (Join-Path $PSScriptRoot '..') '..')
$appZip   = Join-Path $env:TEMP "pda-app-$suffix.zip"
if (Test-Path $appZip) { Remove-Item $appZip -Force }
$appItems = @('app', 'public', 'settings', 'server.mjs', 'startdemo.ps1', 'stopdemo.ps1', 'package.json', 'README.md') |
    ForEach-Object { Join-Path $repoRoot $_ } |
    Where-Object { Test-Path $_ }
Write-Host 'Packaging application...'
Compress-Archive -Path $appItems -DestinationPath $appZip -Force

Write-Host 'Uploading bootstrap and application package...'
Set-AzStorageBlobContent -Context $storageCtx -Container $containerName -File (Join-Path $PSScriptRoot 'bootstrap.ps1') -Blob 'bootstrap.ps1' -Force | Out-Null
Set-AzStorageBlobContent -Context $storageCtx -Container $containerName -File $appZip -Blob 'app.zip' -Force | Out-Null

$sasExpiry     = (Get-Date).AddHours(6)
$bootstrapUri  = New-AzStorageBlobSASToken -Context $storageCtx -Container $containerName -Blob 'bootstrap.ps1' -Permission r -ExpiryTime $sasExpiry -FullUri
$appZipUri     = New-AzStorageBlobSASToken -Context $storageCtx -Container $containerName -Blob 'app.zip'      -Permission r -ExpiryTime $sasExpiry -FullUri

# --- Network + VM (AVM) --------------------------------------------------------
Write-Host 'Deploying network and virtual machine (this can take several minutes)...'
$deployment = New-AzResourceGroupDeployment `
    -Name ('pda-vm-' + (Get-Date -Format 'yyyyMMddHHmmss')) `
    -ResourceGroupName $resourceGroup `
    -Mode Incremental `
    -TemplateFile (Join-Path $PSScriptRoot 'main.bicep') `
    -location $location `
    -namePrefix $namePrefix `
    -vmSize $vmSize `
    -adminUsername $adminUsername `
    -adminPassword $AdminPassword `
    -dnsLabel $dnsLabel `
    -allowedSourceAddressPrefix $allowedSource `
    -bootstrapFileUri (ConvertTo-SecureString $bootstrapUri -AsPlainText -Force) `
    -appZipFileUri (ConvertTo-SecureString $appZipUri -AsPlainText -Force) `
    -basicAuthUsername (ConvertTo-SecureString $basicAuthUser -AsPlainText -Force) `
    -basicAuthPassword (ConvertTo-SecureString $basicAuthPass -AsPlainText -Force) `
    -ollamaModel $ollamaModel `
    -nodeVersion $nodeVersion `
    -tags $tags

Remove-Item $appZip -Force -ErrorAction SilentlyContinue

Write-Host ''
Write-Host '==================================================================='
Write-Host ' Deployment complete.'
Write-Host "   Public URL : $($deployment.Outputs.publicUrl.Value)"
Write-Host "   RDP host   : $($deployment.Outputs.rdpAddress.Value)"
Write-Host "   Basic auth : user '$basicAuthUser' (password from config file)"
Write-Host "   VM admin   : $adminUsername"
Write-Host '==================================================================='
Write-Host ' First run: RDP to the host as the VM administrator. The demo starts'
Write-Host ' automatically at logon (Ollama + Node). Sign in to Copilot and enter'
Write-Host ' the Mistral key via the Administrator page, exactly as on-premises.'
Write-Host ' Certificate issuance for the public HTTPS name takes a minute.'
Write-Host '==================================================================='
