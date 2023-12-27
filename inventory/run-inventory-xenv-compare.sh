#!/usr/bin/env bash

SCRIPT_NAME=$(basename "${0}")
#SCRIPT_NAME="${SCRIPT_NAME%.*}"

PROJECT_DIR=$( git rev-parse --show-toplevel )
INVENTORY_DIR="${PROJECT_DIR}/inventory"

echo "PROJECT_DIR=${PROJECT_DIR}"
echo "INVENTORY_DIR=${INVENTORY_DIR}"

ENVS="
PROD
QA
DEV
"

main() {
  cd "${INVENTORY_DIR}"

  numFailed=0
  logPrefix="==> ${SCRIPT_NAME}:"

  echo "${logPrefix} Run validate_child_groupvars() test"

  test_results=$(validate_child_groupvars "${INVENTORY_LIST}")
  returnStatus=$?
  numFailed+=$returnStatus

  echo "${logPrefix} returnStatus=${returnStatus}"

  if [[ $returnStatus -gt 0 || $ALWAYS_SHOW_TEST_RESULTS -gt 0 ]]; then
    echo "${logPrefix} test_results ****"
    echo "${logPrefix} *********************** "
    echo "${test_results}"
    echo "${logPrefix} ^^^^^^^^^^^^^^^^^^^^^^^ "
  fi

  echo "${logPrefix} numFailed=${numFailed}"

  exit $returnStatus

}

validate_child_groupvars() {
  INVENTORY_DIR=$1
  ENVS=$2

  BASE_DIRECTORY="${INVENTORY_DIR}"
  echo "BASE_DIRECTORY=[$BASE_DIRECTORY]"

  IFS=$'\n'
  for environment in ${ENVS}
  do
    echo "#######################################################"
    echo "#######################################################"
    echo "##### Compare groups_vars and [$environment]"
    ENV_DIR="${INVENTORY_DIR}/${environment}"

    echo "#####"
    echo "##### Compare ./group_vars and [$environment]"
    echo "##### Ideally, there should be NO differences here"
    echo "#####   The only VALID exception for group_vars differences is group_vars/all/env_specific.yml"
    echo "#####"
    diff_count=$(diff -r group_vars "${environment}/group_vars" | grep -c -v ": env_specific.yml")
    if [[ $diff_count -eq 0 ]]; then
      echo "Congratulations!! No group_var diffs found!!"
    else
      echo "I am sorry to report that there are [${diff_count}] group_var diffs found :("
      diff -r group_vars "${environment}/group_vars" | grep -v ": env_specific.yml"
    fi
    echo ""
    echo ""

  done

  return ${diff_count}
}

main "$@"
