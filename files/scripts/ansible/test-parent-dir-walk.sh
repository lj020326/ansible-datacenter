#!/usr/bin/env bash

CONTENT_DIR=$(dirname "${PWD}")

IFS="/" read -a CONTENT_DIR_ARRAY <<< "${CONTENT_DIR}"

SECRET_FILE=".vault_pass"

for (( idx=${#CONTENT_DIR_ARRAY[@]}-1 ; idx>=0 ; idx-- )) ; do
  SECRET_PATH="${PWD}/${SECRET_FILE}"
  echo "==> Checking idx=$idx SECRET_PATH=${SECRET_PATH}"
  if [ -f "${SECRET_PATH}" ]; then
    echo "==> Found SECRET_PATH=${SECRET_PATH}"
    SECRET=$(cat "${SECRET_PATH}")
    break
  else
    cd ../
  fi
done

if [ -z "$SECRET" ]; then
  SECRET_PATH="${HOME}/${SECRET_FILE}"
  echo "==> Checking idx=$idx SECRET_PATH=${SECRET_PATH}"
  if [ -f "${SECRET_PATH}" ]; then
    echo "==> Found SECRET_PATH=${SECRET_PATH}"
    SECRET=$(cat "${SECRET_PATH}")
  fi
fi

if [ -n "$SECRET" ]
then
  echo "${SECRET}"
else
#    env_info=$(export -p | grep -i linux_middleware_playbooks | sed 's/declare -x //')
#    env_info=$(export -p | grep -i -e pwd -e idea | sed 's/declare -x //')
#    __error_message "**** env_info: ${env_info}"
    __error_message "Secret file '${SECRET_FILE}' not found"
fi
