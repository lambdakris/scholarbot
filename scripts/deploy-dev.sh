#!/bin/bash
# Deploy ScholarBot dev infrastructure.
# Prerequisites: az login, correct subscription active (or set SUBSCRIPTION_ID env var).
set -e

SUBSCRIPTION_ID="$(az account show --query id --output tsv)"
echo "Using subscription: $SUBSCRIPTION_ID"
az account set --subscription "$SUBSCRIPTION_ID"

DEPLOYMENT_NAME="scholar-dev"
RESOURCE_GROUP="scholar-dev-rg"
LOCATION="centralus"
echo "Creating resource group '$RESOURCE_GROUP' if it doesn't exist..."
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none

echo "Deploying infrastructure..."
az deployment group create \
  --name "$DEPLOYMENT_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --template-file "$(dirname "$0")/../infra/main.bicep" \
  --parameters "$(dirname "$0")/../infra/environments/dev.bicepparam" \
  --query properties.outputs \
  --output table
