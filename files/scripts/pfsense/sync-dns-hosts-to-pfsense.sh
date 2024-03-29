#!/usr/bin/env bash

VERSION="2024.2.1"

INTERNAL_DNS_NAMESERVER=dns.example.int
EXTERNAL_DNS_NAMESERVER=8.8.8.8

HOSTNAME_CONFIG_LIST_DEFAULT=("media.example.int:${INTERNAL_DNS_NAMESERVER}")
HOSTNAME_CONFIG_LIST_DEFAULT+=("apps.example.int:${INTERNAL_DNS_NAMESERVER}")
HOSTNAME_CONFIG_LIST_DEFAULT+=("git.example.int:${INTERNAL_DNS_NAMESERVER}")
HOSTNAME_CONFIG_LIST_DEFAULT+=("jira.example.int:${INTERNAL_DNS_NAMESERVER}")
HOSTNAME_CONFIG_LIST_DEFAULT+=("example.org:${EXTERNAL_DNS_NAMESERVER}")

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

API_CLIENT_REPO_DIR="~/repos/ansible/api-client"

#TEST_MODE=1
TEST_MODE=0

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

function install_api_client() {
  ## ref: https://github.com/MikeWooster/api-client/blob/master/README.md#extended-example
  #pip install loguru api-client

  #######################
  ## must install api-client from local source
  ## since there are issues when installing from pypi
  cd "${API_CLIENT_REPO_DIR}"
  pip install .
}

function sync_dns_to_pfsense() {
  local LOG_PREFIX="sync_dns_to_pfsense():"
  local HOSTNAME_CONFIG_LIST=("$@")

  for HOSTNAME_CONFIG in "${HOSTNAME_CONFIG_LIST[@]}"; do

    IFS=":" read -a HOSTNAME_CONFIG_ARRAY <<< "${HOSTNAME_CONFIG}"
    local HOSTNAME=${HOSTNAME_CONFIG_ARRAY[0]}
    local DNS_NAMESERVER=${HOSTNAME_CONFIG_ARRAY[1]}

    logDebug "${LOG_PREFIX} HOSTNAME=[$HOSTNAME], DNS_NAMESERVER=[$DNS_NAMESERVER]"

    SYNC_DNS_CMD="python ${HOME}/bin/pfsense_api_client.py sync-host-ip-list ${HOSTNAME} ${DNS_NAMESERVER} --apply"

    if [ $TEST_MODE -eq 0 ]; then
      logInfo "${LOG_PREFIX} ${SYNC_DNS_CMD}"
      eval "${SYNC_DNS_CMD}"
    else
      logInfo "${LOG_PREFIX} TEST_MODE=$TEST_MODE: skipping [${SYNC_DNS_CMD}]"
    fi

  done

}

function reset_local_dns() {
  local LOG_PREFIX="reset_local_dns():"

  RESET_DNS_CACHE="sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder"

  if [ $TEST_MODE -eq 0 ]; then
    logInfo "${LOG_PREFIX} ${RESET_DNS_CACHE}"
    eval "${RESET_DNS_CACHE}"
  else
    logInfo "${LOG_PREFIX} TEST_MODE=$TEST_MODE: skipping [${RESET_DNS_CACHE}]"
  fi

  logInfo "${LOG_PREFIX} Restart eaacloop"

  ## ref: https://serverfault.com/questions/194832/how-to-start-stop-restart-launchd-services-from-the-command-line#194886
  RESTART_EAACLOOP="sudo launchctl kickstart -k system/net.eaacloop.wapptunneld"

  if [ $TEST_MODE -eq 0 ]; then
    logInfo "${LOG_PREFIX} ${RESTART_EAACLOOP}"
    eval "${RESTART_EAACLOOP}"
  else
    logInfo "${LOG_PREFIX} TEST_MODE=$TEST_MODE: skipping [${RESTART_EAACLOOP}]"
  fi

}

function usage() {
  echo "Usage: ${0} [options] [[endpoint:dns_lookup_endpoint] [endpoint:dns_lookup_endpoint]...]"
  echo ""
  echo "  Options:"
  echo "       -L [ERROR|WARN|INFO|TRACE|DEBUG] : run with specified log level (default INFO)"
  echo "       -v : show script version"
  echo "       -h : help"
  echo ""
  echo "  Examples:"
	echo "       ${0} "
	echo "       ${0} -l DEBUG"
  echo "       ${0} -v"
	echo "       ${0} apps.example.org:8.8.8.8"
	echo "       ${0} apps.example.org:8.8.8.8 jira.example.org:1.1.1.1"
	echo "       ${0} apps.example.int:10.0.0.1 jira.example.int:dns.example.int"
	[ -z "$1" ] || exit "$1"
}

function main() {

  while getopts "L:r:vh" opt; do
      case "${opt}" in
          L) setLogLevel "${OPTARG}" ;;
          v) echo "${VERSION}" && exit ;;
          h) usage 1 ;;
          \?) usage 2 ;;
          *) usage ;;
      esac
  done
  shift $((OPTIND-1))

  HOSTNAME_CONFIG_LIST=("${HOSTNAME_CONFIG_LIST_DEFAULT[@]}")
  if [ $# -gt 0 ]; then
    HOSTNAME_CONFIG_LIST=("$@")
  fi
  logInfo "HOSTNAME_CONFIG_LIST[@]=${HOSTNAME_CONFIG_LIST[@]}"

#  install_api_client

  sync_dns_to_pfsense "${HOSTNAME_CONFIG_LIST[@]}"

  reset_local_dns

}

main "$@"
