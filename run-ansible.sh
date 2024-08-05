#!/usr/bin/env bash

#echo "params=${@}"

#DEBUG=0
REMOTE_USER=administrator
REMOTE_HOST=vcontrol01.johnson.int

#RUN_CMD=$(basename ${0})

TARGET_DIR=${PWD}
#GIT_REMOTE_URL=$(git config --get remote.origin.url)
GIT_REMOTE_URL=$(git ls-remote --get-url origin)

RUN_LOCAL=1
RUN_VENV=1

DEBUG_LEVEL=0
if [[ "$-" == *x* ]]; then
  echo "DEBUG is set"
  DEBUG_LEVEL=1
else
  echo "DEBUG is not set"
fi

usage() {
  retcode=${1-1}
  echo "" 1>&2
  echo "Usage: ${0} [options] [CLI commands]" 1>&2
  echo "" 1>&2
  echo "  Options:" 1>&2
  echo "     -R      : use default remote host to run the following ansible commands, defaults to \"${REMOTE_HOST}\"" 1>&2
  echo "     -n      : use OS ansible and do NOT bootstrap/use a virtualenv to run ansible" 1>&2
  echo "     -r HOST : set remote host used to run the following ansible commands" 1>&2
  echo "     -g URL  : set git repo URL for the site.yml playbook to use" 1>&2
  echo "     -b URL  : set git repo branch for the site.yml playbook to use" 1>&2
  echo "     -t DIR  : set git repo target directory to clone to for the site.yml playbook to use" 1>&2
  echo "" 1>&2
  echo "  Required:" 1>&2
  echo "     command:    ansible [ansible options]" 1>&2
  echo "                 ansible-playbook [ansible-playbook options]" 1>&2
  echo "                 kolla-ansible [kolla-ansible options]" 1>&2
  echo "                 shell_command [shell_command options]" 1>&2
  echo "" 1>&2
  echo "  Examples:" 1>&2
  echo "     ${0} ansible -m ping all"
  echo "     ${0} -r REMOTE_HOST ansible -i inventory/dev/hosts.ini -m ping"
  echo "     ${0} -R ansible -i inventory/dev/hosts.ini -m ping"
  echo "     ${0} ansible -i inventory/dev/hosts.ini all -m ping"
  echo "     ${0} ansible -i inventory/dev/hosts.ini openstack -m ping"
  echo "     ${0} ansible windows -i inventory/dev/hosts.ini -m win_ping"
  echo "     ${0} ansible -i inventory/dev/hosts.ini all -m ping"
  echo "     ${0} ansible-playbook site.yml --tags bootstrap-node --limit admin2"
  echo "     ${0} ansible-playbook site.yml --tags bootstrap-node-network --limit node01"
  echo "     ${0} ansible-playbook site.yml --tags bootstrap-node-mounts --limit media"
  echo "     ${0} ansible-playbook site.yml --tags bootstrap-openstack"
  echo "     ${0} ansible-playbook site.yml --tags bootstrap-openstack-cloud"
  echo "     ${0} ansible-playbook site.yml --tags docker-admin-node"
  echo "     ${0} ansible-playbook site.yml --tags docker-media-node"
  echo "     ${0} ansible-playbook site.yml --tags docker-samba-node"
  echo "     ${0} ansible-playbook site.yml --tags openstack-deploy-node"
  echo "     ${0} ansible-playbook site.yml --tags openstack-osclient"
  echo "     ${0} bash -x scripts/kolla-ansible/init-runonce.sh"
  echo "     ${0} bash -x scripts/kolla-ansible/test_ovs_network.sh"
  echo "     ${0} bash -x scripts/kolla-ansible/test_ovs_networks.sh"
  echo "     ${0} kolla-ansible -i inventory/hosts-openstack.ini bootstrap-servers"
  echo "     ${0} kolla-ansible -i inventory/hosts-openstack.ini deploy"
  echo "     ${0} kolla-ansible -i inventory/hosts-openstack.ini destroy --yes-i-really-really-mean-it"
  echo "     ${0} kolla-ansible -i inventory/hosts-openstack.ini post-deploy"
  echo "     ${0} kolla-ansible -i inventory/hosts-openstack.ini prechecks"
  echo "     ${0} kolla-ansible -i inventory/hosts-openstack.ini pull"
  echo "     ${0} kolla-ansible -i inventory/hosts-openstack.ini reconfigure"
  echo "     ${0} kolla-ansible -i inventory/hosts-openstack.ini restart"
  echo "     ${0} kolla-ansible -i inventory/hosts-openstack.ini stop"
  echo "     ${0} kolla-ansible -i inventory/hosts-openstack.ini stop --yes-i-really-really-mean-it"
  echo "     ${0} openstack server create --image cirros --flavor m1.tiny --key-name mykey --network demo-net demo1"
  echo "     ${0} scripts/kolla-ansible/init-runonce.sh"
  exit ${retcode}
}

run_command_wrapper_fn() {
  ## ref: https://stackoverflow.com/questions/16605362/in-bash-you-can-set-x-to-enable-debugging-is-there-any-way-to-know-if-that-has
  #    pip install --user debops[ansible]
  RUN_CMD=$1
  GIT_REPO_DIR=$2
  GIT_REMOTE_URL=$3
  GIT_BRANCH_NAME=$4
  DEBUG_LEVEL=$5
  shift 5

  ANSIBLE_LOG="ansible.log"
  OPENSTACK_VENV_PATH="/opt/openstack"
  BOOTSTRAP_VENV_SCRIPT="${GIT_REPO_DIR}/scripts/bootstrap-ansible-venv.sh"
  BOOTSTRAP_KOLLA_ENV="/etc/kolla/admin-openrc.sh"

  DEBUG_FLAG=""
  if [ ${DEBUG_LEVEL} -gt 0 ]; then
    DEBUG_FLAG="-x"
  fi

  GIT_PULL="git pull origin ${GIT_BRANCH_NAME}"
  echo "HOSTNAME=${HOSTNAME}"
  echo "RUN_CMD=${RUN_CMD}"
  #    export ANSIBLE_KEEP_REMOTE_FILES=1
  #    export ANSIBLE_DEBUG=1
  #    echo "which ansible-playbook=$(which ansible-playbook)"
  #    echo "env:\n$(env)"

  if [ ! -d ${GIT_REPO_DIR} ]; then
    echo "${GIT_REPO_DIR} not found, cloning from ${GIT_REMOTE_URL}"
    export PARENT_DIR="$(dirname "${GIT_REPO_DIR}")"
    mkdir -p ${PARENT_DIR}
    git clone ${GIT_REMOTE_URL} ${GIT_REPO_DIR}
  fi

  declare -a COMMAND_ARRAY
  COMMAND_ARRAY=("cd ${GIT_REPO_DIR}")
  COMMAND_ARRAY+=("${GIT_PULL}")
  COMMAND_ARRAY+=("git checkout ${GIT_BRANCH_NAME}")
  COMMAND_ARRAY+=("echo '############# SETUP RUN ENV #####################'")

  if [[ "${RUN_CMD}" == *"kolla-ansible"* ]]; then
    VENV_INIT="${OPENSTACK_VENV_PATH}/bin/activate"
    if [[ ${RUN_VENV} -eq 1 ]]; then
      COMMAND_ARRAY+=("source ${VENV_INIT}")
    fi
    COMMAND_ARRAY+=("source ${BOOTSTRAP_KOLLA_ENV}")
  elif [[ "${RUN_CMD}" == *"ansible-playbook"* ]]; then
    VENV_INIT="${GIT_REPO_DIR}/venv/bin/activate"
    if [[ ${RUN_VENV} -eq 1 ]]; then
      COMMAND_ARRAY+=("bash ${DEBUG_FLAG} ${BOOTSTRAP_VENV_SCRIPT}")
      COMMAND_ARRAY+=("source ${VENV_INIT}")
    fi
    COMMAND_ARRAY+=("[ ! -f ${ANSIBLE_LOG} ] || rm ${ANSIBLE_LOG}")
  elif [[ "${RUN_CMD}" == *"ansible"* ]]; then
    VENV_INIT="${GIT_REPO_DIR}/venv/bin/activate"
    if [[ ${RUN_VENV} -eq 1 ]]; then
      COMMAND_ARRAY+=("bash ${DEBUG_FLAG} ${BOOTSTRAP_VENV_SCRIPT}")
      COMMAND_ARRAY+=("source ${VENV_INIT}")
    fi
    COMMAND_ARRAY+=("[ ! -f ${ANSIBLE_LOG} ] || rm ${ANSIBLE_LOG}")
  fi
  COMMAND_ARRAY+=("echo '############# RUN COMMAND #######################'")

  echo "VENV_INIT=${VENV_INIT}"

  PARAMS="${@}"
  echo "PARAMS=${PARAMS}"

  COMMAND_ARRAY+=("echo ${RUN_CMD} ${PARAMS}")
  COMMAND_ARRAY+=("${RUN_CMD} ${PARAMS}")

  ## ref: https://stackoverflow.com/questions/13470413/converting-a-bash-array-into-a-delimited-string
  ## ref: https://stackoverflow.com/questions/15520339/how-to-remove-carriage-return-and-newline-from-a-variable-in-shell-script
  DELIM=' && \'
  NL=$'\n'
  printf -v COMMAND_STRING "%s${DELIM}$NL" "${COMMAND_ARRAY[@]}"
  COMMAND_STRING=${COMMAND_STRING%$NL}
  COMMAND_STRING=${COMMAND_STRING%$DELIM}

  echo "============================"
  echo "${COMMAND_STRING}"
  echo "============================"
  echo "============================"
  #  ${COMMAND_STRING}
  eval "${COMMAND_STRING}"
  echo "============================"
  echo "============================"

  exit ${?}
}

while getopts "g:b:r:t:Rhx" opt; do
  case "${opt}" in
  g) GIT_REMOTE_URL="${OPTARG}" ;;
  b) GIT_BRANCH_NAME="${OPTARG}" ;;
  r)
      RUN_LOCAL=0
      REMOTE_HOST="${OPTARG}"
      ;;
  t) TARGET_DIR="${OPTARG}" ;;
  R) RUN_LOCAL=0 ;;
  n) RUN_VENV=0 ;;
  x) DEBUG_LEVEL=1 ;;
  h) usage 1 ;;
  \?) usage 2 ;;
  :)
    echo "Option -$OPTARG requires an argument." >&2
    usage 3
    ;;
  *)
    usage 4
    ;;
  esac
done
shift $((OPTIND - 1))

RUN_CMD=$1
shift 1

additional_args=$@
echo "additional_args=${additional_args}" >&2

if [[ ! -z ${REMOTE_HOST} ]]; then
  if [[ "${REMOTE_HOST}" == "localhost" ]]; then
    RUN_LOCAL=1
  fi
fi

if [[ -z ${GIT_REMOTE_URL} || "${GIT_REMOTE_URL}" == "origin" ]]; then
  GIT_REMOTE_URL=${GIT_DC_URL-"https://github.com/lj020326/ansible-datacenter.git"}
  GIT_BRANCH_NAME=${GIT_DC_BRANCH-"public"}
else
  GIT_BRANCH_NAME=$(git symbolic-ref -q HEAD)
  GIT_BRANCH_NAME=${GIT_BRANCH_NAME##refs/heads/}
  GIT_BRANCH_NAME=${GIT_BRANCH_NAME:-HEAD}

  git add . && git commit -m 'updates' && git push origin
fi

## ref: https://stackoverflow.com/questions/1371261/get-current-directory-name-without-full-path-in-a-bash-script
#PROJECT_DIR=${PWD##*/}
PROJECT_DIR=${TARGET_DIR##*/}
PROJECT_DIR="${PROJECT_DIR%"${PROJECT_DIR##*[!/]}"}" # extglob-free multi-trailing-/ trim
PROJECT_DIR="${PROJECT_DIR##*/}"
ANSIBLE_LOG="ansible.log"

echo "TARGET_DIR=${TARGET_DIR}"
echo "PROJECT_DIR=${PROJECT_DIR}"

GIT_REPO_DIR=${TARGET_DIR}
if [[ ${RUN_LOCAL} -ne 1 ]]; then
  GIT_REPO_DIR=/home/${REMOTE_USER}/repos/ansible/${PROJECT_DIR}
fi
echo "GIT_REPO_DIR=${GIT_REPO_DIR}"

RUN_COMMAND_WITH_ARGS="run_command_wrapper_fn ${RUN_CMD} ${GIT_REPO_DIR} ${GIT_REMOTE_URL} ${GIT_BRANCH_NAME} ${DEBUG_LEVEL} ${@}"

if [[ "${RUN_CMD}" == *"ansible"* ]]; then
  VAULTPASS_FILEPATH="~/.vault_pass"
  VAULT_FILEPATH="./vars/vault.yml"
  RUN_COMMAND_WITH_ARGS+=" --vault-password-file ${VAULTPASS_FILEPATH}"
  RUN_COMMAND_WITH_ARGS+=" -e @${VAULT_FILEPATH}"
fi

if [[ ${RUN_LOCAL} -eq 1 ]]; then
  ${RUN_COMMAND_WITH_ARGS}
  COMMAND_RET_STATUS=$?
else

  #COMMAND="$(typeset -f run_command_wrapper_fn); run_command_wrapper_fn ${PROJECT_DIR} ${GIT_REMOTE_URL} ${@}"
  #COMMAND="$(declare -f run_command_wrapper_fn); run_command_wrapper_fn ${PROJECT_DIR} ${GIT_REMOTE_URL} ${GIT_BRANCH_NAME} ${@}"
  RUN_COMMAND_WITH_ARGS="$(declare -f run_command_wrapper_fn); ${RUN_COMMAND_WITH_ARGS}"

  ssh -t ${REMOTE_USER}@${REMOTE_HOST} "${RUN_COMMAND_WITH_ARGS}"
  COMMAND_RET_STATUS=$?

  if [[ "${RUN_CMD}" == *"ansible"* ]]; then
    echo "fetching ${GIT_REPO_DIR}/${ANSIBLE_LOG}"
    scp ${REMOTE_USER}@${REMOTE_HOST}:${GIT_REPO_DIR}/${ANSIBLE_LOG} .
  fi
fi
echo "COMMAND_RET_STATUS=${COMMAND_RET_STATUS}"
