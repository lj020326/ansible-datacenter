
#set -x

# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

# # Source bashlib logger definitions
# if [ -f ~/.bashlib/logger.sh ]; then
# 	## ref: http://www.cubicrace.com/2016/03/log-tracing-mechnism-for-shell-scripts.html
# 	source ~/.bashlib/logger.sh
#
# #    LOG_SCRIPTENTRY
# #    logInfo(){
# ##        LOG_ENTRY
# ##        LOG_DEBUG "Username: $1, Key: $2"
# #        LOG_INFO "[script: $logPrefix]: msg: $1"
# ##        LOG_EXIT
# #    }
# fi
#
# logPrefix=".bashrc"
# #logLevel=${LOG_DEBUG}
# logLevel=${LOG_INFO}
#
# logDebug "configuring shell env..."

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

# if [ -f "${HOME}/.acme.sh/acme.sh.env" ]; then
#     echo "${log_bash} setting aliases"
#     source "${HOME}/.acme.sh/acme.sh.env"
# fi

if [[ "${platform}" == *"DARWIN"* ]]; then
    # default to Java 11
#     java11
    java8
    sshsetupkeyaliases
fi
