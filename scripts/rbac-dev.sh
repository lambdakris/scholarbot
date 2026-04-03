#!/bin/bash
# Grant your developer account data plane access to all ScholarBot dev resources.
# Run once after deploy-dev.sh. Uses resource-group-scoped assignments so this
# script stays in sync automatically as resources are added or removed.
set -e

SUBSCRIPTION_ID="$(az account show --query id --output tsv)"
RESOURCE_GROUP="scholar-dev-rg"
SCOPE="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP"
ASSIGNEE=$(az ad signed-in-user show --query id --output tsv)

echo "Using subscription: $SUBSCRIPTION_ID"
echo "Granting roles on $RESOURCE_GROUP..."

grant() { az role assignment create --scope "$SCOPE" --assignee "$ASSIGNEE" --role "$1" --output none; }

grant "Cognitive Services User"
grant "Key Vault Secrets User"
# grant "Search Index Data Contributor"       # uncomment when AI Search is added
# grant "Cosmos DB Built-in Data Contributor" # uncomment when CosmosDB is added

echo "Done."
