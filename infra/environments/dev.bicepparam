using '../main.bicep'

param environmentName = 'dev'
param location = 'centralus'

// AI Foundry instances — one per region needed for model quota.
// Add entries here when models require deployment in different regions.
param foundries = [
  {
    name: 'scholar-dev-foundry-centralus'
    location: 'centralus'
    models: [
      {
        deploymentName: 'claude-haiku-4-5'
        format: 'Anthropic'
        name: 'claude-haiku-4-5'
        version: '20251001'
        skuName: 'GlobalStandard'
        capacity: 10
        enabled: true
      }
    ]
  }
]
