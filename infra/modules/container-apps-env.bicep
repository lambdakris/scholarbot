@description('Name of the Container Apps Environment')
param name string

@description('Location for the resource')
param location string

@description('Tags to apply to the resource')
param tags object = {}

@description('Log Analytics workspace ID')
param logAnalyticsWorkspaceId string

resource containerAppsEnv 'Microsoft.App/managedEnvironments@2026-01-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: reference(logAnalyticsWorkspaceId, '2025-07-01').customerId
        sharedKey: listKeys(logAnalyticsWorkspaceId, '2025-07-01').primarySharedKey
      }
    }
  }
}

output id string = containerAppsEnv.id
output name string = containerAppsEnv.name
output defaultDomain string = containerAppsEnv.properties.defaultDomain
