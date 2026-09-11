<#
.SYNOPSIS
    Deploys the PDA infrastructure from infra/main.bicep (Azure Verified Modules).
.DESCRIPTION
    Runs a resource-group scoped Bicep deployment that provisions Log Analytics,
    Application Insights, Key Vault, Storage (SMB state share + immutable compliance
    archive), Container Registry, a user-assigned identity, the Container Apps
    environment, the web app, and the optional serverless-GPU Ollama route.
    Publishes the resulting web URL to the GitHub step output 'webUrl'.
#>

. "$PSScriptRoot/_Common.ps1"

$config = Get-PdaConfig

$webImage = Get-OptionalEnv 'PDA_WEB_IMAGE' "$($config.AcrLoginServer)/$($config.ImageRepository):$($config.ImageTag)"
$deploymentName = "pda-$($config.ImageTag)"
$templateFile = Join-Path $config.RepoRoot 'infra/main.bicep'

$parameters = @(
    "namePrefix=$($config.NamePrefix)"
    "acrName=$($config.AcrName)"
    "webImage=$webImage"
    "deployOllama=$($config.DeployOllama)"
    "ollamaModel=$($config.OllamaModel)"
    "ollamaWorkloadProfileType=$($config.OllamaProfileType)"
)
if (-not [string]::IsNullOrWhiteSpace($config.DeployerPrincipalId)) {
    $parameters += "deployerPrincipalId=$($config.DeployerPrincipalId)"
}

Write-Step "Deploying $deploymentName to $($config.ResourceGroup)"
$outputJson = Invoke-Az deployment group create `
    --resource-group $config.ResourceGroup `
    --name $deploymentName `
    --template-file $templateFile `
    --parameters $parameters `
    --query 'properties.outputs' `
    --output json

$outputs = $outputJson | ConvertFrom-Json
$webUrl = $outputs.webUrl.value

Set-GitHubOutput -Name 'webUrl' -Value $webUrl
Write-Step "Deployment complete. Web URL: $webUrl"
