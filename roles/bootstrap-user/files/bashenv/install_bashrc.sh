#!/usr/bin/env bash


DATE=`date +%Y%m%d%H%M%S`

echo "**********************************"
echo "*** installing bashrc         ****"
echo "**********************************"

HOME_DIR="${HOME}"

#INITIAL_WD=`pwd`
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
echo "SCRIPT_DIR=[${SCRIPT_DIR}]"

SRC_DIR="${SCRIPT_DIR}"
PROJECT_DIR="$( cd "$SRC_DIR/../../../" && pwd )"
PROJECT_DIR2="~/repos/silex/alsac/ansible-dcc"
## expand ~ for rsync to work correctly
#PROJECT_DIR2="$( cd "$PROJECT_DIR2" && pwd )"
eval PROJECT_DIR2=$PROJECT_DIR2

#SECRETS_DIR="$( cd "$SRC_DIR/../../private/env/" && pwd )"
SECRETS_DIR="${PROJECT_DIR}/files/private/env/"
export ANSIBLE_VAULT_PASSWORD_FILE=$HOME/.vault_pass

#REPO_DIR1="./roles/bootstrap-user/files/bashenv"
#REPO_DIR1="$( cd "$SRC_DIR/../../../roles/bootstrap-user/files/bashenv/" && pwd )"
REPO_DIR1="${PROJECT_DIR}/roles/bootstrap-user/files/bashenv"
REPO_DIR2="${PROJECT_DIR2}/files/scripts/bashenv"
REPO_DIR3="${PROJECT_DIR2}/roles/bootstrap-user/files/bashenv"

#FROM="${SRC_DIR}/.bash* ${SECRETS_DIR}/.bash*"
FROM="${SRC_DIR}/.bash*"
FROM2="${SRC_DIR}/"
BACKUP_HOME_DIR="${HOME_DIR}/.bash-backups"
BACKUP_REPO_DIR1="${REPO_DIR1}/save"
BACKUP_REPO_DIR2="${REPO_DIR2}/save"
BACKUP_REPO_DIR3="${REPO_DIR3}/save"

echo "SRC_DIR=[${SRC_DIR}]"
echo "HOME_DIR=[${HOME_DIR}]"
echo "FROM=[${FROM}]"
echo "FROM2=[${FROM2}]"
echo "REPO_DIR1=[${REPO_DIR1}]"
echo "REPO_DIR2=[${REPO_DIR2}]"
echo "REPO_DIR3=[${REPO_DIR3}]"
echo "SECRETS_DIR=[${SECRETS_DIR}]"

if [ ! -d $SRC_DIR ]; then
    echo "SRC_DIR not found at ${SRC_DIR}, exiting..."
    exit 1
fi

## rsync can backup and sync
## ref: https://www.digitalocean.com/community/tutorials/how-to-use-rsync-to-sync-local-and-remote-directories-on-a-vps

## REF: http://stackoverflow.com/questions/4585929/how-to-use-cp-command-to-exclude-a-specific-directory
EXCLUDES="--exclude=.idea"
EXCLUDES+=" --exclude=.git"
EXCLUDES+=" --exclude=venv"
EXCLUDES+=" --exclude=save"

RSYNC_OPTIONS_HOME=(
    -arv
    --update
    ${EXCLUDES}
    --backup
    --backup-dir=$BACKUP_HOME_DIR
)

RSYNC_OPTIONS_REPO1=(
    -arv
    --update
    ${EXCLUDES}
    --backup
    --backup-dir=$BACKUP_REPO_DIR1
)

RSYNC_OPTIONS_REPO2=(
    -arv
    --update
    ${EXCLUDES}
    --backup
    --backup-dir=$BACKUP_REPO_DIR2
)

RSYNC_OPTIONS_REPO3=(
    -arv
    --update
    ${EXCLUDES}
    --backup
    --backup-dir=$BACKUP_REPO_DIR3
)

#OPTIONS=(
#    -arv
#    --update
#)

echo "rsync ${RSYNC_OPTIONS_HOME[@]} ${FROM} ${HOME_DIR}/"
rsync ${RSYNC_OPTIONS_HOME[@]} ${FROM} ${HOME_DIR}/

echo "rsync ${RSYNC_OPTIONS_REPO1[@]} ${FROM2} ${REPO_DIR1}/"
rsync ${RSYNC_OPTIONS_REPO1[@]} ${FROM2} ${REPO_DIR1}/

if [ -d ${REPO_DIR2} ] ; then
  echo "rsync ${RSYNC_OPTIONS_REPO2[@]} ${FROM} ${REPO_DIR2}/"
  rsync ${RSYNC_OPTIONS_REPO2[@]} ${FROM2} ${REPO_DIR2}/

  echo "rsync ${RSYNC_OPTIONS_REPO3[@]} ${FROM} ${REPO_DIR3}/"
  rsync ${RSYNC_OPTIONS_REPO3[@]} ${FROM2} ${REPO_DIR3}/
fi

if [ "${SECRETS_DIR}/.bash_secrets" -nt "${HOME_DIR}/.bash_secrets" ]; then
  echo "deploying secrets ${SECRETS_DIR}/.bash_secrets"
  ## Do not need to specify password file since defined in ansible.cfg
  ansible-vault decrypt ${SECRETS_DIR}/.bash_secrets --output ${TO}/.bash_secrets --vault-password-file ~/.vault_pass
#  ansible-vault decrypt ${SECRETS_DIR}/.bash_secrets --output ${TO}/.bash_secrets
  chmod 600 ~/.bash_secrets
fi
