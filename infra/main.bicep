metadata description = 'PDA governance demo — Azure Container Apps hosting with Key Vault at-rest protection, immutable compliance archive, and an optional serverless GPU Ollama route. Built from Azure Verified Modules.'

targetScope = 'resourceGroup'

@description('Short prefix used to derive resource names. Lower-case letters and digits.')
@minLength(2)
@maxLength(8)
param namePrefix string = 'pda'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Full container image reference for the web app, including tag (e.g. myacr.azurecr.io/pda/web:1234). The pipeline supplies this after building and pushing.')
param webImage string

@description('Container registry name. Leave empty to derive one; the pipeline passes a deterministic name so it can build and push before this deployment runs.')
param acrName string = ''

@description('Deploy the sovereign Ollama route on a Container Apps serverless GPU profile.')
param deployOllama bool = true

@description('Container image for the Ollama route.')
param ollamaImage string = 'docker.io/ollama/ollama:0.3.14'

@description('Model tag Ollama pulls on start and the app targets for the on-premises/highly confidential route.')
param ollamaModel string = 'llama3.1'

@description('Serverless GPU workload profile type for the Ollama route. Requires GPU quota in the target region.')
param ollamaWorkloadProfileType string = 'Consumption-GPU-NC8as-T4'

@description('vCPU allocated to the Ollama container (must fit the chosen GPU profile).')
param ollamaCpu int = 8

@description('Memory allocated to the Ollama container (must fit the chosen GPU profile).')
param ollamaMemory string = '56Gi'

@description('Name of the Key Vault key that wraps the application data-encryption key.')
param kekName string = 'pda-kek'

@description('Retention window (days) for the time-based WORM immutability policy on the compliance archive.')
@minValue(1)
param immutabilityDays int = 365

@description('Emit a non-authoritative OpenTelemetry mirror of ledger appends to Application Insights.')
param enableOpenTelemetry bool = true

@description('Provision an Azure OpenAI (AI Foundry) account + deployment to serve the cloud Public route via managed identity.')
param deployAzureOpenAI bool = false

@description('Existing Azure OpenAI v1 endpoint to use instead of provisioning one (e.g. https://<res>.openai.azure.com/openai/v1). Ignored when deployAzureOpenAI is true.')
param azureOpenAiEndpoint string = ''

@description('Model deployment name the Public route targets.')
param azureOpenAiDeployment string = 'gpt-4o-mini'

@description('Model name deployed when deployAzureOpenAI is true.')
param azureOpenAiModel string = 'gpt-4o-mini'

@description('Model version deployed when deployAzureOpenAI is true.')
param azureOpenAiModelVersion string = '2024-07-18'

@description('Tokens-per-minute capacity (thousands) for the model deployment.')
@minValue(1)
param azureOpenAiCapacity int = 10

@description('Optional object ID of the CI/CD deploying principal. When set it is granted data-plane roles needed to seed Key Vault secrets.')
param deployerPrincipalId string = ''

@description('Tags applied to all resources.')
param tags object = {
  workload: 'pda-governance-demo'
  managedBy: 'bicep-avm'
}

var suffix = uniqueString(resourceGroup().id)
var storageAccountName = take(toLower(replace('${namePrefix}st${suffix}', '-', '')), 24)
var acrNameEffective = empty(acrName) ? take(toLower(replace('${namePrefix}acr${suffix}', '-', '')), 50) : toLower(acrName)
var keyVaultName = take('${namePrefix}-kv-${suffix}', 24)
var logAnalyticsName = '${namePrefix}-logs-${suffix}'
var appInsightsName = '${namePrefix}-appi-${suffix}'
var identityName = '${namePrefix}-id-${suffix}'
var environmentName = '${namePrefix}-env-${suffix}'
var webAppName = '${namePrefix}-web'
var ollamaAppName = '${namePrefix}-ollama'
var stateShareName = 'pda-state'
var ollamaShareName = 'ollama-models'
var archiveContainerName = 'compliance-archive'
var consumptionProfileName = 'Consumption'
var gpuProfileName = 'gpu'
var azureAccountName = take(toLower(replace('${namePrefix}aoai${suffix}', '-', '')), 63)

// -------------------------------------------------------------------------------------------------
// Identity
// -------------------------------------------------------------------------------------------------
module identity 'br/public:avm/res/managed-identity/user-assigned-identity:0.6.0' = {
  name: 'uami'
  params: {
    name: identityName
    location: location
    tags: tags
  }
}

// -------------------------------------------------------------------------------------------------
// Observability
// -------------------------------------------------------------------------------------------------
module logAnalytics 'br/public:avm/res/operational-insights/workspace:0.16.1' = {
  name: 'logAnalytics'
  params: {
    name: logAnalyticsName
    location: location
    tags: tags
  }
}

module appInsights 'br/public:avm/res/insights/component:0.8.0' = {
  name: 'appInsights'
  params: {
    name: appInsightsName
    location: location
    workspaceResourceId: logAnalytics.outputs.resourceId
    tags: tags
  }
}

// -------------------------------------------------------------------------------------------------
// Container registry — pull with the user-assigned identity, no admin user
// -------------------------------------------------------------------------------------------------
module registry 'br/public:avm/res/container-registry/registry:0.13.0' = {
  name: 'acr'
  params: {
    name: acrNameEffective
    location: location
    acrSku: 'Standard'
    acrAdminUserEnabled: false
    tags: tags
    roleAssignments: [
      {
        principalId: identity.outputs.principalId
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'AcrPull'
      }
    ]
  }
}

// -------------------------------------------------------------------------------------------------
// Key Vault — holds the key-encryption key (KEK) that wraps the app data key
// -------------------------------------------------------------------------------------------------
module keyVault 'br/public:avm/res/key-vault/vault:0.14.0' = {
  name: 'keyVault'
  params: {
    name: keyVaultName
    location: location
    sku: 'standard'
    enableRbacAuthorization: true
    enablePurgeProtection: true
    enableSoftDelete: true
    tags: tags
    keys: [
      {
        name: kekName
        kty: 'RSA'
        keySize: 3072
        keyOps: [
          'wrapKey'
          'unwrapKey'
        ]
      }
    ]
    roleAssignments: concat(
      [
        {
          principalId: identity.outputs.principalId
          principalType: 'ServicePrincipal'
          roleDefinitionIdOrName: 'Key Vault Crypto User'
        }
        {
          principalId: identity.outputs.principalId
          principalType: 'ServicePrincipal'
          roleDefinitionIdOrName: 'Key Vault Secrets User'
        }
      ],
      empty(deployerPrincipalId) ? [] : [
        {
          principalId: deployerPrincipalId
          roleDefinitionIdOrName: 'Key Vault Secrets Officer'
        }
      ]
    )
  }
}

// -------------------------------------------------------------------------------------------------
// Storage — SMB share for live state, immutable blob container for the compliance archive
// -------------------------------------------------------------------------------------------------
module storage 'br/public:avm/res/storage/storage-account:0.33.0' = {
  name: 'storage'
  params: {
    name: storageAccountName
    location: location
    kind: 'StorageV2'
    skuName: 'Standard_ZRS'
    allowBlobPublicAccess: false
    // The managed environment mounts the SMB share using the account key, so shared-key access stays on.
    allowSharedKeyAccess: true
    tags: tags
    blobServices: {
      containerDeleteRetentionPolicyEnabled: true
      containerDeleteRetentionPolicyDays: 7
      deleteRetentionPolicyEnabled: true
      deleteRetentionPolicyDays: 7
      isVersioningEnabled: true
      changeFeedEnabled: true
      containers: [
        {
          name: archiveContainerName
          publicAccess: 'None'
        }
      ]
    }
    fileServices: {
      shares: concat(
        [
          {
            name: stateShareName
            accessTier: 'TransactionOptimized'
            shareQuota: 100
          }
        ],
        deployOllama ? [
          {
            name: ollamaShareName
            accessTier: 'TransactionOptimized'
            shareQuota: 200
          }
        ] : []
      )
    }
    roleAssignments: [
      {
        principalId: identity.outputs.principalId
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'Storage Blob Data Contributor'
      }
    ]
  }
}

// Time-based WORM policy for the compliance archive. Protected append writes keep the
// append-only ledger archivable while blocking overwrite/delete within the retention window.
resource archiveImmutability 'Microsoft.Storage/storageAccounts/blobServices/containers/immutabilityPolicies@2024-01-01' = {
  name: '${storageAccountName}/default/${archiveContainerName}/default'
  properties: {
    immutabilityPeriodSinceCreationInDays: immutabilityDays
    allowProtectedAppendWrites: true
  }
  dependsOn: [
    storage
  ]
}

// -------------------------------------------------------------------------------------------------
// Azure OpenAI / AI Foundry — cloud Public route, managed-identity (AAD) auth only
// -------------------------------------------------------------------------------------------------
module azureOpenAi 'br/public:avm/res/cognitive-services/account:0.19.0' = if (deployAzureOpenAI) {
  name: 'azureOpenAi'
  params: {
    name: azureAccountName
    location: location
    tags: tags
    kind: 'OpenAI'
    sku: 'S0'
    customSubDomainName: azureAccountName
    disableLocalAuth: true
    publicNetworkAccess: 'Enabled'
    deployments: [
      {
        name: azureOpenAiDeployment
        model: {
          format: 'OpenAI'
          name: azureOpenAiModel
          version: azureOpenAiModelVersion
        }
        sku: {
          name: 'Standard'
          capacity: azureOpenAiCapacity
        }
      }
    ]
    roleAssignments: [
      {
        principalId: identity.outputs.principalId
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'Cognitive Services OpenAI User'
      }
    ]
  }
}

var azureEnabled = deployAzureOpenAI || !empty(azureOpenAiEndpoint)
var azureEndpointEffective = deployAzureOpenAI ? '${azureOpenAi!.outputs.endpoint}openai/v1' : azureOpenAiEndpoint

// -------------------------------------------------------------------------------------------------
// Container Apps managed environment
// -------------------------------------------------------------------------------------------------
module environment 'br/public:avm/res/app/managed-environment:0.16.0' = {
  name: 'environment'
  params: {
    name: environmentName
    location: location
    tags: tags
    zoneRedundant: false
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsWorkspaceResourceId: logAnalytics.outputs.resourceId
    }
    managedIdentities: {
      userAssignedResourceIds: [
        identity.outputs.resourceId
      ]
    }
    workloadProfiles: concat(
      [
        {
          name: consumptionProfileName
          workloadProfileType: 'Consumption'
        }
      ],
      deployOllama ? [
        {
          name: gpuProfileName
          workloadProfileType: ollamaWorkloadProfileType
          minimumCount: 0
          maximumCount: 1
        }
      ] : []
    )
    storages: concat(
      [
        {
          kind: 'SMB'
          accessMode: 'ReadWrite'
          shareName: stateShareName
          storageAccountName: storage.outputs.name
        }
      ],
      deployOllama ? [
        {
          kind: 'SMB'
          accessMode: 'ReadWrite'
          shareName: ollamaShareName
          storageAccountName: storage.outputs.name
        }
      ] : []
    )
  }
}

// -------------------------------------------------------------------------------------------------
// Ollama sovereign route (serverless GPU) — internal ingress only
// -------------------------------------------------------------------------------------------------
module ollamaApp 'br/public:avm/res/app/container-app:0.23.0' = if (deployOllama) {
  name: 'ollamaApp'
  params: {
    name: ollamaAppName
    location: location
    tags: tags
    environmentResourceId: environment.outputs.resourceId
    workloadProfileName: gpuProfileName
    activeRevisionsMode: 'Single'
    ingressExternal: false
    ingressTargetPort: 11434
    ingressTransport: 'http'
    ingressAllowInsecure: false
    managedIdentities: {
      userAssignedResourceIds: [
        identity.outputs.resourceId
      ]
    }
    scaleSettings: {
      minReplicas: 0
      maxReplicas: 1
    }
    volumes: [
      {
        name: 'models'
        storageType: 'AzureFile'
        storageName: ollamaShareName
      }
    ]
    containers: [
      {
        name: 'ollama'
        image: ollamaImage
        command: [
          '/bin/sh'
        ]
        args: [
          '-c'
          'ollama serve & until ollama ls >/dev/null 2>&1; do sleep 1; done; ollama pull ${ollamaModel}; wait'
        ]
        resources: {
          cpu: ollamaCpu
          memory: ollamaMemory
        }
        env: [
          {
            name: 'OLLAMA_HOST'
            value: '0.0.0.0:11434'
          }
          {
            name: 'OLLAMA_MODELS'
            value: '/root/.ollama/models'
          }
        ]
        volumeMounts: [
          {
            volumeName: 'models'
            mountPath: '/root/.ollama'
          }
        ]
      }
    ]
  }
}

// -------------------------------------------------------------------------------------------------
// Web application (governance demo)
// -------------------------------------------------------------------------------------------------
var webFqdn = '${webAppName}.${environment.outputs.defaultDomain}'
var ollamaBase = deployOllama ? 'https://${ollamaApp!.outputs.fqdn}/v1' : 'http://127.0.0.1:11434/v1'

var baseEnv = [
  {
    name: 'PDA_ALLOW_REMOTE'
    value: '1'
  }
  {
    name: 'PDA_PROTECTOR'
    value: 'keyvault'
  }
  {
    name: 'AZURE_KEY_VAULT_URI'
    value: keyVault.outputs.uri
  }
  {
    name: 'PDA_KEK_NAME'
    value: kekName
  }
  {
    name: 'AZURE_CLIENT_ID'
    value: identity.outputs.clientId
  }
  {
    name: 'PDA_STATE_DIR'
    value: '/state'
  }
  {
    name: 'PDA_DEPENDENCIES'
    value: '/app'
  }
  {
    name: 'PORT'
    value: '8110'
  }
  {
    name: 'PDA_PUBLIC_SCHEME'
    value: 'https'
  }
  {
    name: 'PDA_ALLOWED_HOSTS'
    value: webFqdn
  }
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: appInsights.outputs.connectionString
  }
  {
    name: 'PDA_OTEL_ENABLED'
    value: enableOpenTelemetry ? '1' : '0'
  }
]

var webEnv = concat(
  baseEnv,
  deployOllama ? [
    {
      name: 'PDA_OLLAMA_BASE'
      value: ollamaBase
    }
  ] : [],
  azureEnabled ? [
    {
      name: 'AZURE_OPENAI_ENDPOINT'
      value: azureEndpointEffective
    }
    {
      name: 'AZURE_OPENAI_DEPLOYMENT'
      value: azureOpenAiDeployment
    }
    {
      name: 'PDA_PUBLIC_ROUTE'
      value: 'azure'
    }
  ] : []
)

module webApp 'br/public:avm/res/app/container-app:0.23.0' = {
  name: 'webApp'
  params: {
    name: webAppName
    location: location
    tags: tags
    environmentResourceId: environment.outputs.resourceId
    workloadProfileName: consumptionProfileName
    activeRevisionsMode: 'Single'
    ingressExternal: true
    ingressTargetPort: 8110
    ingressTransport: 'auto'
    ingressAllowInsecure: false
    managedIdentities: {
      userAssignedResourceIds: [
        identity.outputs.resourceId
      ]
    }
    registries: [
      {
        server: registry.outputs.loginServer
        identity: identity.outputs.resourceId
      }
    ]
    scaleSettings: {
      minReplicas: 1
      maxReplicas: 1
    }
    volumes: [
      {
        name: 'state'
        storageType: 'AzureFile'
        storageName: stateShareName
      }
    ]
    containers: [
      {
        name: 'web'
        image: webImage
        resources: {
          cpu: 1
          memory: '2Gi'
        }
        env: webEnv
        volumeMounts: [
          {
            volumeName: 'state'
            mountPath: '/state'
          }
        ]
        probes: [
          {
            type: 'Liveness'
            httpGet: {
              path: '/healthz'
              port: 8110
            }
            initialDelaySeconds: 10
            periodSeconds: 30
          }
          {
            type: 'Readiness'
            httpGet: {
              path: '/healthz'
              port: 8110
            }
            initialDelaySeconds: 5
            periodSeconds: 10
          }
        ]
      }
    ]
  }
}

// -------------------------------------------------------------------------------------------------
// Outputs
// -------------------------------------------------------------------------------------------------
@description('Public URL of the governance web app.')
output webUrl string = 'https://${webApp.outputs.fqdn}'

@description('Login server of the container registry.')
output acrLoginServer string = registry.outputs.loginServer

@description('Name of the container registry.')
output acrName string = registry.outputs.name

@description('Key Vault URI.')
output keyVaultUri string = keyVault.outputs.uri

@description('Key Vault name.')
output keyVaultName string = keyVault.outputs.name

@description('User-assigned identity client ID used by the app.')
output identityClientId string = identity.outputs.clientId

@description('Name of the web container app.')
output webAppName string = webApp.outputs.name

@description('Storage account name backing state and the compliance archive.')
output storageAccountName string = storage.outputs.name

@description('Azure OpenAI v1 endpoint serving the cloud Public route, if configured.')
output azureOpenAiEndpoint string = azureEnabled ? azureEndpointEffective : ''
