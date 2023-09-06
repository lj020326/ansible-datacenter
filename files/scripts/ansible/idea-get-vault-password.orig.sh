#!/usr/bin/env bash

## ref: https://plugins.jetbrains.com/plugin/14353-ansible-vault-integration/tutorials/vault-file-as-script

# Helper to show error message
__error_message() {
   >&2 echo "$1"
   exit 2
}

# Check script is not called directly
if [ -z "$IDEA_ANSIBLE_VAULT_CONTEXT_DIRECTORY" ]
then
  __error_message "Call is not coming from IntelliJ Plugin"
fi

# Check context folder
case "$IDEA_ANSIBLE_VAULT_CONTEXT_DIRECTORY" in
  # known maturities
  dev|qa|prod)
    secret_file=".${IDEA_ANSIBLE_VAULT_CONTEXT_DIRECTORY}.secret"
    if [ -f "$secret_file" ]
    then
      cat  ".${IDEA_ANSIBLE_VAULT_CONTEXT_DIRECTORY}.secret"
    else
      __error_message "Secret file '${secret_file}' not found"
    fi
    ;;

  # whoops something went wrong
  *)
    __error_message "Unsupported folder"
    exit 2
    ;;
esac
