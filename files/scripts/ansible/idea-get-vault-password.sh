#!/usr/bin/env bash

## ref: https://plugins.jetbrains.com/plugin/14353-ansible-vault-integration/tutorials/vault-file-as-script

# Helper to show error message
__error_message() {
   >&2 echo "$1"
   exit 2
}

## no-op when not debugging
__info_message() {
#   >&2 echo "$1"
  true
}

#env_info=$(export -p | grep -i -e linux | sed 's/declare -x //')
#__info_message "**** env_info: ${env_info}"

# Check script is not called directly
if [ -z "$IDEA_ANSIBLE_VAULT_CONTEXT_DIRECTORY" ]
then
  __error_message "Call is not coming from IntelliJ Plugin"
fi

CONTENT_DIR=$(dirname "${IDEA_ANSIBLE_VAULT_CONTEXT_FILE}")
__info_message "==> CONTENT_DIR=${CONTENT_DIR}"
cd "${CONTENT_DIR}"

IFS="/" read -a CONTENT_DIR_ARRAY <<< "${CONTENT_DIR}"

SECRET_FILE=".vault_pass"

for (( idx=${#CONTENT_DIR_ARRAY[@]}-1 ; idx>=0 ; idx-- )) ; do
  SECRET_PATH="${PWD}/${SECRET_FILE}"
  __info_message "==> Checking idx=$idx SECRET_PATH=${SECRET_PATH}"
  if [ -f "${SECRET_PATH}" ]; then
    __info_message "==> Found SECRET_PATH=${SECRET_PATH}"
    SECRET=$(cat "${SECRET_PATH}")
    break
  else
    cd ../
  fi
done

if [ -z "$SECRET" ]; then
  SECRET_PATH="${HOME}/${SECRET_FILE}"
  __info_message "==> Checking idx=$idx SECRET_PATH=${SECRET_PATH}"
  if [ -f "${SECRET_PATH}" ]; then
    __info_message "==> Found SECRET_PATH=${SECRET_PATH}"
    SECRET=$(cat "${SECRET_PATH}")
  fi
fi

if [ -n "$SECRET" ]
then
  __info_message "==> SECRET_PATH=${SECRET_PATH}"
##  __info_message "==> SECRET=${SECRET}"
#  echo -n "${SECRET}"
#  echo "${SECRET_PATH}"
  cat "${SECRET_PATH}"
else
    __error_message "Secret file '${SECRET_FILE}' not found"
fi
