
#set -x

# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

log_bash=".bashrc"
echo "${log_bash} configuring shell env..."

PLATFORM_OS=$(uname -s | tr "[:upper:]" "[:lower:]")

case "${PLATFORM_OS}" in
    linux*)     PLATFORM=LINUX;;
    darwin*)    PLATFORM=DARWIN;;
    cygwin*)    PLATFORM=CYGWIN;;
    mingw64*)   PLATFORM=MINGW64;;
    mingw32*)   PLATFORM=MINGW32;;
    msys*)      PLATFORM=MSYS;;
    *)          PLATFORM="UNKNOWN:${PLATFORM_OS}"
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

if [ -f "${HOME}/.bash_env" ]; then
    echo "${log_bash} sourcing .bash_env"
    source ~/.bash_env
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

#if [[ "$PLATFORM" =~ ^(MSYS|MINGW)$ ]]; then
if [ -f "${HOME}/.bash_prompt" ]; then
    echo "${log_bash} setting prompt"
    source ~/.bash_prompt
fi

if [ -f "${HOME}/.bash_aliases" ]; then
    echo "${log_prefix} setting aliases"
    source "${HOME}/.bash_aliases"
fi

if [[ "${USER}" == *"ansible"* ]]; then
    ANSIBLE_VENV_DIR="{{ ansible_virtualenv }}"
    ANSIBLE_VENV_BINDIR="${ANSIBLE_VENV_DIR}/bin"
    if [ -f "${ANSIBLE_VENV_BINDIR}/activate" ]; then
        echo "${log_bash} sourcing ${ANSIBLE_VENV_BINDIR}/activate"
        source "${ANSIBLE_VENV_BINDIR}/activate"
    fi
fi
