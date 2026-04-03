using '../main.bicep'

param environmentName = 'dev'
param location = 'centralus'

// AI Foundry instances — one per region needed for model quota.
// Add entries here when models require deployment in different regions.
param foundries = [
  /*
  {
    name: 'scholar-dev-foundry-swedencentral'
    location: 'swedencentral'
    models: [
      {
        deploymentName: 'claude-haiku-4-5'
        format: 'Anthropic'
        name: 'claude-haiku-4-5'
        version: '20251001'
        skuName: 'GlobalStandard'
        capacity: 10
        enabled: true
        modelProviderData: {
          industry: 'Technology'
          organizationName: 'Personal'
          countryCode: 'US'
        }
      }
    ]
  }
  */
]
