#!/usr/bin/env bash
set -euo pipefail

IDENTITY_NAME="cubix-metaservices-github-terraform"
SUBSCRIPTION_ID="d4d35aad-20e7-4b76-bbb0-944c0f092cc4"
TENANT_ID="8820d9af-b533-4848-9bf3-ebf24d29d140"
LOCATION="westeurope"
IDENTITY_RESOURCE_GROUP_NAME="cubix-meta-services"
STATE_RESOURCE_GROUP_NAME="cubix-meta-services"
STATE_STORAGE_ACCOUNT_NAME="cubixmetastore"
DNS_RESOURCE_GROUP_NAME="cubix-meta-services"

require_command() {
  local command_name="$1"

  if ! command -v "${command_name}" >/dev/null 2>&1; then
    echo "Missing required command: ${command_name}" >&2
    exit 1
  fi
}

require_command az
require_command gh

if ! gh auth status >/dev/null 2>&1; then
  echo "GitHub CLI is not authenticated. Run: gh auth login" >&2
  exit 1
fi

GITHUB_REPOSITORY=$(gh repo view --json nameWithOwner --jq .nameWithOwner)

if [ -z "${GITHUB_REPOSITORY}" ]; then
  echo "Could not determine GitHub repository from the current directory." >&2
  exit 1
fi

az account set --subscription "${SUBSCRIPTION_ID}"

az group create \
  --name "${IDENTITY_RESOURCE_GROUP_NAME}" \
  --location "${LOCATION}" \
  --tags work="Cubix Platform Engineer course" \
  --output none

if ! az identity show \
  --name "${IDENTITY_NAME}" \
  --resource-group "${IDENTITY_RESOURCE_GROUP_NAME}" \
  --output none 2>/dev/null; then
  az identity create \
    --name "${IDENTITY_NAME}" \
    --resource-group "${IDENTITY_RESOURCE_GROUP_NAME}" \
    --location "${LOCATION}" \
    --tags work="Cubix Platform Engineer course" \
    --output none
fi

CLIENT_ID=$(az identity show \
  --name "${IDENTITY_NAME}" \
  --resource-group "${IDENTITY_RESOURCE_GROUP_NAME}" \
  --query clientId \
  --output tsv)

PRINCIPAL_ID=$(az identity show \
  --name "${IDENTITY_NAME}" \
  --resource-group "${IDENTITY_RESOURCE_GROUP_NAME}" \
  --query principalId \
  --output tsv)

create_federated_credential() {
  local name="$1"
  local subject="$2"

  if az identity federated-credential show \
    --name "${name}" \
    --identity-name "${IDENTITY_NAME}" \
    --resource-group "${IDENTITY_RESOURCE_GROUP_NAME}" \
    --output none 2>/dev/null; then
    return
  fi

  az identity federated-credential create \
    --name "${name}" \
    --identity-name "${IDENTITY_NAME}" \
    --resource-group "${IDENTITY_RESOURCE_GROUP_NAME}" \
    --issuer "https://token.actions.githubusercontent.com" \
    --subject "${subject}" \
    --audiences "api://AzureADTokenExchange" \
    --output none
}

create_role_assignment() {
  local role="$1"
  local scope="$2"

  if az role assignment list \
    --assignee "${PRINCIPAL_ID}" \
    --role "${role}" \
    --scope "${scope}" \
    --query "[0].id" \
    --output tsv | grep -q .; then
    return
  fi

  az role assignment create \
    --assignee-object-id "${PRINCIPAL_ID}" \
    --assignee-principal-type ServicePrincipal \
    --role "${role}" \
    --scope "${scope}" \
    --output none
}

create_federated_credential \
  "github-main" \
  "repo:${GITHUB_REPOSITORY}:ref:refs/heads/main"

create_federated_credential \
  "github-pull-request" \
  "repo:${GITHUB_REPOSITORY}:pull_request"

SUBSCRIPTION_SCOPE="/subscriptions/${SUBSCRIPTION_ID}"
STATE_STORAGE_SCOPE="${SUBSCRIPTION_SCOPE}/resourceGroups/${STATE_RESOURCE_GROUP_NAME}/providers/Microsoft.Storage/storageAccounts/${STATE_STORAGE_ACCOUNT_NAME}"
DNS_RESOURCE_GROUP_SCOPE="${SUBSCRIPTION_SCOPE}/resourceGroups/${DNS_RESOURCE_GROUP_NAME}"

create_role_assignment "Contributor" "${DNS_RESOURCE_GROUP_SCOPE}"
create_role_assignment "Storage Blob Data Contributor" "${STATE_STORAGE_SCOPE}"
create_role_assignment "DNS Zone Contributor" "${DNS_RESOURCE_GROUP_SCOPE}"

gh secret set AZURE_CLIENT_ID --body "${CLIENT_ID}"

cat <<EOF
Created/updated GitHub Actions workload identity federation for ${GITHUB_REPOSITORY}.

Managed identity:
${IDENTITY_NAME}

GitHub Actions secret set:
AZURE_CLIENT_ID=${CLIENT_ID}

Tenant ID:
${TENANT_ID}

Subscription ID:
${SUBSCRIPTION_ID}
EOF
