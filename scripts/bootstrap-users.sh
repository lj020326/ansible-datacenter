#!/usr/bin/env bash

VERSION="2025.6.12"

SCRIPT_NAME="$(basename "$0")"

ANSIBLE_PLAYBOOK="run-playbook.sh"
PATH="${PATH}:."

usage() {
#    reset
    echo "" 1>&2
    echo "Usage: ${SCRIPT_NAME} NODE_NAME" 1>&2
    echo "     NODE_NAME: name of the node to bootstrap the setup for the users and user env" 1>&2
    echo "" 1>&2
    echo "  Examples:" 1>&2
    echo "     ${SCRIPT_NAME} node01" 1>&2
    echo "     ${SCRIPT_NAME} all" 1>&2
    echo "" 1>&2
    exit ${1}
}

if [[ ! $(type -P ${ANSIBLE_PLAYBOOK}) ]] ; then
    echo "${ANSIBLE_PLAYBOOK} must be in PATH"
    echo "${ANSIBLE_PLAYBOOK} not found in PATH=[${PATH}]"
    exit 1
fi

while getopts "hx" opt; do
    case "${opt}" in
        h) usage 1 ;;
        x) debug_container=1 ;;
        \?) usage 2 ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            usage 3
            ;;
        *)
            usage 4
            ;;
    esac
done


if [ $# -lt 1 ]; then
    echo "required NODE_NAME not specified" >&2
    usage 5
fi

NODE_NAME=$1

ask_pass_opts="--ask-pass --ask-become-pass"
ansible_extra_vars=""

## ref: https://stackoverflow.com/questions/37004686/how-to-pass-a-user-password-in-ansible-command
if [[ ! -z ${ANSIBLE_SSH_PASSWORD} ]] ; then
  ansible_extra_vars=" --extra-vars ansible_password=${ANSIBLE_SSH_PASSWORD}"
  ask_pass_opts=""
fi

if [[ ! -z ${ANSIBLE_BECOME_PASSWORD} ]] ; then
  ansible_extra_vars=" --extra-vars ansible_become_password=${ANSIBLE_BECOME_PASSWORD}"
  ask_pass_opts=""
fi

#DEBUG_VERBOSITY="-v"
DEBUG_VERBOSITY="-vvvv"
ANSIBLE_COMMAND="${ANSIBLE_PLAYBOOK} ${DEBUG_VERBOSITY} site.yml --tags bootstrap-user ${ask_pass_opts} ${ansible_extra_vars}"

case "${NODE_NAME}" in
    "all")
        ${ANSIBLE_COMMAND}
        ;;
    *)
        ${ANSIBLE_COMMAND} --limit "${NODE_NAME}"
        ;;
esac
