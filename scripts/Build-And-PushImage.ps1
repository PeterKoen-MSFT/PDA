<#
.SYNOPSIS
    Builds the web container image inside Azure Container Registry and returns the
    full image reference.
.DESCRIPTION
    Ensures the resource group and registry exist (so the build can run before the
    main infrastructure deployment), then uses `az acr build` to build the Dockerfile
    server-side — no local Docker daemon is required. The resulting image reference is
    written to the GitHub step output 'image'.
#>

. "$PSScriptRoot/_Common.ps1"

$config = Get-PdaConfig
$image = "$($config.AcrLoginServer)/$($config.ImageRepository):$($config.ImageTag)"

Write-Step "Ensuring resource group $($config.ResourceGroup) in $($config.Location)"
Invoke-Az group create `
    --name $config.ResourceGroup `
    --location $config.Location `
    --output none

Write-Step "Ensuring container registry $($config.AcrName)"
Invoke-Az acr create `
    --resource-group $config.ResourceGroup `
    --name $config.AcrName `
    --sku Standard `
    --admin-enabled false `
    --output none

Write-Step "Building image $image from $($config.RepoRoot)"
Invoke-Az acr build `
    --registry $config.AcrName `
    --image "$($config.ImageRepository):$($config.ImageTag)" `
    --file (Join-Path $config.RepoRoot 'Dockerfile') `
    $config.RepoRoot

Set-GitHubOutput -Name 'image' -Value $image
Write-Step "Image published: $image"
