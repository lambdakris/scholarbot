@description('Environment name')
param environmentName string = 'dev'

@description('Location for all resources')
param location string = resourceGroup().location

@description('''
AI Foundry instances — one per region needed for model quota. Each entry:
  {
    name: string             // globally unique resource name
    location: string         // Azure region (may differ from main location for quota reasons)
    models: array            // model deployments (see ai-foundry.bicep for schema)
  }
''')
param foundries array = []

// Naming convention
var prefix = 'scholar-${environmentName}'
var tags = {
  environment: environmentName
  application: 'scholarbot'
}

// Log Analytics Workspace
module logAnalytics 'modules/log-analytics.bicep' = {
  name: 'log-analytics'
  params: {
    name: '${prefix}-logs'
    location: location
    tags: tags
  }
}

// Container Apps Environment
module containerAppsEnv 'modules/container-apps-env.bicep' = {
  name: 'container-apps-env'
  params: {
    name: '${prefix}-cae'
    location: location
    tags: tags
    logAnalyticsWorkspaceId: logAnalytics.outputs.id
  }
}

// Key Vault
module keyVault 'modules/key-vault.bicep' = {
  name: 'key-vault'
  params: {
    name: '${prefix}-kv'
    location: location
    tags: tags
  }
}

// AI Foundry — one instance per region to satisfy model quota requirements
module aiFoundries 'modules/ai-foundry.bicep' = [for foundry in foundries: {
  name: 'ai-foundry-${foundry.name}'
  params: {
    name: foundry.name
    location: foundry.location
    tags: tags
    models: foundry.models
  }
}]

// Outputs — consumed by deploy scripts and referenced in Milestone 4 container app deployment
output containerAppsEnvId string = containerAppsEnv.outputs.id
output containerAppsEnvName string = containerAppsEnv.outputs.name
output keyVaultName string = keyVault.outputs.name
output keyVaultUri string = keyVault.outputs.uri
output aiFoundryNames array = [for (foundry, i) in foundries: aiFoundries[i].outputs.name]
output aiFoundryEndpoints array = [for (foundry, i) in foundries: aiFoundries[i].outputs.endpoint]
