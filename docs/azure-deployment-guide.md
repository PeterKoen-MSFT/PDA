# PDA on Azure — Deployment Guide

This guide provisions the PDA governance demo to Azure Container Apps using Bicep
(Azure Verified Modules) and GitHub Actions. All Azure logic lives in PowerShell
scripts under `scripts/`; the workflows only orchestrate them.

## Contents

- [What gets deployed](#what-gets-deployed)
- [Prerequisites](#prerequisites)
- [1. Create the Entra app registration and federated credential](#1-create-the-entra-app-registration-and-federated-credential)
- [2. Grant Azure permissions](#2-grant-azure-permissions)
- [3. Configure GitHub secrets and variables](#3-configure-github-secrets-and-variables)
- [4. Deploy via GitHub Actions](#4-deploy-via-github-actions)
- [5. First-run configuration in the app](#5-first-run-configuration-in-the-app)
- [Manual / local deployment](#manual--local-deployment)
- [Configuration reference](#configuration-reference)
- [Teardown](#teardown)
- [Troubleshooting](#troubleshooting)

## What gets deployed

A single resource-group deployment ([infra/main.bicep](../infra/main.bicep)) creates:
Log Analytics, Application Insights, a user-assigned managed identity, Container
Registry, Key Vault (with an RSA KEK), a Storage account (SMB state share + immutable
compliance archive), a Container Apps environment, the web app, and — optionally — the
serverless-GPU Ollama route. See [azure-architecture.md](azure-architecture.md) for the
full picture.

Pipeline stages ([.github/workflows/deploy.yml](../.github/workflows/deploy.yml)):

| Step | Script | Action |
| --- | --- | --- |
| Azure login | `azure/login@v2` (OIDC) | Federated, secretless sign-in |
| Select subscription | [scripts/Connect-Azure.ps1](../scripts/Connect-Azure.ps1) | `az account set`, verify Bicep |
| Build and push image | [scripts/Build-And-PushImage.ps1](../scripts/Build-And-PushImage.ps1) | Ensure RG + ACR, `az acr build` (no local Docker) |
| Deploy infrastructure | [scripts/Deploy-Infrastructure.ps1](../scripts/Deploy-Infrastructure.ps1) | `az deployment group create` |

## Prerequisites

- An Azure subscription and permission to create resources and role assignments.
- **GPU quota** for Container Apps serverless GPU in your target region if
  `PDA_DEPLOY_OLLAMA=true` (e.g. `Consumption-GPU-NC8as-T4` in `swedencentral`).
  Request quota, or set `PDA_DEPLOY_OLLAMA=false` to skip it.
- Azure CLI ≥ 2.60 with the Bicep CLI (only for manual deploys).
- A GitHub repository with Actions enabled.

## 1. Create the Entra app registration and federated credential

Create an app registration the workflow uses for OIDC (no client secret):

```bash
az ad app create --display-name "pda-github-deployer"
APP_ID=$(az ad app list --display-name "pda-github-deployer" --query "[0].appId" -o tsv)
az ad sp create --id "$APP_ID"

# Federated credential scoped to your repo's production environment.
az ad app federated-credential create --id "$APP_ID" --parameters '{
  "name": "pda-github-production",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:<OWNER>/<REPO>:environment:production",
  "audiences": ["api://AzureADTokenExchange"]
}'
```

> The `subject` must match how the workflow runs. This repo's workflows use
> `environment: production`, so the subject is
> `repo:<OWNER>/<REPO>:environment:production`. For branch-triggered runs without an
> environment, use `repo:<OWNER>/<REPO>:ref:refs/heads/main` instead.

Record the app (client) ID, your tenant ID and subscription ID:

```bash
echo "AZURE_CLIENT_ID=$APP_ID"
az account show --query "{tenantId:tenantId, subscriptionId:id}" -o json
```

## 2. Grant Azure permissions

The deploying principal needs to create resources and assign roles in the target
scope. For a demo, grant it at the subscription (or a pre-created resource group):

```bash
SP_OBJECT_ID=$(az ad sp show --id "$APP_ID" --query id -o tsv)
SUB_ID=$(az account show --query id -o tsv)

# Create/assign at a resource group you control (recommended) or the subscription.
az role assignment create --assignee-object-id "$SP_OBJECT_ID" \
  --assignee-principal-type ServicePrincipal \
  --role "Contributor" --scope "/subscriptions/$SUB_ID"

# Needed because the template creates role assignments.
az role assignment create --assignee-object-id "$SP_OBJECT_ID" \
  --assignee-principal-type ServicePrincipal \
  --role "User Access Administrator" --scope "/subscriptions/$SUB_ID"
```

Optionally set `DEPLOYER_PRINCIPAL_ID=$SP_OBJECT_ID` (see below) so the deployer is
granted **Key Vault Secrets Officer** for seeding secrets.

## 3. Configure GitHub secrets and variables

In **Settings → Secrets and variables → Actions** (and create the `production`
environment):

Secrets:

| Secret | Value |
| --- | --- |
| `AZURE_CLIENT_ID` | app (client) ID from step 1 |
| `AZURE_TENANT_ID` | your tenant ID |
| `AZURE_SUBSCRIPTION_ID` | your subscription ID |

Variables:

| Variable | Example | Notes |
| --- | --- | --- |
| `AZURE_RESOURCE_GROUP` | `pda-demo-rg` | Created if missing |
| `AZURE_LOCATION` | `swedencentral` | Use a GPU-capable region if deploying Ollama |
| `PDA_NAME_PREFIX` | `pda` | 2–8 lower-case chars/digits |
| `PDA_DEPLOY_OLLAMA` | `true` / `false` | Toggle the GPU route |
| `PDA_OLLAMA_MODEL` | `llama3.1` | Model pulled on start |
| `PDA_OLLAMA_PROFILE` | `Consumption-GPU-NC8as-T4` | Must match available GPU quota |
| `DEPLOYER_PRINCIPAL_ID` | *(SP object ID)* | Optional; grants KV Secrets Officer |

## 4. Deploy via GitHub Actions

- Push to `main` (paths under `app/`, `public/`, `infra/`, `scripts/`, `server.mjs`,
  `package.json`, `Dockerfile`) or run **Deploy PDA to Azure** manually from the
  Actions tab.
- On success, the deploy step prints the public web URL (also available as the
  `deploy` step output `webUrl`).

## 5. First-run configuration in the app

1. Open the web URL and go to **Administrator**.
2. Review and **publish** the signed policy revision you want to demo.
3. In **Route settings**, enable providers and enter API keys for the EU routes
   (Mistral / SimpleLLM). Keys are protected at rest via the Key Vault–backed
   envelope encryption.
4. Set the **Internal model preference** (Mistral or SimpleLLM).
5. The **sovereign / highly confidential** route uses the internal Ollama app; the
   first turn may be slower while the model finishes pulling.

> The Public → Copilot route is not usable in Container Apps (no interactive Copilot
> CLI sign-in). Demonstrate governance with the EU and sovereign routes.

## Manual / local deployment

You can deploy from a workstation with Azure CLI (the scripts read the same
environment variables):

```powershell
$env:AZURE_SUBSCRIPTION_ID = '<sub>'
$env:AZURE_RESOURCE_GROUP  = 'pda-demo-rg'
$env:AZURE_LOCATION        = 'swedencentral'
$env:PDA_NAME_PREFIX       = 'pda'

az login
./scripts/Connect-Azure.ps1
./scripts/Build-And-PushImage.ps1
./scripts/Deploy-Infrastructure.ps1
```

Or deploy the template directly (after building/pushing an image):

```powershell
az deployment group create `
  --resource-group pda-demo-rg `
  --template-file infra/main.bicep `
  --parameters infra/main.bicepparam `
  --parameters webImage='<acr>.azurecr.io/pda/web:<tag>' acrName='<acr>'
```

## Configuration reference

Environment variables read by the deployment scripts
([scripts/_Common.ps1](../scripts/_Common.ps1)):

| Variable | Required | Default | Purpose |
| --- | --- | --- | --- |
| `AZURE_SUBSCRIPTION_ID` | yes | — | Target subscription |
| `AZURE_RESOURCE_GROUP` | yes | — | Target resource group (created if missing) |
| `AZURE_LOCATION` | no | `swedencentral` | Region |
| `PDA_NAME_PREFIX` | no | `pda` | Resource name prefix |
| `PDA_ACR_NAME` | no | derived | Registry name (deterministic per sub+RG if unset) |
| `PDA_IMAGE_REPOSITORY` | no | `pda/web` | Image repository |
| `PDA_IMAGE_TAG` | no | `GITHUB_SHA`/`local` | Image tag |
| `PDA_DEPLOY_OLLAMA` | no | `true` | Deploy the GPU route |
| `PDA_OLLAMA_MODEL` | no | `llama3.1` | Ollama model |
| `PDA_OLLAMA_PROFILE` | no | `Consumption-GPU-NC8as-T4` | GPU workload profile |
| `DEPLOYER_PRINCIPAL_ID` | no | — | Grants KV Secrets Officer to the deployer |
| `PDA_WEB_IMAGE` | no | derived | Full image ref (set from the build step) |

Bicep parameters are documented inline in [infra/main.bicep](../infra/main.bicep).

## Teardown

Run the **Teardown PDA Azure environment** workflow and type `delete` to confirm, or
locally:

```powershell
./scripts/Remove-Infrastructure.ps1
```

> Key Vault has **purge protection** enabled, so the vault is *recoverable* (not
> immediately purgeable) until its soft-delete retention elapses. The compliance
> archive's WORM policy also prevents blob deletion within the retention window.

## Troubleshooting

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| `az deployment` fails on GPU profile | No GPU quota in region | Request quota or set `PDA_DEPLOY_OLLAMA=false` |
| Login step fails (`AADSTS700...`) | Federated subject mismatch | Ensure the federated credential subject matches the run (environment/branch) |
| Template role-assignment error | Deployer lacks `User Access Administrator` | Grant it at the deployment scope |
| Web app unhealthy after deploy | Image not built / wrong port | Confirm `Build-And-PushImage` ran; probe path is `/healthz` on `8110` |
| Public route errors in cloud | Copilot CLI sign-in unavailable | Use EU/sovereign routes; configure in Admin |
| App can't unwrap the data key | UAMI missing KV Crypto User or wrong `AZURE_KEY_VAULT_URI` | Verify role assignment and env vars on the container app |
