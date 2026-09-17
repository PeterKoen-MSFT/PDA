metadata description = 'Policy Driven Agent single-VM deployment. Provisions a Windows Server VM (Node.js + Ollama + Caddy) reachable over a public HTTPS address, using Azure Verified Modules. The application itself is unchanged and keeps listening on loopback 127.0.0.1:8110; Caddy terminates HTTPS and enforces basic authentication.'

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Prefix used to name every resource. Keep short; the VM computer name is derived from it.')
@minLength(2)
@maxLength(8)
param namePrefix string = 'pda'

@description('VM size. Default has 8 vCPU / 64 GiB RAM and no GPU.')
param vmSize string = 'Standard_E8s_v5'

@description('OS disk size in GB. Must be large enough for Windows, Node.js, Ollama and the pulled model.')
param osDiskSizeGB int = 256

@description('Local administrator username for the VM (used for RDP and to run the demo).')
param adminUsername string

@description('Local administrator password for the VM.')
@secure()
param adminPassword string

@description('DNS name label for the public IP. The full name becomes <dnsLabel>.<location>.cloudapp.azure.com and is used for the HTTPS certificate.')
param dnsLabel string

@description('Source address prefix allowed to reach HTTP/HTTPS/RDP. Use "*" for any, or a CIDR / IP to restrict.')
param allowedSourceAddressPrefix string = '*'

@description('Virtual network address space.')
param addressPrefix string = '10.42.0.0/24'

@description('Subnet address space.')
param subnetPrefix string = '10.42.0.0/25'

@description('SAS URL of the bootstrap.ps1 script, downloaded by the custom script extension.')
@secure()
param bootstrapFileUri string

@description('SAS URL of the application package (app.zip), downloaded by the custom script extension.')
@secure()
param appZipFileUri string

@description('Username required by Caddy basic authentication.')
@secure()
param basicAuthUsername string

@description('Password required by Caddy basic authentication.')
@secure()
param basicAuthPassword string

@description('Ollama model pulled during provisioning and used by the demo.')
param ollamaModel string = 'qwen2.5:7b'

@description('Node.js version installed on the VM (Windows x64 zip).')
param nodeVersion string = '22.12.0'

@description('PowerShell 7 version installed on the VM (used to run startdemo.ps1, matching on-premises).')
param pwshVersion string = '7.4.6'

@description('Tags applied to every resource. Must include the policy-exemption tag.')
param tags object = {
  SecurityControl: 'Ignore'
}

// ---------------------------------------------------------------------------
// Variables
// ---------------------------------------------------------------------------

var publicFqdn = '${dnsLabel}.${location}.cloudapp.azure.com'

// Secrets are base64-encoded so they can travel safely as command-line arguments
// (the extension executes commandToExecute through cmd.exe, where characters such
// as & would otherwise break the line). The values live in protectedSettings,
// which the custom script extension encrypts at rest and in transit.
var bootstrapCommand = 'powershell -ExecutionPolicy Bypass -NoProfile -File bootstrap.ps1 -Fqdn "${publicFqdn}" -BasicAuthUserB64 "${base64(basicAuthUsername)}" -BasicAuthPasswordB64 "${base64(basicAuthPassword)}" -AdminUsername "${adminUsername}" -AdminPasswordB64 "${base64(adminPassword)}" -OllamaModel "${ollamaModel}" -NodeVersion "${nodeVersion}" -PwshVersion "${pwshVersion}"'

// ---------------------------------------------------------------------------
// Network security group: allow inbound HTTPS, HTTP (ACME challenge) and RDP.
// ---------------------------------------------------------------------------

module nsg 'br/public:avm/res/network/network-security-group:0.5.3' = {
  name: 'pda-nsg'
  params: {
    name: '${namePrefix}-nsg'
    location: location
    tags: tags
    securityRules: [
      {
        name: 'Allow-HTTPS-Inbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 100
          protocol: 'Tcp'
          sourceAddressPrefix: allowedSourceAddressPrefix
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
        }
      }
      {
        name: 'Allow-HTTP-Inbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 110
          protocol: 'Tcp'
          sourceAddressPrefix: allowedSourceAddressPrefix
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '80'
        }
      }
      {
        name: 'Allow-RDP-Inbound'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 120
          protocol: 'Tcp'
          sourceAddressPrefix: allowedSourceAddressPrefix
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '3389'
        }
      }
    ]
  }
}

// ---------------------------------------------------------------------------
// Virtual network with a single subnet protected by the NSG.
// ---------------------------------------------------------------------------

module vnet 'br/public:avm/res/network/virtual-network:0.10.2' = {
  name: 'pda-vnet'
  params: {
    name: '${namePrefix}-vnet'
    location: location
    tags: tags
    addressPrefixes: [
      addressPrefix
    ]
    subnets: [
      {
        name: 'app'
        addressPrefix: subnetPrefix
        networkSecurityGroupResourceId: nsg.outputs.resourceId
      }
    ]
  }
}

// ---------------------------------------------------------------------------
// Windows VM with a public IP (DNS label) and the custom script extension
// that installs and starts the whole stack.
// ---------------------------------------------------------------------------

module vm 'br/public:avm/res/compute/virtual-machine:0.22.3' = {
  name: 'pda-vm'
  params: {
    name: '${namePrefix}-vm'
    location: location
    tags: tags
    availabilityZone: -1
    osType: 'Windows'
    vmSize: vmSize
    adminUsername: adminUsername
    adminPassword: adminPassword
    encryptionAtHost: false
    bootDiagnostics: true
    imageReference: {
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2025-datacenter-azure-edition'
      version: 'latest'
    }
    osDisk: {
      name: '${namePrefix}-osdisk'
      createOption: 'FromImage'
      caching: 'ReadWrite'
      diskSizeGB: osDiskSizeGB
      managedDisk: {
        storageAccountType: 'Premium_LRS'
      }
    }
    nicConfigurations: [
      {
        name: '${namePrefix}-nic'
        tags: tags
        ipConfigurations: [
          {
            name: 'ipconfig1'
            subnetResourceId: vnet.outputs.subnetResourceIds[0]
            pipConfiguration: {
              publicIpNameSuffix: '-pip'
              tags: tags
              dnsSettings: {
                domainNameLabel: dnsLabel
              }
            }
          }
        ]
      }
    ]
    extensionCustomScriptConfig: {
      name: 'pda-bootstrap'
      protectedSettings: {
        fileUris: [
          bootstrapFileUri
          appZipFileUri
        ]
        commandToExecute: bootstrapCommand
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------

output vmName string = vm.outputs.name
output publicFqdn string = publicFqdn
output publicUrl string = 'https://${publicFqdn}/'
output rdpAddress string = publicFqdn
