
#set -x

# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

log_bash=".bashrc"
echo "${log_bash} configuring shell env..."

#OS="$(/bin/uname -s)"
OS="$(uname -s)"
case "${OS}" in
    Linux*)     PLATFORM=Linux;;
    Darwin*)    PLATFORM=DARWIN;;
    CYGWIN*)    PLATFORM=CYGWIN;;
    MINGW64*)   PLATFORM=MINGW64;;
    MINGW32*)   PLATFORM=MINGW32;;
    MSYS*)      PLATFORM=MSYS;;
    *)          PLATFORM="UNKNOWN:${OS}"
esac

echo "${log_bash} PLATFORM=[${PLATFORM}]"

function isInstalled() {
    command -v "${1}" >/dev/null 2>&1 || return 1
}

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

if [ -f "${HOME}/.bash_functions" ]; then
    echo "${log_bash} setting functions"
    source "${HOME}/.bash_functions"
fi

if [ -f "${HOME}/.bash_secrets" ]; then
    if [ ! -f "${HOME}/.vault_pass" ]; then
        echo "${log_bash} ~/.vault_pass not found, skip loading ${HOME}/.bash_secrets"
    elif ! isInstalled ansible-vault; then
        echo "${log_bash} ansible-vault not installed, skip loading ${HOME}/.bash_secrets"
    else
        echo "${log_bash} sourcing ~/.bash_secrets"
        eval "$(ansible-vault view ${HOME}/.bash_secrets --vault-password-file ${HOME}/.vault_pass)"
    fi
fi

if [ -f "${HOME}/.bash_env" ]; then
    echo "${log_bash} sourcing .bash_env"
    source ~/.bash_env
fi

if [ -f "${HOME}/.bash_path" ]; then
    echo "${log_bash} sourcing .bash_path"
    source ~/.bash_path
fi

#if [[ "$PLATFORM" =~ ^(MSYS|MINGW)$ ]]; then
if [ -f "${HOME}/.bash_prompt" ]; then
    echo "${log_bash} setting prompt"
    source ~/.bash_prompt
fi

if [ -f "${HOME}/.bash_aliases" ]; then
    echo "${log_prefix} setting aliases"
    source "${HOME}/.bash_aliases"
fi

