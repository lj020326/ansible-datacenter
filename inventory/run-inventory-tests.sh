#!/usr/bin/env bash

PROJECT_DIR=$( git rev-parse --show-toplevel )
INVENTORY_DIR="${PROJECT_DIR}/inventory"

ALWAYS_SHOW_TEST_RESULTS=0

INVENTORY_LIST="
PROD
QA
DEV
"

validate_child_inventories() {
  INVENTORY_LIST=$1

  ansible-inventory --version
  numFailed=0

  IFS=$'\n'
  for INVENTORY in ${INVENTORY_LIST}
  do
    echo "#######################################################"
    echo "==>"
    echo "==> ansible-inventory --graph -i ${INVENTORY}"
    echo "==>"
    exception_count=$(ansible-inventory --graph -i "${INVENTORY}" 2>&1 | grep -c -i -e warning -e error)

    if [[ $exception_count -eq 0 ]]; then
      echo "Congratulations!! No ansible-inventory exceptions found!!"
    else
      numFailed+=1
      echo "I am sorry to report that there are [${exception_count}] ansible-inventory exceptions found :("
      ansible-inventory --graph "${INVENTORY}" 2>&1 | grep -i -e warning -e error
    fi
    echo ""
    echo ""

  done

  return "${numFailed}"
}

validate_child_groupvars() {
  INVENTORY_LIST=$1

  IFS=$'\n'
  for INVENTORY in ${INVENTORY_LIST}
  do
    echo "#######################################################"
    echo "#######################################################"
    echo "==> Compare ./group_vars and [$INVENTORY]"
    echo "==> There should be NO differences here"
    echo "==> The only VALID exception for group_vars differences is group_vars/all/env_specific.yml"
    echo "==> "
    diff_count=$(diff -r group_vars "${INVENTORY}/group_vars" | grep -c -v ": env_specific.yml")
    if [[ $diff_count -eq 0 ]]; then
      echo "Congratulations!! No group_var diffs found!!"
    else
      echo "I am sorry to report that there are [${diff_count}] group_var diffs found :("
      diff -r group_vars "${INVENTORY}/group_vars" | grep -v ": env_specific.yml"
    fi
    echo ""
    echo ""

  done

  return "${diff_count}"
}

run_all_tests() {
  logPrefix="==> run_all_tests():"
  numFailed=0

  echo "${logPrefix} TEST[01] - Run validate_child_inventories() tests"

  test_results=$(validate_child_inventories "${INVENTORY_LIST}")
  returnStatus=$?
  numFailed+=$returnStatus

  echo "${logPrefix} TEST[01] - returnStatus=${returnStatus}"

  if [[ $returnStatus -gt 0 || $ALWAYS_SHOW_TEST_RESULTS -gt 0 ]]; then
    echo "${logPrefix} TEST[01] - test_results "
    echo "${logPrefix} TEST[01] - *********************** "
    echo "${test_results}"
    echo "${logPrefix} TEST[01] - ^^^^^^^^^^^^^^^^^^^^^^^ "
  fi

  echo "${logPrefix} TEST[02] - Run yamllint test"

  test_results=$(yamllint .)
  returnStatus=$?
  numFailed+=$returnStatus

  echo "${logPrefix} TEST[02] - returnStatus=${returnStatus}"

  if [[ $returnStatus -gt 0 || $ALWAYS_SHOW_TEST_RESULTS -gt 0 ]]; then
    echo "${logPrefix} TEST[02] - test_results ****"
    echo "${logPrefix} TEST[02] - *********************** "
    echo "${test_results}"
    echo "${logPrefix} TEST[02] - ^^^^^^^^^^^^^^^^^^^^^^^ "
  fi

  echo "${logPrefix} TEST[03] - Run validate_child_groupvars() test"

  test_results=$(validate_child_groupvars "${INVENTORY_LIST}")
  returnStatus=$?
  numFailed+=$returnStatus

  echo "${logPrefix} TEST[03] - returnStatus=${returnStatus}"

  if [[ $returnStatus -gt 0 || $ALWAYS_SHOW_TEST_RESULTS -gt 0 ]]; then
    echo "${logPrefix} TEST[03] - test_results ****"
    echo "${logPrefix} TEST[03] - *********************** "
    echo "${test_results}"
    echo "${logPrefix} TEST[03] - ^^^^^^^^^^^^^^^^^^^^^^^ "
  fi

  echo "${logPrefix} numFailed=${numFailed}"
  return ${numFailed}
}

function checkRequiredCommands() {
    missingCommands=""
    for currentCommand in "$@"
    do
        isInstalled "${currentCommand}" || missingCommands="${missingCommands} ${currentCommand}"
    done

    if [[ ! -z "${missingCommands}" ]]; then
        fail "checkRequiredCommands(): Please install the following commands required by this script:${missingCommands}"
    fi
}

function isInstalled() {
    command -v "${1}" >/dev/null 2>&1 || return 1
}

function main() {

  checkRequiredCommands ansible-inventory yamllint

  #echo "==> SCRIPT_DIR=${SCRIPT_DIR}"
  echo "==> PROJECT_DIR=${PROJECT_DIR}"

  cd "${INVENTORY_DIR}"

  run_all_tests
  totalNumFailed=$?

  echo "==> *********************** "
  echo "==> OVERALL INVENTORY TEST RESULTS"
  echo "==> TOTAL totalNumFailed=${totalNumFailed}"
  if [[ $totalNumFailed -eq 0 ]]; then
    echo "==> TEST SUCCEEDED!"
  else
    echo "==> TEST FAILED!"
  fi
  exit $numFailed
}

main "$@"
