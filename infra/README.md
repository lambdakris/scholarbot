# Infrastructure

Bicep modules for provisioning ScholarBot's Azure dev environment.

## What gets created

| Resource | Module | Purpose |
|----------|--------|---------|
| Log Analytics Workspace | `modules/log-analytics.bicep` | Container Apps logging |
| Container Apps Environment | `modules/container-apps-env.bicep` | Hosting environment for server + portal (apps deployed in Milestone 4) |
| Key Vault | `modules/key-vault.bicep` | Secret storage (RBAC-authorized, soft delete enabled) |
| AI Foundry Account(s) | `modules/ai-foundry.bicep` | LLM hosting — one instance per region to satisfy model quota requirements |

Model deployments are configured per-foundry instance in `environments/dev.bicepparam`. Anthropic model deployment via Bicep is best-effort — if Azure rejects the deployment format, set `enabled: false` on that model entry and deploy it manually through the Azure portal (AI Foundry → Model Catalog).

## Prerequisites

- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed
- `az login` with an account that has Contributor access to the target subscription
- The following resource providers registered on the subscription:
  - `Microsoft.CognitiveServices`
  - `Microsoft.App`
  - `Microsoft.KeyVault`
  - `Microsoft.OperationalInsights`

## Deploy

```bash
# 1. Deploy infrastructure
./scripts/deploy-dev.sh

# 2. Grant your developer account access (one-time)
./scripts/rbac-dev.sh
```

`deploy-dev.sh` creates the resource group `scholar-dev-rg` in `centralus` and deploys all modules. `rbac-dev.sh` grants your Azure AD user the necessary data plane roles at the resource group scope.

Both scripts use the current `az` subscription by default. Override with `SUBSCRIPTION_ID` env var if needed.

## Environments

| File | Environment | Region |
|------|-------------|--------|
| `environments/dev.bicepparam` | dev | centralus |

Add new `.bicepparam` files for additional environments (test, prod). Each can define its own foundry instances, locations, and model configurations.

## RBAC approach

**Developer access** (your user account): Managed via `scripts/rbac-dev.sh`. Roles are assigned at the resource group scope so they automatically cover new resources without script changes.

**Service-to-service access** (managed identities): Created in the consuming service's Bicep — e.g., `container-app.bicep` (Milestone 4) will grant the Container App's identity access to Key Vault and AI Foundry. This avoids requiring managed identity IDs at infrastructure provisioning time.

**Services with non-standard auth** (e.g., PostgreSQL): Handled via service-specific commands in the dedicated section of `rbac-dev.sh`.

## Structure

```
infra/
├── main.bicep                    # Orchestrator — wires all modules together
├── modules/
│   ├── log-analytics.bicep
│   ├── container-apps-env.bicep
│   ├── key-vault.bicep
│   └── ai-foundry.bicep          # Supports multiple model deployments via models array
└── environments/
    └── dev.bicepparam             # Dev environment parameters
```
