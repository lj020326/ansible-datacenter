
#set -x

# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

log_bash=".bashrc"
echo "${log_bash} configuring shell env..."

#unameOut="$(/bin/uname -s)"
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     platform=Linux;;
    Darwin*)    platform=DARWIN;;
    CYGWIN*)    platform=CYGWIN;;
    MINGW64*)   platform=MINGW64;;
    MINGW32*)   platform=MINGW32;;
    MSYS*)      platform=MSYS;;
    *)          platform="UNKNOWN:${unameOut}"
esac

echo "platform=[${platform}]"

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

if [ -f "${HOME}/.bash_functions" ]; then
    echo "setting functions"
    source "${HOME}/.bash_functions"
fi

if [ -f "${HOME}/.bash_env" ]; then
    echo "${log_bash} sourcing .bash_env"
    . ~/.bash_env
fi

if [ -f "${HOME}/.bash_secrets" ]; then
    echo "${log_bash} sourcing .bash_secrets"
    . ~/.bash_secrets
fi

#if [[ "$platform" =~ ^(MSYS|MINGW)$ ]]; then
if [ -f "${HOME}/.bash_prompt" ]; then
    echo "${log_bash} setting prompt"
    . ~/.bash_prompt
fi

if [ -f "${HOME}/.bash_aliases" ]; then
    echo "${log_prefix} setting aliases"
    source "${HOME}/.bash_aliases"
fi

#export ANSIBLE_ROLES_PATH=/etc/ansible/roles:~/.ansible/roles
#export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

if [ -d "${HOME}/.local/bin" ]; then
    export PATH+=":${HOME}/.local/bin"
fi
