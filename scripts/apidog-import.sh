#!/usr/bin/env bash
set -euo pipefail

: "${APIDOG_TOKEN:?Defina APIDOG_TOKEN}"
: "${APIDOG_PROJECT_ID:?Defina APIDOG_PROJECT_ID}"
: "${OPENAPI_URL:?Defina OPENAPI_URL}"

APIDOG_API_BASE="${APIDOG_API_BASE:-https://api.apidog.com}"
APIDOG_API_VERSION="${APIDOG_API_VERSION:-2024-03-28}"
APIDOG_LOCALE="${APIDOG_LOCALE:-en-US}"

cat > /tmp/apidog-payload.json <<EOF
{
  "input": {
    "url": "${OPENAPI_URL}"
  },
  "options": {
    "targetEndpointFolderId": 0,
    "targetSchemaFolderId": 0,
    "endpointOverwriteBehavior": "OVERWRITE_EXISTING",
    "schemaOverwriteBehavior": "OVERWRITE_EXISTING",
    "updateFolderOfChangedEndpoint": false,
    "prependBasePath": false
  }
}
EOF

echo "Importando spec para o Apidog..."
echo "Project ID: ${APIDOG_PROJECT_ID}"
echo "Spec URL: ${OPENAPI_URL}"
echo

HTTP_CODE=$(
  curl --silent --show-error \
    --output /tmp/apidog-response.json \
    --write-out "%{http_code}" \
    --request POST \
    "${APIDOG_API_BASE}/v1/projects/${APIDOG_PROJECT_ID}/import-openapi?locale=${APIDOG_LOCALE}" \
    --header "X-Apidog-Api-Version: ${APIDOG_API_VERSION}" \
    --header "Authorization: Bearer ${APIDOG_TOKEN}" \
    --header "Content-Type: application/json" \
    --data @/tmp/apidog-payload.json
)

echo "HTTP ${HTTP_CODE}"
echo "Resposta:"
cat /tmp/apidog-response.json
echo

if [ "${HTTP_CODE}" != "200" ]; then
  exit 1
fi