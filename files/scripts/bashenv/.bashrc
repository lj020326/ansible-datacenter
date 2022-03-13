# To the extent possible under law, the author(s) have dedicated all 
# copyright and related and neighboring rights to this software to the 
# public domain worldwide. This software is distributed without any warranty. 
# You should have received a copy of the CC0 Public Domain Dedication along 
# with this software. 
# If not, see <http://creativecommons.org/publicdomain/zero/1.0/>. 

# ~/.bashrc: executed by bash(1) for interactive shells.

# The copy in your home directory (~/.bashrc) is yours, please
# feel free to customise it to create a shell
# environment to your liking.  If you feel a change
# would be benifitial to all, please feel free to send
# a patch to the msys2 mailing list.

# User dependent .bashrc file

#set -x

# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Source bashlib logger definitions
if [ -f ~/.bashlib/logger.sh ]; then
	## ref: http://www.cubicrace.com/2016/03/log-tracing-mechnism-for-shell-scripts.html
	source ~/.bashlib/logger.sh

#    LOG_SCRIPTENTRY
#    logInfo(){
##        LOG_ENTRY
##        LOG_DEBUG "Username: $1, Key: $2"
#        LOG_INFO "[script: $logPrefix]: msg: $1"
##        LOG_EXIT
#    }
fi

logPrefix=".bashrc"
#logLevel=${LOG_DEBUG}
logLevel=${LOG_INFO}

logDebug "configuring shell env..."

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

logInfo "platform=[${platform}]"

# Functions
load_functions () {

	# Functions
	#
	# Some people use a different file for functions
	if [ -f "${HOME}/.bash_functions" ]; then
		logInfo "setting functions"
		source "${HOME}/.bash_functions"
	fi
}

load_functions

if [ -f "${HOME}/.bash_env" ]; then
    logInfo "sourcing .bash_env"
    . ~/.bash_env
fi

if [ -f "${HOME}/.bash_secrets" ]; then
    logInfo "sourcing .bash_secrets"
    . ~/.bash_secrets
fi

#if [[ "$platform" =~ ^(MSYS|MINGW)$ ]]; then
if [ -f "${HOME}/.bash_prompt" ]; then
    logInfo "setting prompt"
    . ~/.bash_prompt
fi

# Shell Options
#
# See man bash for more options...
#
# Don't wait for job termination notification
# set -o notify
#
# Don't use ^D to exit
# set -o ignoreeof
#
# Use case-insensitive filename globbing
# shopt -s nocaseglob
#
# Make bash append rather than overwrite the history on disk
# shopt -s histappend
shopt -s histappend

#
# When changing directory small typos can be ignored by bash
# for example, cd /vr/lgo/apaache would find /var/log/apache
# shopt -s cdspell

# Completion options
#
# These completion tuning parameters change the default behavior of bash_completion:
#
# Define to access remotely checked-out files over passwordless ssh for CVS
# COMP_CVS_REMOTE=1
#
# Define to avoid stripping description in --option=description of './configure --help'
# COMP_CONFIGURE_HINTS=1
#
# Define to avoid flattening internal contents of tar files
# COMP_TAR_INTERNAL_PATHS=1
#
# Uncomment to turn on programmable completion enhancements.
# Any completions you add in ~/.bash_completion are sourced last.
# [[ -f /etc/bash_completion ]] && . /etc/bash_completion

# History Options
#
# Don't put duplicate lines in the history.
# export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
#
# Ignore some controlling instructions
# HISTIGNORE is a colon-delimited list of patterns which should be excluded.
# The '&' is a special pattern which suppresses duplicate entries.
# export HISTIGNORE=$'[ \t]*:&:[fb]g:exit'
# export HISTIGNORE=$'[ \t]*:&:[fb]g:exit:ls' # Ignore the ls command as well
#
# Whenever displaying the prompt, write the previous line to disk
# export PROMPT_COMMAND="history -a"

# Umask
#
# /etc/profile sets 022, removing write perms to group + others.
# Set a more restrictive umask: i.e. no exec perms for others:
# umask 027
# Paranoid: neither group nor others have any perms:
# umask 077

#logInfo "PATH=$PATH"

# Aliases
load_aliases () {

	if [ -f "${HOME}/.bash_aliases" ]; then
		logInfo "setting aliases"
		source "${HOME}/.bash_aliases"
	fi

    if [ -f "${HOME}/.acme.sh/acme.sh.env" ]; then
        logInfo "setting aliases"
        source "${HOME}/.acme.sh/acme.sh.env"
    fi
}

load_aliases

