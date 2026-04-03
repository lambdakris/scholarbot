@description('Name of the AI Foundry account')
param name string

@description('Location for the resource')
param location string

@description('Tags to apply to the resource')
param tags object = {}

@description('Name of the AI Foundry project')
param projectName string = '${name}-proj'

@description('''
Array of model deployments. Each entry:
  {
    deploymentName: string   // name used by the app (e.g. "claude-haiku-4-5")
    format: string           // "Anthropic" | "OpenAI"
    name: string             // model catalog name
    version: string          // model version
    skuName: string          // e.g. "GlobalStandard", "Standard" — may differ by provider
    capacity: int            // TPM in thousands
    enabled: bool            // set false to skip (e.g. if format unsupported in Bicep)
    modelProviderData: object? // required for Anthropic: { industry, organizationName, countryCode }
  }
''')
param models array = []

// Note on RBAC: service-to-service role assignments (e.g. Container App managed identity
// → Cognitive Services User) are created in the consuming service's Bicep (container-app.bicep),
// not here. Developer access is handled via scripts/rbac-dev.sh.

// AI Foundry account (kind: AIServices supports both OpenAI and Anthropic models)
resource aiFoundry 'Microsoft.CognitiveServices/accounts@2026-01-15-preview' = {
  name: name
  location: location
  tags: tags
  kind: 'AIServices'
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'S0'
  }
  properties: {
    allowProjectManagement: true
    customSubDomainName: name
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
}

// AI Foundry project
resource aiProject 'Microsoft.CognitiveServices/accounts/projects@2026-01-15-preview' = {
  parent: aiFoundry
  name: projectName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {}
}

// Model deployments — looped over the models array, serialized to avoid conflicts.
// Anthropic format is best-effort: if Azure rejects a deployment, set enabled=false
// and deploy that model manually via the Azure portal (AI Foundry → Model Catalog).
@batchSize(1)
resource modelDeployments 'Microsoft.CognitiveServices/accounts/deployments@2026-01-15-preview' = [for model in models: if (model.enabled) {
  parent: aiFoundry
  name: model.deploymentName
  sku: {
    name: model.skuName
    capacity: model.capacity
  }
  properties: {
    model: {
      format: model.format
      name: model.name
      version: model.version
    }
    modelProviderData: contains(model, 'modelProviderData') ? model.modelProviderData : null
  }
}]

output name string = aiFoundry.name
output principalId string = aiFoundry.identity.principalId
output endpoint string = aiFoundry.properties.endpoints['AI Foundry API']
output projectName string = aiProject.name
