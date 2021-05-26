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

unameOut="$(/bin/uname -s)"
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

## ref: https://gist.github.com/vby/ef4d72e6ae51c64acbe7790ca7d89606#file-msys2-bashrc-sh
function add_winpath() {
    paths=''
    __IFS=$IFS
    IFS=';'
    for path in `cat $1/Path`; do
        paths="$paths:`cygpath -u $path`"
    done
    IFS=$__IFS
    export PATH="$PATH:$paths"
}

#ANSIBLE_DC_REPO="~/repos/ansible/ansible-datacenter"
ANSIBLE_DC_REPO="${HOME}/repos/ansible/ansible-datacenter"

if [[ -d "${HOME}/repos/pyutils" ]]; then
    PYUTILS_DIR="${HOME}/repos/pyutils"
elif [[ -d "${HOME}/repos/python/pyutils" ]]; then
    PYUTILS_DIR="${HOME}/repos/python/pyutils"
elif [[ -d "/opt/pyutils" ]]; then
    PYUTILS_DIR="/opt/pyutils"
fi

logDebug "PYUTILS_DIR=[${PYUTILS_DIR}]"

export LANG='en_US.utf-8'

if [ -f "${HOME}/.bash_env" ]; then
    logInfo "sourcing .bash_env"
    . ~/.bash_env
fi

## ref: https://www.jeffgeerling.com/blog/running-ansible-within-windows
#ANSIBLE=/opt/ansible
#export PATH=$PATH:$ANSIBLE/bin
#export PYTHONPATH=$ANSIBLE/lib
#export ANSIBLE_LIBRARY=$ANSIBLE/library

if [[ "$platform" =~ ^(MSYS|MINGW64|MINGW32)$ ]]; then

    logInfo "setting env for MSYS/MINGW platform"
#    export CMAKE_C_COMPILER=/c/apps/msys64/mingw64/bin/gcc
#    export CMAKE_CXX_COMPILER=/c/apps/msys64/mingw64/bin/g++
#    export CC=/c/apps/msys64/mingw64/bin/gcc
#    export CXX=/c/apps/msys64/mingw64/bin/g++
    export CMAKE_C_COMPILER=/usr/bin/gcc
    export CMAKE_CXX_COMPILER=/usr/bin/g++

	## always use /usr/bin unless explicitly overridden in shell
#	if [[ "$platform" =~ ^(MINGW64)$ ]]; then
#		export CMAKE_C_COMPILER=/mingw64/bin/gcc
#		export CMAKE_CXX_COMPILER=/mingw64/bin/g++
#	fi
    export CC=${CMAKE_C_COMPILER}
    export CXX=${CMAKE_CXX_COMPILER}

    #export VSCOMMONTOOLS="/c/Program Files (x86)/Microsoft Visual C++ Build Tools"
    #export VSCOMMONTOOLS=`echo "/$VSCOMMONTOOLS" | sed -e 's/\\/\//g' -e 's/://'`
    export VSCOMMONTOOLS_MSYS=$(echo "/$VSCOMMONTOOLS" | sed -e 's/\\/\//g' -e 's/://')

    export PYTHON2_HOME=/usr/bin
    export PYTHON2_BIN_DIR=$PYTHON2_HOME

    export PYTHON3_HOME=/mingw64/bin
    export PYTHON3_BIN_DIR=$PYTHON3_HOME

    export PYTHON2_HOME_WIN=/c/apps/python27
    export PYTHON2_BIN_DIR_WIN=$PYTHON2_HOME_WIN/python-2.7.13.amd64

    export PYTHON3_HOME_WIN=/c/apps/python37
    export PYTHON3_BIN_DIR_WIN=$PYTHON3_HOME_WIN/python-3.7.4.amd64

    #export MSYS_HOME=/c/apps/msys64
    export MINGW_HOME=/mingw64

    #export JAVA_HOME=/c/apps/java/jre8
#    [[ -z $JAVA_HOME ]] && export JAVA_HOME=/c/apps/Java/jdk1.8.0_231
#    export JAVA_HOME=/c/apps/Java/jdk1.8.0_231
#    export JAVA_HOME=/c/apps/Java/jre1.6
    export JAVA_HOME=/c/apps/Java/jre1.8.0_231
    export M2_HOME=/c/apps/apache-maven-3.5.2

    export JYTHON_HOME=/c/apps/jython/jython2.7.0
    export MONGODB=/c/apps/mongodb3.3.8

    export CHOCOLATEYINSTALL=/c/ProgramData/Chocolatey
    export METEORINSTALL=/c/Users/Lee/AppData/Local/.meteor
#    export RUBYINSTALL=/c/apps/Ruby25-x64

    export EDITOR=/c/apps/notepad++/notepad++.exe

	DOCKER_HOME="/c/Program Files/Docker/Docker/resources"
	DOCKER_BIN=$DOCKER_HOME/bin

#    export DOCKER_TOOLBOX_INSTALL_PATH="/c/Program Files/Docker Toolbox"
#    export DOCKER_HOME=$DOCKER_TOOLBOX_INSTALL_PATH
#    export DOCKER_VM_IP=192.168.99.102

#    export DOCKER_TLS_VERIFY="1"
#    export DOCKER_HOST="tcp://192.168.99.102:2376"
#    export DOCKER_CERT_PATH="C:\Users\Lee\.docker\machine\machines\default"
#    export DOCKER_MACHINE_NAME="default"
#    export COMPOSE_CONVERT_WINDOWS_PATHS="true"

#    eval $("/c/Program Files/Docker Toolbox/docker-machine.exe" env default)
#    eval $("${DOCKER_TOOLBOX_INSTALL_PATH}/docker-machine.exe" env default)
#    eval $("C:\Program Files\Docker Toolbox\docker-machine.exe" env default)

	export HEROKU_HOME=/c/Program\ Files/Heroku

	## setting POSTGRES DB env
	export PGHOME="/C/Program Files/PostgreSQL/10"
	export PGDATA="/C/Program Files/PostgreSQL/10/data"
	export PGDATABASE=postgres
	export PGUSER=postgres
	export PGPORT=5432
	export PGLOCALEDIR="$PGHOME/share/locale"
	
	export VAGRANT_HOME="/c/apps/HashiCorp/Vagrant"
	export VAGRANT_DEFAULT_PROVIDER="virtualbox"
	export GOLANG_HOME="/c/apps/Go"
    export GOLANG_LOCAL_HOME="${HOME}/go"

	export POSH_HOME="/c/Windows/System32/WindowsPowerShell/v1.0"
	export DIG_HOME="/c/apps/dig"
	
    logDebug "setting PATH for MSYS/MINGW platform"
    ## set user path
#    export PATH=/usr/bin:/usr/local/bin
	export PATH=/usr/local/bin:/usr/bin

	if [[ "$platform" =~ ^(MINGW64)$ ]]; then
		export PATH=/usr/local/bin:/mingw64/bin:/usr/bin
	fi

    export PATH+=:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl
    export PATH+=:/c/Windows/system32
    export PATH+=:/c/apps/bin
    export PATH+=:"$HOME/bin"
    # export PATH+=:"/c/apps/7-Zip"
    export PATH+=:"$VSCOMMONTOOLS_MSYS"
    #export PATH+=:/c/apps/nvm
    export PATH+=:"$DOCKER_HOME"
    export PATH+=:"$DOCKER_HOME/bin"
#    export PATH+=:"$HEROKU_HOME/bin"
	export PATH+=:"$PGHOME/bin"

    ## java env
    export PATH+=:$JAVA_HOME/bin
    export PATH+=:$M2_HOME/bin

#    export PATH+=:$MONGODB/bin
#    export PATH+=:$JYTHON_HOME/bin

    ## Chocolatey
    export PATH+=:$CHOCOLATEYINSTALL/bin

    ## METEOR
    export PATH+=:$METEORINSTALL

    export PATH+=:$VAGRANT_HOME/bin
    export PATH+=:$GOLANG_HOME/bin
    export PATH+=:$GOLANG_LOCAL_HOME/bin

	export PATH+=:$POSH_HOME
    export PATH+=:$DIG_HOME/bin

    ## RUBY + JEKYLL + GEM
#    export PATH+=:$RUBYINSTALL/bin

    ## GIT
    export PATH+=:/c/apps/git/bin
    #export PATH=/c/apps/git/bin:$PATH

    #export PATH+=:~/.minishift/cache/oc/v1.4.1
    export PATH+=:$MINGW_HOME/bin

    ## MINIKUBE
#    export PATH+=:/c/apps/Kubernetes/Minikube

#    export PATH+=:/c/apps/phantomjs-2.1.1-windows/bin

    ## NODE/NPM
	export PATH+=":/c/Program Files/nodejs"
    export PATH+=:./node_modules/.bin
#    export PATH+=:/c/apps/nodejs
#    export PATH="./node_modules/.bin:${PATH}"
	export PATH+=":/c/Program Files (x86)/Yarn/bin"

    ## NVM
#    export NVM_DIR="$HOME/.nvm"
#    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
#    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    export NVM_DIR="/c/apps/nvm"
    export NVM_HOME="/c/apps/nvm"
    export NVM_SYMLINK="/c/apps/nodejs"

    export PATH+=":${NVM_DIR}"
    export PATH+=":${NVM_SYMLINK}"

	## windows path env:
#	add_winpath '/proc/registry/HKEY_LOCAL_MACHINE/SYSTEM/CurrentControlSet/Control/Session Manager/Environment'
#	add_winpath '/proc/registry/HKEY_CURRENT_USER/Environment'

else
    logDebug "setting path for LINUX/Other env"

    if [[ $EUID -eq 0 ]]; then
        #export KUBECONFIG=/opt/openshift/openshift.local.config/master/admin.kubeconfig
        # sudo -H cp /etc/kubernetes/admin.conf $HOME/.kube/config
        # sudo -H cp ~/repos/pyutils/k8s/conf/admin.conf $HOME/.kube/config
        export KUBECONFIG=$HOME/.kube/config
    fi
    if [ $HOSTNAME == "openshift.johnson.int" ]; then
	export OPENSHIFT_INSTALL=/opt/openshift
        export CURL_CA_BUNDLE=/opt/openshift/openshift.local.config/master/ca.crt
    fi

    export ANSIBLE_ROLES_PATH=/etc/ansible/roles:~/.ansible/roles

    export KOLLA_HOME=/data/Iaas/OpenStack

    export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

    export PATH+=:$OPENSHIFT_INSTALL

fi

logDebug "more PATH env var updates"

if [ -d "${HOME}/.local/bin" ]; then
    export PATH+=":${HOME}/.local/bin"
fi

#logDebug "PATH=${PATH}"

#export PATH+="node_modules/.bin"
export PATH="./node_modules/.bin:${PATH}"

#export PATH+=:.
export PATH=".:${PATH}"

#logDebug "PATH=${PATH}"

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

logInfo "setting python env"

##setenv-python 2
##setenv-python 3
setenv-python 3WIN

#logInfo "PATH=$PATH"

# Aliases
load_aliases () {

	if [ -f "${HOME}/.bash_aliases" ]; then
		logInfo "setting aliases"
		source "${HOME}/.bash_aliases"
	fi
}

load_aliases

