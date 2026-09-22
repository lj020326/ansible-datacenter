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

    UPGRADE_CMD="dist-upgrade"
    if [[ "${1:-}" == "--upgrade" ]]; then
      # Using upgrade rather than full-upgrade for safer daily automated patching
      UPGRADE_CMD="upgrade"
    fi

    apt-get ${UPGRADE_CMD} -qq -y
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

# ---------------------------------------------------------
# CHECK IF REBOOT IS REQUIRED
# ---------------------------------------------------------
REBOOT_REQUIRED=0

if [ -f /var/run/reboot-required ]; then
    log_message "System reboot is required (found /var/run/reboot-required)."
    REBOOT_REQUIRED=1
elif command -v needs-restarting >/dev/null 2>&1; then
    if ! needs-restarting -r >/dev/null 2>&1; then
        log_message "System reboot is required (needs-restarting detected kernel/core changes)."
        REBOOT_REQUIRED=1
    fi
fi

if [ "$REBOOT_REQUIRED" -eq 1 ]; then
    # Touch marker for run-os-update.sh orchestrator
    touch /var/run/os-update-reboot-required
fi

exit 0
