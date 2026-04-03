@description('Name of the Key Vault')
param name string

@description('Location for the resource')
param location string

@description('Tags to apply to the resource')
param tags object = {}

// Note on RBAC: service-to-service role assignments (e.g. Container App managed identity
// → Key Vault Secrets User) are created in the consuming service's Bicep (container-app.bicep),
// not here. This avoids the chicken-and-egg problem of needing managed identity IDs before
// the consuming service exists. Developer access is handled via scripts/rbac-dev.sh.

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
  }
}

output id string = keyVault.id
output name string = keyVault.name
output uri string = keyVault.properties.vaultUri
