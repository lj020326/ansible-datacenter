#!/usr/bin/env bash

# Exit immediately on errors or unbound variables
set -e; set -u; set -o pipefail

log_message() { echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1"; }
log_error() { echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $1" >&2; }

log_message "Starting OS update sequence."

# Detect OS using standard os-release file
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID=$ID
    OS_LIKE=${ID_LIKE:-""}
else
    log_error "Cannot determine OS. /etc/os-release not found."
    exit 1
fi

# ---------------------------------------------------------
# DEBIAN / UBUNTU
# ---------------------------------------------------------
if [[ "$OS_ID" == "debian" || "$OS_ID" == "ubuntu" || "$OS_LIKE" == *"debian"* ]]; then
    log_message "Detected Debian/Ubuntu system. Running apt-get."

    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq -y
    # Using upgrade rather than full-upgrade for safer daily automated patching
    apt-get upgrade -qq -y
    apt-get autoremove -qq -y
    apt-get clean -qq

# ---------------------------------------------------------
# CENTOS / RHEL / ROCKY / ALMA
# ---------------------------------------------------------
elif [[ "$OS_ID" == "centos" || "$OS_ID" == "rhel" || "$OS_LIKE" == *"rhel"* || "$OS_LIKE" == *"fedora"* ]]; then
    log_message "Detected RedHat-family system."

    # Prefer dnf (CentOS 8+) but fallback to yum (CentOS 7)
    if command -v dnf >/dev/null 2>&1; then
        log_message "Using dnf package manager."
        dnf upgrade -y -q
        dnf autoremove -y -q
        dnf clean all -q
    elif command -v yum >/dev/null 2>&1; then
        log_message "Using yum package manager."
        yum update -y -q
        yum autoremove -y -q
        yum clean all -q
    else
        log_error "Neither dnf nor yum found. Aborting."
        exit 1
    fi

else
    log_error "Unsupported OS signature: ID=$OS_ID, ID_LIKE=$OS_LIKE"
    exit 1
fi

log_message "OS update sequence completed successfully."
exit 0
