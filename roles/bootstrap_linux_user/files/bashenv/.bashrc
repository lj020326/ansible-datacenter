# shellcheck shell=bash

log_bash=".bashrc:"

# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

if [ -t 1 ]; then
    IS_TTY=1
else
    IS_TTY=0
fi

echo "IS_TTY=$IS_TTY"

# Only print logs if running in a real TTY to keep background output clean
[[ $IS_TTY -eq 1 ]] && echo "${log_bash} configuring shell env..."

function isInstalled() {
    command -v "${1}" >/dev/null 2>&1 || return 1
}

# Source global definitions
if [ -f /etc/bashrc ]; then
    [[ $IS_TTY -eq 1 ]] && echo "${log_bash} loading global shell env..."
    # shellcheck source=/dev/null
    source /etc/bashrc
fi

# Always source environment variables (needed by IntelliJ)
if [ -f "${HOME}/.bash_env" ]; then
    [[ $IS_TTY -eq 1 ]] && echo "${log_bash} sourcing .bash_env"
    # shellcheck source=/dev/null
    source "${HOME}/.bash_env"
fi

if [ -f "${HOME}/.bash_functions" ]; then
    [[ $IS_TTY -eq 1 ]] && echo "${log_bash} setting functions"
    # shellcheck source=/dev/null
    source "${HOME}/.bash_functions"
fi

if [ -f "${HOME}/.bash_aliases" ]; then
    echo "${log_bash} setting aliases"
    # shellcheck source=/dev/null
    source "${HOME}/.bash_aliases"
fi

# # 1. Check if running inside a real TTY (Interactive Terminal)
# # If running non-interactively OR without a real TTY device, exit early.
# # This prevents IntelliJ/background tools from running heavy interactive setups.
# if [[ "$-" != *i* ]] || [ ! -t 1 ]; then
#     echo "${log_bash} non-interactive or without a real TTY device, exiting early"
#     return 0
# fi

# ALWAYS GUARD INTERACTIVE-ONLY COMPONENTS BEHIND IS_TTY
if [[ $IS_TTY -eq 1 ]]; then
    if [ -f "${HOME}/.bash_prompt" ]; then
        # shellcheck source=/dev/null
        source "${HOME}/.bash_prompt"
    fi

    if [ -f "${HOME}/.bash_secrets" ]; then
        if [ -f "${HOME}/.vault_pass" ] && isInstalled ansible-vault; then
            echo "${log_bash} sourcing ~/.bash_secrets"
            eval "$(ansible-vault view "${HOME}/.bash_secrets" --vault-password-file "${HOME}/.vault_pass" 2>/dev/null)"
        fi
    fi
fi
