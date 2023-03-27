#!/usr/bin/env bash

# PURPOSE:
# This script clones the openstack-ansible-tests repository to the
# tests/common folder in order to be able to re-use test components
# for role testing. This is intended to be the thinnest possible
# shim for test execution outside of OpenStack CI.

## Shell Opts ----------------------------------------------------------------
set -xeu

## Vars ----------------------------------------------------------------------

WORKING_DIR="$(readlink -f $(dirname $0))"
OSA_PROJECT_NAME="$(sed -n 's|^project=openstack/\(.*\).git$|\1|p' $(pwd)/.gitreview)"

COMMON_TESTS_PATH="${WORKING_DIR}/tests/common"
TESTING_HOME=${TESTING_HOME:-$HOME}
ZUUL_TESTS_CLONE_LOCATION="/home/zuul/src/opendev.org/openstack/openstack-ansible-tests"

# Use .gitreview as the key to determine the appropriate
# branch to clone for tests.
TESTING_BRANCH=$(awk -F'=' '/defaultbranch/ {print $2}' "${WORKING_DIR}/.gitreview")
if [[ "${TESTING_BRANCH}" == "" ]]; then
  TESTING_BRANCH="master"
fi

## Main ----------------------------------------------------------------------

# Source distribution information
source /etc/os-release || source /usr/lib/os-release

# Figure out the appropriate package install command
case ${ID,,} in
    centos|rhel|fedora|rocky) pkg_mgr_cmd="dnf install -y" ;;
    ubuntu|debian) pkg_mgr_cmd="apt-get install -y" ;;
    *) echo "unsupported distribution: ${ID,,}"; exit 1 ;;
esac

# Install git so that we can clone the tests repo if git is not available
which git &>/dev/null || eval sudo "${pkg_mgr_cmd}" git

# Clone the tests repo for access to the common test script
if [[ ! -d "${COMMON_TESTS_PATH}" ]]; then
    # The tests repo doesn't need a clone, we can just
    # symlink it.
    if [[ "${OSA_PROJECT_NAME}" == "openstack-ansible-tests" ]]; then
        ln -s "${WORKING_DIR}" "${COMMON_TESTS_PATH}"

    # In zuul v3 any dependent repository is placed into
    # /home/zuul/src/opendev.org, so we check to see
    # if there is a tests checkout there already. If so, we
    # symlink that and use it.
    elif [[ -d "${ZUUL_TESTS_CLONE_LOCATION}" ]]; then
        ln -s "${ZUUL_TESTS_CLONE_LOCATION}" "${COMMON_TESTS_PATH}"

    # Otherwise we're clearly not in zuul or using a previously setup
    # repo in some way, so just clone it from upstream.
    else
        git clone -b "${TESTING_BRANCH}" \
            https://opendev.org/openstack/openstack-ansible-tests \
            "${COMMON_TESTS_PATH}"
    fi
fi

# Execute the common test script
source tests/common/run_tests_common.sh
