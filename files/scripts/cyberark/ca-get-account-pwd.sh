#!/usr/bin/env bash

set -e
set -x

CYBERARK_API_BASE_URL=${1:-https://cyberark.example.int}
CA_USERNAME=${2:-casvcacct}
CA_PASSWORD=${3:-password}
CA_ACCOUNT_USERNAME=${4:ca_account_username}

CA_API_TOKEN=$(curl -s --location --request POST ${CYBERARK_API_BASE_URL}/PasswordVault/API/auth/LDAP/Logon \
--header 'Content-Type: application/json' \
--data-raw '{
	"username": "'"${CA_USERNAME}"'",
	"password": "'"${CA_PASSWORD}"'",
    "concurrentSession": true
}' | tr -d '"')

echo "CA_API_TOKEN=${CA_API_TOKEN}"

CA_ACCOUNT_ID=$(curl -s --location --request GET ${CYBERARK_API_BASE_URL}/PasswordVault/api/Accounts?search=${CA_ACCOUNT_USERNAME} \
--header "Content-Length: 0" \
--header 'Authorization: '${CA_API_TOKEN} | jq '.value[0].id' | tr -d '"')

echo "CA_ACCOUNT_ID=${CA_ACCOUNT_ID}"

## ref: https://stackoverflow.com/questions/72311554/how-to-use-bash-command-line-to-curl-an-api-with-token-and-payload-as-parameters
CA_ACCOUNT_PWD=$(curl -s --location --request POST ${CYBERARK_API_BASE_URL}/PasswordVault/api/accounts/${CA_ACCOUNT_ID}/password/retrieve \
--header "Content-Length: 0" \
--header 'Authorization: '${CA_API_TOKEN})

echo "CA_ACCOUNT_PWD=${CA_ACCOUNT_PWD}"
