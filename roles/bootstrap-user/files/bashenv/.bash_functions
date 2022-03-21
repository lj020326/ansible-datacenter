
local logPrefix=".bash_functions"
logDebug "configuring shell functions..."

# Functions
#
# Some example functions:
#
# a) function settitle
# settitle () 
# { 
#   echo -ne "\e]2;$@\a\e]1;$@\a"; 
# }
# 
# b) function cd_func
# This function defines a 'cd' replacement function capable of keeping, 
# displaying and accessing history of visited directories, up to 10 entries.
# To use it, uncomment it, source this file and try 'cd --'.
# acd_func 1.0.5, 10-nov-2004
# Petar Marinov, http:/geocities.com/h2428, this is public domain
# function cd_func ()
# {
#   local x2 the_new_dir adir index
#   local -i cnt
# 
#   if [[ $1 ==  "--" ]]; then
#     dirs -v
#     return 0
#   fi
# 
#   the_new_dir=$1
#   [[ -z $1 ]] && the_new_dir=$HOME
# 
#   if [[ ${the_new_dir:0:1} == '-' ]]; then
#     #
#     # Extract dir N from dirs
#     index=${the_new_dir:1}
#     [[ -z $index ]] && index=1
#     adir=$(dirs +$index)
#     [[ -z $adir ]] && return 1
#     the_new_dir=$adir
#   fi
# 
#   #
#   # '~' has to be substituted by ${HOME}
#   [[ ${the_new_dir:0:1} == '~' ]] && the_new_dir="${HOME}${the_new_dir:1}"
# 
#   #
#   # Now change to the new dir and add to the top of the stack
#   pushd "${the_new_dir}" > /dev/null
#   [[ $? -ne 0 ]] && return 1
#   the_new_dir=$(pwd)
# 
#   #
#   # Trim down everything beyond 11th entry
#   popd -n +11 2>/dev/null 1>/dev/null
# 
#   #
#   # Remove any other occurence of this dir, skipping the top of the stack
#   for ((cnt=1; cnt <= 10; cnt++)); do
#     x2=$(dirs +${cnt} 2>/dev/null)
#     [[ $? -ne 0 ]] && return 0
#     [[ ${x2:0:1} == '~' ]] && x2="${HOME}${x2:1}"
#     if [[ "${x2}" == "${the_new_dir}" ]]; then
#       popd -n +$cnt 2>/dev/null 1>/dev/null
#       cnt=cnt-1
#     fi
#   done
# 
#   return 0
# }
# 
# alias cd=cd_func

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

##
## TODO: make the following function work for DRY reasons
## cant get this to work for some reason
## getting the following error:
##
## $ setenv-python 2 
## bash: =2: command not found
##
unset -f setenv-python || true
function setenv-python() {
	python_version=${1:-"3WIN"}
	add2path=${2:-0}

	local logPrefix="setenv-python"
	logDebug "python_version=[${python_version}]"

	case "${python_version}" in
		3WIN)
			PYTHON_HOME=$PYTHON3_HOME_WIN
			PYTHON_BIN_DIR=$PYTHON3_BIN_DIR_WIN
			PYTHONDIR=$PYTHON3_BIN_DIR_WIN
			VENV_BINDIR="Scripts"
			PYTHON_SCRIPTDIR=$PYTHON_BIN_DIR/${VENV_BINDIR}
			export PATH=$PYTHON_HOME/scripts:$PATH
			export PATH=$PYTHON_SCRIPTDIR:$PATH
			export PATH=$PYTHON_BIN_DIR:$PATH
			;;
		3)
			PYTHON_HOME=$PYTHON3_HOME
			PYTHON_BIN_DIR=$PYTHON3_BIN_DIR
			PYTHONDIR=$PYTHON3_BIN_DIR
			VENV_BINDIR="bin"
			PYTHON_SCRIPTDIR=$PYTHON_BIN_DIR/${VENV_BINDIR}
			;;
		2WIN)
			PYTHON_HOME=$PYTHON2_HOME_WIN
			PYTHON_BIN_DIR=$PYTHON2_BIN_DIR_WIN
			PYTHONDIR=$PYTHON2_BIN_DIR_WIN
			PYTHON_SCRIPTDIR=$PYTHON_BIN_DIR/${VENV_BINDIR}
			export PATH=$PYTHON_HOME/scripts:$PATH
			export PATH=$PYTHON_SCRIPTDIR:$PATH
			export PATH=$PYTHON_BIN_DIR:$PATH
			VENV_BINDIR="Scripts"
			;;
		2)
			PYTHON_HOME=$PYTHON2_HOME
			PYTHON_BIN_DIR=$PYTHON2_BIN_DIR
			PYTHONDIR=$PYTHON2_BIN_DIR
			VENV_BINDIR="bin"
			PYTHON_SCRIPTDIR=$PYTHON_BIN_DIR/${VENV_BINDIR}
			;;
		*)
			platform="UNKNOWN:python_version=${python_version}"
			;;
	esac
	
	logDebug "PYTHON_HOME=[${PYTHON_HOME}]"

#	logDebug "PATH=$PATH"

	export PYTHON=$PYTHON_BIN_DIR/python
	alias .venv=". ./venv/${VENV_BINDIR}/activate"

}

unset -f get-certs || true
function get-certs() {

    DATE=`date +%Y%m%d%H%M%S`

    echo "**********************************"
    echo "*** installing certs"
    echo "**********************************"

    #CERT_DEST_DIR="~/.ssh"
    #CERT_DEST_DIR="/home/administrator/.ssh"
    CERT_DEST_DIR="${HOME}/.ssh"

    #INITIAL_WD=`pwd`
#    SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
#    logDebug "SCRIPT_DIR=[${SCRIPT_DIR}]"

#    CERT_SRC_DIR="${SCRIPT_DIR}/../certs/.ssh"
#    CERT_SRC_DIR="/opt/pyutils/certs/.ssh"
    CERT_SRC_DIR="${PYUTILS_DIR}/certs/.ssh"

    logDebug "CERT_SRC_DIR=[${CERT_SRC_DIR}]"
    logDebug "CERT_DEST_DIR=[${CERT_DEST_DIR}]"

    FROM="${CERT_SRC_DIR}/"
    TO="${CERT_DEST_DIR}/"
    BACKUP="${CERT_DEST_DIR}/backups"
    #BACKUP="backups"

    if [ ! -d $CERT_SRC_DIR ]; then
        logDebug "CERT_SRC_DIR not found at ${CERT_SRC_DIR}, exiting..."
        exit 1
    fi

    ## rsync can backup and sync
    ## ref: https://www.digitalocean.com/community/tutorials/how-to-use-rsync-to-sync-local-and-remote-directories-on-a-vps

    # OPTIONS=(
    #     -arv
    #     --update
    #     --backup
    #     --backup-dir=$BACKUP
    # )

    OPTIONS=(
        -arv
        --update
    )

    #echo "rsync ${OPTIONS[@]} $FROM $TO"
    echo "rsync ${OPTIONS[@]} $FROM $TO"

    rsync ${OPTIONS[@]} ${FROM} ${TO}

    chmod 600 ${CERT_DEST_DIR}/id_rsa

}

## ref: https://stackoverflow.com/questions/42635253/display-received-cert-with-curl
## example usage: 
##
##   certinfo admin2.johnson.int 5000
##
unset -f certinfo || true
function certinfo () {
  nslookup $1
  (openssl s_client -showcerts -servername $1 -connect $1:$2 <<< "Q" | openssl x509 -text | grep "DNS After")
}

unset -f create-git-project || true
function create-git-project() {
    $project=$1

    cd /var/lib/git
    mkdir $project.git
    cd $project.git
    git init --bare
    cd ..
    chown -R git.git $project.git
}


unset -f meteor-list-depends || true
function meteor-list-depends() {

    for p in `meteor list | grep '^[a-z]' | awk '{ print $1"@"$2 }'`; do echo "$p"; meteor show "$p" | grep -E "^  [a-z]"; echo; done
}

unset -f find-up || true
function find-up () {
    path=$(pwd)
    while [[ "$path" != "" && ! -e "$path/$1" ]]; do
        path=${path%/*}
    done
    echo "$path"
}

unset -f cdnvm || true
function cdnvm(){
    cd $@;
    nvm_path=$(find-up .nvmrc | tr -d '[:space:]')

    # If there are no .nvmrc file, use the default nvm version
    if [[ ! $nvm_path = *[^[:space:]]* ]]; then

        declare default_version;
        default_version=$(nvm version default);

        # If there is no default version, set it to `node`
        # This will use the latest version on your machine
        if [[ $default_version == "N/A" ]]; then
            nvm alias default node;
            default_version=$(nvm version default);
        fi

        # If the current version is not the default version, set it to use the default version
        if [[ $(nvm current) != "$default_version" ]]; then
            nvm use default;
        fi

        elif [[ -s $nvm_path/.nvmrc && -r $nvm_path/.nvmrc ]]; then
        declare nvm_version
        nvm_version=$(<"$nvm_path"/.nvmrc)

        # Add the `v` suffix if it does not exists in the .nvmrc file
        if [[ $nvm_version != v* ]]; then
            nvm_version="v""$nvm_version"
        fi

        # If it is not already installed, install it
        if [[ $(nvm ls "$nvm_version" | tr -d '[:space:]') == "N/A" ]]; then
            nvm install "$nvm_version";
        fi

        if [[ $(nvm current) != "$nvm_version" ]]; then
            nvm use "$nvm_version";
        fi
    fi
}

## make these function so they evaluate at time of exec and not upon shell startup
## Prevent bash alias from evaluating statement at shell start
## ref: https://stackoverflow.com/questions/13260969/prevent-bash-alias-from-evaluating-statement-at-shell-start
#alias gitpull.="git pull origin $(git rev-parse --abbrev-ref HEAD)"
#alias gitpush.="git push origin $(git rev-parse --abbrev-ref HEAD)"
#alias gitsetupstream="git branch --set-upstream-to=origin/$(git symbolic-ref HEAD 2>/dev/null)"

unset -f gitshowupstream || true
function gitshowupstream(){
  LOCAL_BRANCH="$(git symbolic-ref --short HEAD)" && \
  REMOTE_AND_BRANCH=$(git rev-parse --abbrev-ref ${LOCAL_BRANCH}@{upstream}) && \
  echo ${REMOTE_AND_BRANCH}
}

unset -f gitsetupstream. || true
function gitsetupstream(){
  NEW_REMOTE={$1:"origin"}
  LOCAL_BRANCH="$(git symbolic-ref --short HEAD)" && \
  echo LOCAL_BRANCH=${LOCAL_BRANCH} && \
  REMOTE_AND_BRANCH=$(git rev-parse --abbrev-ref ${LOCAL_BRANCH}@{upstream}) && \
  IFS=/ read REMOTE REMOTE_BRANCH <<< ${REMOTE_AND_BRANCH} && \
  git branch --set-upstream-to=${NEW_REMOTE}/${LOCAL_BRANCH}
}

unset -f gitpull || true
function gitpull(){
  LOCAL_BRANCH="$(git symbolic-ref --short HEAD)" && \
  REMOTE_AND_BRANCH=$(git rev-parse --abbrev-ref ${LOCAL_BRANCH}@{upstream}) && \
  IFS=/ read REMOTE REMOTE_BRANCH <<< ${REMOTE_AND_BRANCH} && \
  git pull ${REMOTE} ${REMOTE_BRANCH}
}

unset -f gitpush. || true
function gitpush(){
  LOCAL_BRANCH="$(git symbolic-ref --short HEAD)" && \
  REMOTE_AND_BRANCH=$(git rev-parse --abbrev-ref ${LOCAL_BRANCH}@{upstream}) && \
  IFS=/ read REMOTE REMOTE_BRANCH <<< ${REMOTE_AND_BRANCH} && \
  git push ${REMOTE} ${REMOTE_BRANCH}
}


unset -f gitpushwork || true
function gitpushwork(){
  GIT_SSH_COMMAND='ssh -i ~/.ssh/${SSH_KEY_WORK}' git push bitbucket $(git rev-parse --abbrev-ref HEAD)
}

unset -f gitpullwork || true
function gitpullwork(){
  GIT_SSH_COMMAND='ssh -i ~/.ssh/${SSH_KEY_WORK}' git pull bitbucket $(git rev-parse --abbrev-ref HEAD)
}

unset -f getbranchhist || true
function getbranchhist(){
  ## How to get commit history for just one branch?
  ## ref: https://stackoverflow.com/questions/16974204/how-to-get-commit-history-for-just-one-branch
  git log $(git rev-parse --abbrev-ref HEAD)..
}

unset -f gitcommitpush || true
function gitcommitpush() {
  LOCAL_BRANCH="$(git symbolic-ref --short HEAD)" && \
  REMOTE_AND_BRANCH=$(git rev-parse --abbrev-ref ${LOCAL_BRANCH}@{upstream}) && \
  IFS=/ read REMOTE REMOTE_BRANCH <<< ${REMOTE_AND_BRANCH} && \
  echo "Staging changes:" && \
  git add . && \
  echo "Committing changes:" && \
  git commit -am 'updates from ${HOSTNAME}' && \
  echo "Pushing local branch ${LOCAL_BRANCH} to remote ${REMOTE} branch ${REMOTE_BRANCH}:" && \
  git push ${REMOTE} ${LOCAL_BRANCH}:${REMOTE_BRANCH}
}

unset -f gitremovecached || true
function gitremovecached() {
  LOCAL_BRANCH="$(git symbolic-ref --short HEAD)" && \
  REMOTE_AND_BRANCH=$(git rev-parse --abbrev-ref ${LOCAL_BRANCH}@{upstream}) && \
  IFS=/ read REMOTE REMOTE_BRANCH <<< ${REMOTE_AND_BRANCH} && \
  git rm -r --cached . && \
  git add . && \
  git commit -am 'Remove ignored files' && \
  git push ${REMOTE} ${LOCAL_BRANCH}:${REMOTE_BRANCH}
}

unset -f blastit || true
function blastit() {
  ## https://stackoverflow.com/questions/5738797/how-can-i-push-a-local-git-branch-to-a-remote-with-a-different-name-easily
  ## https://stackoverflow.com/questions/46514831/how-read-the-current-upstream-for-a-git-branch
  LOCAL_BRANCH="$(git symbolic-ref --short HEAD)" && \
  REMOTE_AND_BRANCH=$(git rev-parse --abbrev-ref ${LOCAL_BRANCH}@{upstream}) && \
  IFS=/ read REMOTE REMOTE_BRANCH <<< ${REMOTE_AND_BRANCH} && \
  git pull ${REMOTE} ${REMOTE_BRANCH} && \
  git add . && \
  git commit -am "updates from ${HOSTNAME}" && \
  git push ${REMOTE} ${LOCAL_BRANCH}:${REMOTE_BRANCH}
}

## ref: https://superuser.com/questions/154332/how-do-i-unset-or-get-rid-of-a-bash-function
unset -f blastdocs || true
function blastdocs() {
    pushd . && cd ~/docs && git pull origin
    if [ -f save/phone.txt ]; then
#        cp -p save/phone.txt . && \
#        ansible-vault encrypt phone.txt --output ${TO}/.bash_secrets --vault-password-file ~/.vault_pass
        ansible-vault encrypt save/phone.txt --output phone.txt --vault-password-file ~/.vault_pass
    fi
    blastit && popd
}
