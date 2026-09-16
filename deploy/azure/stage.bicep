metadata description = 'Staging storage account used to hand the bootstrap script and application package to the VM custom script extension. Deployed before the VM so the blobs exist when the extension runs.'

@description('Location for the staging storage account.')
param location string = resourceGroup().location

@description('Globally unique storage account name (3-24 lowercase alphanumeric).')
@minLength(3)
@maxLength(24)
param storageAccountName string

@description('Blob container that holds the bootstrap script and application package.')
param containerName string = 'stage'

@description('Tags applied to every resource. Must include the policy-exemption tag.')
param tags object = {
  SecurityControl: 'Ignore'
}

// The subscription enforces a policy that disables shared-key and public network
// access on storage unless the resource carries SecurityControl: Ignore. The tag
// (flowed through the module) keeps SAS-based upload/download working.
module storageAccount 'br/public:avm/res/storage/storage-account:0.33.0' = {
  name: 'pda-stage-storage'
  params: {
    name: storageAccountName
    location: location
    skuName: 'Standard_LRS'
    kind: 'StorageV2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
    blobServices: {
      containers: [
        {
          name: containerName
          publicAccess: 'None'
        }
      ]
    }
    tags: tags
  }
}

output storageAccountName string = storageAccount.outputs.name
output containerName string = containerName
