targetScope = 'subscription'

param location string
param resourceGroupName string
param acrName string

resource group 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
}

module registry 'br/public:avm/res/container-registry/registry:0.13.0' = {
  name: 'pda-registry-bootstrap'
  scope: group
  params: {
    name: acrName
    location: location
    acrSku: 'Standard'
    acrAdminUserEnabled: false
    tags: { workload: 'pda-governance-demo', managedBy: 'bicep-avm' }
  }
}
