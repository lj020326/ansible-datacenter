#!/usr/bin/env bash

## ref: https://github.com/moby/moby/issues/29293
## ref: https://github.com/Archi-Lab/archilab-jenkins/commit/04778dd6aa60eb348c5e160dab0749f7881ce2a7

VERSION="2025.2.12"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILEPATH="deploy-stack.cfg"

## ref: https://stackoverflow.com/questions/43053013/how-do-i-check-that-a-docker-host-is-in-swarm-mode
DOCKER_SWARM_NODE_STATE=$(docker info --format '{{.Swarm.LocalNodeState}}')
DOCKER_SWARM_CONTROL_NODE=$(docker info --format '{{.Swarm.ControlAvailable}}')

DOCKER_SWARM_MODE=0

DOCKER_STACK_LIST_DEFAULT=()
DOCKER_STACK_LIST_DEFAULT+=("docker_stack")

DOCKER_EXTERNAL_NETWORK_LIST=()
#DOCKER_EXTERNAL_NETWORK_LIST+=("traefik_public")
#DOCKER_EXTERNAL_NETWORK_LIST+=("traefik_public,172.28.0.0/16")
#DOCKER_EXTERNAL_NETWORK_LIST+=("traefik_public,192.168.12.0/24")

DOCKER_COMPOSE_FILE=docker-compose.yml

DOCKER_CLEANUP_POSTGRES_PIDFILE=0
DOCKER_POSTGRES_PIDFILE_PATH=postgres/data/postmaster.pid

DOCKER_DEPLOY_DETACHED=1

REMOVE_DOCKER_STACK=0
DEPLOY_DOCKER_STACK=1

#### LOGGING RELATED
LOG_ERROR=0
LOG_WARN=1
LOG_INFO=2
LOG_TRACE=3
LOG_DEBUG=4

declare -A LOGLEVEL_TO_STR
LOGLEVEL_TO_STR["${LOG_ERROR}"]="ERROR"
LOGLEVEL_TO_STR["${LOG_WARN}"]="WARN"
LOGLEVEL_TO_STR["${LOG_INFO}"]="INFO"
LOGLEVEL_TO_STR["${LOG_TRACE}"]="TRACE"
LOGLEVEL_TO_STR["${LOG_DEBUG}"]="DEBUG"

function reverse_array() {
  local -n ARRAY_SOURCE_REF=$1
  local -n REVERSED_ARRAY_REF=$2
  # Iterate over the keys of the LOGLEVEL_TO_STR array
  for KEY in "${!ARRAY_SOURCE_REF[@]}"; do
    # Get the value associated with the current key
    VALUE="${ARRAY_SOURCE_REF[$KEY]}"
    # Add the reversed key-value pair to the REVERSED_ARRAY_REF array
    REVERSED_ARRAY_REF[$VALUE]="$KEY"
  done
}

declare -A LOGLEVELSTR_TO_LEVEL
reverse_array LOGLEVEL_TO_STR LOGLEVELSTR_TO_LEVEL

#LOG_LEVEL=${LOG_DEBUG}
LOG_LEVEL=${LOG_INFO}

function logError() {
  if [ $LOG_LEVEL -ge $LOG_ERROR ]; then
  	logMessage "${LOG_ERROR}" "${1}"
  fi
}
function logWarn() {
  if [ $LOG_LEVEL -ge $LOG_WARN ]; then
  	logMessage "${LOG_WARN}" "${1}"
  fi
}
function logInfo() {
  if [ $LOG_LEVEL -ge $LOG_INFO ]; then
  	logMessage "${LOG_INFO}" "${1}"
  fi
}
function logTrace() {
  if [ $LOG_LEVEL -ge $LOG_TRACE ]; then
  	logMessage "${LOG_TRACE}" "${1}"
  fi
}
function logDebug() {
  if [ $LOG_LEVEL -ge $LOG_DEBUG ]; then
  	logMessage "${LOG_DEBUG}" "${1}"
  fi
}
function abort() {
  logError "$@"
  exit 1
}
function fail() {
  logError "$@"
  exit 1
}

function logMessage() {
  local LOG_MESSAGE_LEVEL="${1}"
  local LOG_MESSAGE="${2}"
  ## remove first item from FUNCNAME array
#  local CALLING_FUNCTION_ARRAY=("${FUNCNAME[@]:2}")
  ## Get the length of the array
  local CALLING_FUNCTION_ARRAY_LENGTH=${#FUNCNAME[@]}
  local CALLING_FUNCTION_ARRAY=("${FUNCNAME[@]:2:$((CALLING_FUNCTION_ARRAY_LENGTH - 3))}")
#  echo "CALLING_FUNCTION_ARRAY[@]=${CALLING_FUNCTION_ARRAY[@]}"

  local CALL_ARRAY_LENGTH=${#CALLING_FUNCTION_ARRAY[@]}
  local REVERSED_CALL_ARRAY=()
  for (( i = CALL_ARRAY_LENGTH - 1; i >= 0; i-- )); do
    REVERSED_CALL_ARRAY+=( "${CALLING_FUNCTION_ARRAY[i]}" )
  done
#  echo "REVERSED_CALL_ARRAY[@]=${REVERSED_CALL_ARRAY[@]}"

#  local CALLING_FUNCTION_STR="${CALLING_FUNCTION_ARRAY[*]}"
  ## ref: https://stackoverflow.com/questions/1527049/how-can-i-join-elements-of-a-bash-array-into-a-delimited-string#17841619
  local SEPARATOR=":"
  local CALLING_FUNCTION_STR
  CALLING_FUNCTION_STR=$(printf "${SEPARATOR}%s" "${REVERSED_CALL_ARRAY[@]}")
  CALLING_FUNCTION_STR=${CALLING_FUNCTION_STR:${#SEPARATOR}}

  ## ref: https://stackoverflow.com/a/13221491
  if [ "${LOGLEVEL_TO_STR[${LOG_MESSAGE_LEVEL}]+abc}" ]; then
    LOG_LEVEL_STR="${LOGLEVEL_TO_STR[${LOG_MESSAGE_LEVEL}]}"
  else
    abort "Unknown log level of [${LOG_MESSAGE_LEVEL}]"
  fi

  local LOG_LEVEL_PADDING_LENGTH=5

  local PADDED_LOG_LEVEL
  PADDED_LOG_LEVEL=$(printf "%-${LOG_LEVEL_PADDING_LENGTH}s" "${LOG_LEVEL_STR}")

  local LOG_PREFIX="${CALLING_FUNCTION_STR}():"
  echo -e "[${PADDED_LOG_LEVEL}]: ==> ${LOG_PREFIX} ${LOG_MESSAGE}"
}

function setLogLevel() {
  LOG_LEVEL_STR=$1

  ## ref: https://stackoverflow.com/a/13221491
  if [ "${LOGLEVELSTR_TO_LEVEL[${LOG_LEVEL_STR}]+abc}" ]; then
    LOG_LEVEL="${LOGLEVELSTR_TO_LEVEL[${LOG_LEVEL_STR}]}"
  else
    abort "Unknown log level of [${LOG_LEVEL_STR}]"
  fi

}

function remove_docker_stack() {
  local DOCKER_STACK_NAME=$1
  local wait_limit=20

  logInfo "Removing stack [${DOCKER_STACK_NAME}].."

  DOCKER_STACK_PS_COMMAND="docker compose --file=${DOCKER_COMPOSE_FILE} ps -q"
  DOCKER_STACK_RM_COMMAND="docker-compose down"
  if [[ "${DOCKER_SWARM_MODE}" -eq 1 ]]; then
      #docker stack rm ${DOCKER_STACK_NAME} >/dev/null 2>&1 || true
      ## ref: https://github.com/moby/moby/issues/32620#issuecomment-439050180
    DOCKER_STACK_PS_COMMAND="docker stack ps ${DOCKER_STACK_NAME} -q"
    DOCKER_STACK_RM_COMMAND="docker stack rm --detach=false ${DOCKER_STACK_NAME}"
  elif [[ "${DOCKER_SWARM_MODE}" -ne 0 ]]; then
    abort "DOCKER_SWARM_MODE => [${DOCKER_SWARM_MODE}], skipping stack removal"
  fi

  logInfo "${DOCKER_STACK_PS_COMMAND} && ${DOCKER_STACK_RM_COMMAND}"
  eval "${DOCKER_STACK_PS_COMMAND} >/dev/null 2>&1" && eval "${DOCKER_STACK_RM_COMMAND}" || true

  if [[ "${DOCKER_SWARM_MODE}" -eq 1 ]]; then
    DOCKER_LABEL_FILTER="label=com.docker.stack.namespace=${DOCKER_STACK_NAME}"

    ## it would be nice if the 'docker stack rm' command supported a 'wait' option to avoid the following hack
    ## ref: https://github.com/moby/moby/issues/30942
  #    until [ -z "$(docker service ls --filter ${DOCKER_LABEL_FILTER} -q)" ] || [ "$wait_limit" -lt 0 ]; do
    until [ -z "$(docker stack ps ${DOCKER_STACK_NAME} -q >/dev/null 2>&1)" ] || [ "$wait_limit" -lt 0 ]; do
      sleep 2;
      wait_limit="$((wait_limit-1))"
    done

    until [ -z "$(docker network ls --filter ${DOCKER_LABEL_FILTER} -q)" ] || [ "$wait_limit" -lt 0 ]; do
      sleep 2;
      wait_limit="$((wait_limit-1))"
    done
  fi

  for DOCKER_EXTERNAL_NETWORK in "${DOCKER_EXTERNAL_NETWORK_LIST[@]}"; do
    # ref: https://stackoverflow.com/questions/12317483/array-of-arrays-in-bash
    # split server name from sub-list
    IFS="," read -a DOCKER_NETWORK_INFO_ARRAY <<< $DOCKER_EXTERNAL_NETWORK
    local DOCKER_NETWORK_NAME=${DOCKER_NETWORK_INFO_ARRAY[0]}

    logInfo "Removing external network ${DOCKER_NETWORK_NAME}"
    docker network rm "${DOCKER_NETWORK_NAME}" >/dev/null 2>&1 || true
  done

  local RESTART_DOCKER_COMMAND="systemctl restart docker"
  logInfo "${RESTART_DOCKER_COMMAND}"
  eval "${RESTART_DOCKER_COMMAND}"

  ## ref: https://github.com/moby/moby/issues/25981#issuecomment-244783392
  DOCKER_PROXY_PORTS_STILL_EXIST=$(netstat -tulnp | grep -c "docker-proxy")

  if [ "${DOCKER_PROXY_PORTS_STILL_EXIST}" -ne 0 ]; then
    logInfo "[${DOCKER_PROXY_PORTS_STILL_EXIST}] docker-proxy port binds continue to exist after restart"
    logInfo "performing additional network cleanup"
    logInfo "  ** fix/resolution reference: https://github.com/moby/moby/issues/25981#issuecomment-244783392"
    cleanup_stale_docker_networks
  fi

  logInfo "Docker stack completely removed and ready to recreate."
}

## ref: https://github.com/moby/moby/issues/25981#issuecomment-244783392
function cleanup_stale_docker_networks() {
  local STOP_DOCKER_COMMAND="systemctl stop docker"
  logInfo "${STOP_DOCKER_COMMAND}"
  eval "${STOP_DOCKER_COMMAND}"

  rm -fr /var/lib/docker/network/files/*

  local START_DOCKER_COMMAND="systemctl start docker"
  logInfo "${START_DOCKER_COMMAND}"
  eval "${START_DOCKER_COMMAND}"

  DOCKER_PROXY_PORTS_STILL_EXIST=$(netstat -tulnp | grep -c "docker-proxy")

  if [ "${DOCKER_PROXY_PORTS_STILL_EXIST}" -ne 0 ]; then
    logError "[${DOCKER_PROXY_PORTS_STILL_EXIST}] docker-proxy port binds CONTINUE to exist after network cleanup"
    abort "quitting!"
  fi

}

function deploy_docker_stack() {
  local DOCKER_STACK_NAME=$1
  local wait_limit=20

  #docker build --pull -t ${DOCKER_STACK_NAME} .

  for DOCKER_EXTERNAL_NETWORK in "${DOCKER_EXTERNAL_NETWORK_LIST[@]}"; do

    # ref: https://stackoverflow.com/questions/12317483/array-of-arrays-in-bash
    # split server name from sub-list
    IFS="," read -a DOCKER_NETWORK_INFO_ARRAY <<< $DOCKER_EXTERNAL_NETWORK
    local DOCKER_NETWORK_NAME=${DOCKER_NETWORK_INFO_ARRAY[0]}
    local DOCKER_NETWORK_SUBNET=${DOCKER_NETWORK_INFO_ARRAY[1]}

    logDebug "DOCKER_NETWORK_NAME=${DOCKER_NETWORK_NAME}"
    logDebug "DOCKER_NETWORK_SUBNET=${DOCKER_NETWORK_SUBNET}"

    DOCKER_CREATE_NETWORK_COMMAND=("docker network create")
    if [[ "${DOCKER_SWARM_MODE}" -eq 1 ]]; then
      ## ref: https://github.com/moby/moby/issues/34153
      DOCKER_CREATE_NETWORK_COMMAND+=("--scope=swarm")
      DOCKER_CREATE_NETWORK_COMMAND+=("--driver=overlay")
    else
      DOCKER_CREATE_NETWORK_COMMAND+=("--scope=local")
    fi

    DOCKER_CREATE_NETWORK_COMMAND+=("--attachable")
    if [ -n "${DOCKER_NETWORK_SUBNET}" ]; then
      DOCKER_CREATE_NETWORK_COMMAND+=("--subnet=${DOCKER_NETWORK_SUBNET}")
    fi
    DOCKER_CREATE_NETWORK_COMMAND+=("${DOCKER_NETWORK_NAME}")
    logInfo "${DOCKER_CREATE_NETWORK_COMMAND[*]}"

    ## ref: https://stackoverflow.com/questions/48643466/docker-create-network-should-ignore-existing-network
    ## ref: https://docs.docker.com/reference/cli/docker/network/create/
    docker network inspect "${DOCKER_NETWORK_NAME}" >/dev/null 2>&1 || eval "${DOCKER_CREATE_NETWORK_COMMAND[*]}"
  done

  logInfo "Deploy stack [${DOCKER_STACK_NAME}].."

  DOCKER_DEPLOY_COMMAND=()
  if [[ "${DOCKER_SWARM_MODE}" -eq 1 ]]; then

    ## ref: https://github.com/moby/moby/issues/34153
    DOCKER_DEPLOY_COMMAND+=("docker stack deploy")
    DOCKER_DEPLOY_COMMAND+=("--with-registry-auth")
    DOCKER_DEPLOY_COMMAND+=("--resolve-image=always")
    DOCKER_DEPLOY_COMMAND+=("--compose-file=${DOCKER_COMPOSE_FILE}")
    if [ "${DOCKER_DEPLOY_DETACHED}" -eq 0 ]; then
      DOCKER_DEPLOY_COMMAND+=("--detach=false")
    else
      DOCKER_DEPLOY_COMMAND+=("--detach=true")
    fi
    DOCKER_DEPLOY_COMMAND+=("${DOCKER_STACK_NAME}")

  elif [[ "${DOCKER_SWARM_MODE}" -eq 0 ]]; then
#    DOCKER_DEPLOY_COMMAND+=("docker-compose up -d")
    DOCKER_DEPLOY_COMMAND+=("docker compose")
    DOCKER_DEPLOY_COMMAND+=("--file=${DOCKER_COMPOSE_FILE}")
    DOCKER_DEPLOY_COMMAND+=("up --detach")
  else
    abort "DOCKER_SWARM_MODE => [${DOCKER_SWARM_MODE}], skipping stack deploy"
  fi
  logInfo "${DOCKER_DEPLOY_COMMAND[*]}"
  eval "${DOCKER_DEPLOY_COMMAND[*]}"

  logInfo "Running containers for stack [${DOCKER_STACK_NAME}]:"
  if [[ "${DOCKER_SWARM_MODE}" -eq 1 ]]; then
    #docker stack ps --filter="desired-state=running" ${DOCKER_STACK_NAME}
    DOCKER_PS_COMMAND="docker stack ps --filter=\"desired-state=running\" ${DOCKER_STACK_NAME}"
  elif [[ "${DOCKER_SWARM_MODE}" -eq 0 ]]; then
    DOCKER_PS_COMMAND="docker compose ps"
  fi
  logInfo "${DOCKER_PS_COMMAND}"
  eval "${DOCKER_PS_COMMAND}"
}

function usage() {
  echo "Usage: ${0} [options] [[docker stack name 1] [docker stack name 2] ...]"
  echo ""
  echo "  Options:"
  echo "       -L [ERROR|WARN|INFO|TRACE|DEBUG] : run with specified log level (default INFO)"
  echo "       -c CONFIG_FILEPATH : default 'deploy-stack.cfg'"
  echo "       -f DOCKER_COMPOSE_FILE : default 'docker-compose.yml'"
  echo "       -p : make sure postgres pid file is cleaned up after stopping"
  echo "       -r : remove specified docker stack before deploying the specified docker stack"
  echo "       -s : skip docker stack deployment - may be used with 'remove' option to ONLY remove the stack"
  echo "       -v : show script version"
  echo "       -h : help"
  echo ""
  echo "  Examples:"
	echo "       ${0} "
	echo "       ${0} -L DEBUG"
  echo "       ${0} -v"
	echo "       ${0} my_docker_stack"
	echo "       ${0} -L DEBUG my_stack1 my_stack2"
  echo "       ${0} -p"
  echo "       ${0} -r -s"
  echo "       ${0} -rs"
	[ -z "$1" ] || exit "$1"
}

function main() {

  while getopts "L:c:f:prsvh" opt; do
      case "${opt}" in
          L) setLogLevel "${OPTARG}" ;;
          v) echo "${VERSION}" && exit ;;
          c) CONFIG_FILEPATH="${OPTARG}" ;;
          f) DOCKER_COMPOSE_FILE="${OPTARG}" ;;
          p) DOCKER_CLEANUP_POSTGRES_PIDFILE=1 ;;
          r) REMOVE_DOCKER_STACK=1 ;;
          s) DEPLOY_DOCKER_STACK=0 ;;
          h) usage 1 ;;
          \?) usage 2 ;;
          *) usage ;;
      esac
  done
  shift $((OPTIND-1))

  __DOCKER_STACK_LIST=("${DOCKER_STACK_LIST_DEFAULT[@]}")
  if [ $# -gt 0 ]; then
    __DOCKER_STACK_LIST=("$@")
  fi

  cd "${SCRIPT_DIR}"

  if [[ "$UNAME" != "cygwin" && "$UNAME" != "msys" ]]; then
    if [ "$EUID" -ne 0 ]; then
      abort "Must run this script as root. run 'sudo $SCRIPT_NAME'"
    fi
  fi

  if [ ! -e "${DOCKER_COMPOSE_FILE}" ]; then
    abort "docker compose file ${DOCKER_COMPOSE_FILE} not found, quitting now!"
  fi

  if [[ "${DOCKER_SWARM_NODE_STATE}" == "active" ]]; then
    if [[ "${DOCKER_SWARM_CONTROL_NODE}" == "true" ]]; then
      DOCKER_SWARM_MODE=1
    else
      ## not a control node
      DOCKER_SWARM_MODE=2
    fi
  fi

  if [ -n "${CONFIG_FILEPATH}" ]; then
    if [ ! -e $CONFIG_FILEPATH ]; then
      logWarn "Config file ${CONFIG_FILEPATH} not found, skip loading it!"
    else
      logInfo "Reading configs from ${CONFIG_FILEPATH} ...."
      source ${CONFIG_FILEPATH}
    fi
  fi

  logDebug "DOCKER_SWARM_MODE => [${DOCKER_SWARM_MODE}]"
  logDebug "DOCKER_CLEANUP_POSTGRES_PIDFILE => [${DOCKER_CLEANUP_POSTGRES_PIDFILE}]"
  logDebug "REMOVE_DOCKER_STACK => [${REMOVE_DOCKER_STACK}]"
  logDebug "DEPLOY_DOCKER_STACK => [${DEPLOY_DOCKER_STACK}]"
  logDebug "SCRIPT_DIR=[${SCRIPT_DIR}]"

  if [ "${REMOVE_DOCKER_STACK}" -eq 1 ]; then
    for DOCKER_STACK in "${__DOCKER_STACK_LIST[@]}"; do
      remove_docker_stack "${DOCKER_STACK}"
    done
  fi
  if [ "${DOCKER_CLEANUP_POSTGRES_PIDFILE}" -eq 1 ]; then
    logInfo "remove ${DOCKER_POSTGRES_PIDFILE_PATH}"
    rm -f "${DOCKER_POSTGRES_PIDFILE_PATH}"
  fi

  if [ "${DEPLOY_DOCKER_STACK}" -eq 0 ]; then
    exit 0
  fi

  for DOCKER_STACK in "${__DOCKER_STACK_LIST[@]}"; do
    deploy_docker_stack "${DOCKER_STACK}"
  done

}

main "$@"
