#!/usr/bin/env bash

DATE=`date +%Y%m%d%H%M%S`

echo "**********************************"
echo "*** installing bashrc         ****"
echo "**********************************"

HOME_DIR="${HOME}"

#INITIAL_WD=`pwd`
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
SCRIPT_BASE_DIR="$( cd "$( dirname "$0" )/.." && pwd )"

## expect to be run at the project root
#PROJECT_DIR="$( cd "$SCRIPT_DIR/../../../" && pwd )"
#PROJECT_DIR="$( pwd . )"
#PROJECT_DIR=$(git rev-parse --show-toplevel)
PROJECT_DIR="$( cd "$SCRIPT_DIR/" && git rev-parse --show-toplevel )"

#SECRETS_DIR="$( cd "$SCRIPT_DIR/../../private/env/" && pwd )"
SECRETS_DIR="${PROJECT_DIR}/files/private/env"
export ANSIBLE_VAULT_PASSWORD_FILE=$HOME/.vault_pass

#FROM="${SCRIPT_DIR}/.bash* ${SECRETS_DIR}/.bash*"
FROM="${SCRIPT_DIR}/.bash*"
BACKUP_HOME_DIR="${HOME_DIR}/.bash-backups"
BACKUP_REPO_DIR1="${REPO_DIR1}/save"

echo "SCRIPT_DIR=[${SCRIPT_DIR}]"
echo "HOME_DIR=[${HOME_DIR}]"
echo "PROJECT_DIR=[${PROJECT_DIR}]"
echo "FROM=[${FROM}]"
echo "SECRETS_DIR=[${SECRETS_DIR}]"

if [ ! -d $SCRIPT_DIR ]; then
    echo "SCRIPT_DIR not found at ${SCRIPT_DIR}, exiting..."
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

echo "rsync ${RSYNC_OPTIONS_HOME[@]} ${FROM} ${HOME_DIR}/"
rsync ${RSYNC_OPTIONS_HOME[@]} ${FROM} ${HOME_DIR}/

chmod +x ${SECRETS_DIR}/scripts/*.sh
chmod +x ${SECRETS_DIR}/git/*.sh

echo "rsync env scripts"
rsync ${RSYNC_OPTIONS_HOME[@]} ${SECRETS_DIR}/scripts/*.sh ${HOME_DIR}/bin/
rsync ${RSYNC_OPTIONS_HOME[@]} ${SECRETS_DIR}/git/*.sh ${HOME_DIR}/bin/
rsync ${RSYNC_OPTIONS_HOME[@]} ${SCRIPT_BASE_DIR}/certs/*.sh ${HOME_DIR}/bin/
chmod +x ${HOME_DIR}/bin/*.sh

if [ "${SECRETS_DIR}/.bash_secrets" -nt "${HOME_DIR}/.bash_secrets" ]; then
  echo "deploying secrets ${SECRETS_DIR}/.bash_secrets"
  ## Do not need to specify password file since defined in ansible.cfg
  decrypt_cmd="ansible-vault decrypt ${SECRETS_DIR}/.bash_secrets --output ${HOME_DIR}/.bash_secrets --vault-password-file ${HOME_DIR}/.vault_pass"
  echo $decrypt_cmd
  eval $decrypt_cmd
  chmod 600 ~/.bash_secrets
fi
