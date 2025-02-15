#!/usr/bin/env bash

## ref: https://github.com/moby/moby/issues/29293
## ref: https://github.com/Archi-Lab/archilab-jenkins/commit/04778dd6aa60eb348c5e160dab0749f7881ce2a7

VERSION="2025.2.12"

DOCKER_STACK_LIST_DEFAULT=()
DOCKER_STACK_LIST_DEFAULT+=("docker_stack")

DOCKER_EXTERNAL_NETWORK_LIST=()
DOCKER_EXTERNAL_NETWORK_LIST=("traefik_public")

DOCKER_COMPOSE_FILE=docker-compose.yml

DOCKER_DEPLOY_DETACHED=1

REMOVE_DOCKER_STACK=0


LOG_ERROR=0
LOG_WARN=1
LOG_INFO=2
LOG_TRACE=3
LOG_DEBUG=4

#LOG_LEVEL=${LOG_DEBUG}
LOG_LEVEL=${LOG_INFO}

function logError() {
  if [ $LOG_LEVEL -ge $LOG_ERROR ]; then
  	echo -e "[ERROR]: ==> ${1}"
  fi
}
function logWarn() {
  if [ $LOG_LEVEL -ge $LOG_WARN ]; then
  	echo -e "[WARN ]: ==> ${1}"
  fi
}
function logInfo() {
  if [ $LOG_LEVEL -ge $LOG_INFO ]; then
  	echo -e "[INFO ]: ==> ${1}"
  fi
}
function logTrace() {
  if [ $LOG_LEVEL -ge $LOG_TRACE ]; then
  	echo -e "[TRACE]: ==> ${1}"
  fi
}
function logDebug() {
  if [ $LOG_LEVEL -ge $LOG_DEBUG ]; then
  	echo -e "[DEBUG]: ==> ${1}"
  fi
}

function setLogLevel() {
  local LOGLEVEL=$1

  case "${LOGLEVEL}" in
    ERROR*)
      LOG_LEVEL=$LOG_ERROR
      ;;
    WARN*)
      LOG_LEVEL=$LOG_WARN
      ;;
    INFO*)
      LOG_LEVEL=$LOG_INFO
      ;;
    TRACE*)
      LOG_LEVEL=$LOG_TRACE
      ;;
    DEBUG*)
      LOG_LEVEL=$LOG_DEBUG
      ALWAYS_SHOW_TEST_RESULTS=1
      ;;
    *)
      abort "Unknown loglevel of [${LOGLEVEL}] specified"
  esac

}

function deploy_docker_stack() {
  local LOG_PREFIX="deploy_docker_stack():"
  local DOCKER_STACK_NAME=$1
  local wait_limit=20

  if [ "${REMOVE_DOCKER_STACK}" -eq 1 ]; then
    logInfo "${LOG_PREFIX} Removing stack [${DOCKER_STACK_NAME}].."
    #docker stack rm ${DOCKER_STACK_NAME} >/dev/null 2>&1 || true
    ## ref: https://github.com/moby/moby/issues/32620#issuecomment-439050180
    DOCKER_STACK_RM_COMMAND="docker stack rm --detach=false ${DOCKER_STACK_NAME}"
    logInfo "${LOG_PREFIX} ${DOCKER_STACK_RM_COMMAND}"
    ${DOCKER_STACK_RM_COMMAND} || true

    ## it would be nice if the 'docker stack rm' command supported a 'wait' option to avoid the following hack
    ## ref: https://github.com/moby/moby/issues/30942
#    until [ -z "$(docker service ls --filter label=com.docker.stack.namespace=${DOCKER_STACK_NAME} -q)" ] || [ "$wait_limit" -lt 0 ]; do
    until [ -z "$(docker stack ps "${DOCKER_STACK_NAME}" -q)" ] || [ "$wait_limit" -lt 0 ]; do
      sleep 2;
      wait_limit="$((wait_limit-1))"
    done

    until [ -z "$(docker network ls --filter label=com.docker.stack.namespace=${DOCKER_STACK_NAME} -q)" ] || [ "$wait_limit" -lt 0 ]; do
      sleep 2;
      wait_limit="$((wait_limit-1))"
    done

    logInfo "${LOG_PREFIX} All containers have stopped."
  fi

  #docker build --pull -t ${DOCKER_STACK_NAME} .

  for DOCKER_EXTERNAL_NETWORK in "${DOCKER_EXTERNAL_NETWORK_LIST[@]}"; do
    ## ref: https://stackoverflow.com/questions/48643466/docker-create-network-should-ignore-existing-network
    ## ref: https://docs.docker.com/reference/cli/docker/network/create/
    docker network inspect "${DOCKER_EXTERNAL_NETWORK}" >/dev/null 2>&1 || \
        docker network create --scope swarm --attachable --driver overlay "${DOCKER_EXTERNAL_NETWORK}"
#        docker network create \
#          --scope=swarm \
#          --driver=overlay \
#          --attachable \
#          --subnet=172.28.0.0/16 \
#          "${DOCKER_EXTERNAL_NETWORK}"
  done

  logInfo "${LOG_PREFIX} Deploy stack [${DOCKER_STACK_NAME}].."

  ## ref: https://github.com/moby/moby/issues/34153
  DOCKER_DEPLOY_COMMAND=("docker stack deploy")
  DOCKER_DEPLOY_COMMAND+=("--with-registry-auth")
  DOCKER_DEPLOY_COMMAND+=("--resolve-image=always")
  DOCKER_DEPLOY_COMMAND+=("--compose-file=${DOCKER_COMPOSE_FILE}")
  if [ "${DOCKER_DEPLOY_DETACHED}" -eq 0 ]; then
    DOCKER_DEPLOY_COMMAND+=("--detach=false")
  fi
  DOCKER_DEPLOY_COMMAND+=("${DOCKER_STACK_NAME}")

#  docker stack deploy \
#    --with-registry-auth \
#    --resolve-image=always \
#    --compose-file="${DOCKER_COMPOSE_FILE}" \
#    --detach=false \
#    "${DOCKER_STACK_NAME}"

  logInfo "${DOCKER_DEPLOY_COMMAND[*]}"
  eval "${DOCKER_DEPLOY_COMMAND[*]}"

  logInfo "${LOG_PREFIX} Running containers for stack [${DOCKER_STACK_NAME}]:"
  docker stack ps --filter="desired-state=running" ${DOCKER_STACK_NAME}
}

function usage() {
  echo "Usage: ${0} [options] [[docker stack name 1] [docker stack name 2] ...]"
  echo ""
  echo "  Options:"
  echo "       -L [ERROR|WARN|INFO|TRACE|DEBUG] : run with specified log level (default INFO)"
  echo "       -v : show script version"
  echo "       -f : docker compose filename (default docker-compose.yml)"
  echo "       -r : remove specified docker stack before deploying the specified docker stack"
  echo "       -h : help"
  echo ""
  echo "  Examples:"
	echo "       ${0} "
	echo "       ${0} -L DEBUG"
  echo "       ${0} -v"
	echo "       ${0} my_docker_stack"
	echo "       ${0} -L DEBUG my_stack1 my_stack2"
	[ -z "$1" ] || exit "$1"
}

function main() {

  if [[ "$UNAME" != "cygwin" && "$UNAME" != "msys" ]]; then
    if [ "$EUID" -ne 0 ]; then
      echo "Must run this script as root. run 'sudo $SCRIPT_NAME'"
      exit
    fi
  fi

  while getopts "L:f:vrh" opt; do
      case "${opt}" in
          L) setLogLevel "${OPTARG}" ;;
          v) echo "${VERSION}" && exit ;;
          f) DOCKER_COMPOSE_FILE="${OPTARG}" ;;
          r) REMOVE_DOCKER_STACK=1 ;;
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

  for DOCKER_STACK in "${__DOCKER_STACK_LIST[@]}"; do
    logDebug "DOCKER_STACK=${DOCKER_STACK}"
    deploy_docker_stack "${DOCKER_STACK}"
  done

}

main "$@"
