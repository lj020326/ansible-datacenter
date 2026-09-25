#!/usr/bin/env bash

# Exit immediately on errors or unbound variables
set -e; set -u; set -o pipefail

log_message() { echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1"; }
log_error() { echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $1" >&2; }

# Configuration / Parameters (Defaults to true)
INCLUDE_PHASED="${INCLUDE_PHASED:-true}"

# Parse optional arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --upgrade)
            # Handled later or can be combined
            SHIFT_VAL=1
            ;;
        --no-phased)
            INCLUDE_PHASED=false
            ;;
        --include-phased=*)
            INCLUDE_PHASED="${1#*=}"
            ;;
    esac
    shift
done

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
    if [[ "${1:-}" == "" ]]; then # keep track if upgrade was requested via position or flags if needed
        # Fallback check
        true
    fi

    # Build apt options array based on INCLUDE_PHASED parameter
    APT_OPTIONS=()
    if [[ "$INCLUDE_PHASED" == "true" ]]; then
        APT_OPTIONS=(-o "APT::Get::Always-Include-Phased-Updates=true")
        log_message "Phased updates are enabled (Always-Include-Phased-Updates=true)."
    else
        log_message "Phased updates are disabled by configuration."
    fi

    # Run primary upgrade command with options
    apt-get "${APT_OPTIONS[@]}" ${UPGRADE_CMD} -qq -y

    # Force update any remaining/phased upgradable packages explicitly if enabled
    if [[ "$INCLUDE_PHASED" == "true" ]]; then
        UPGRADABLE_PKGS=$(apt-get "${APT_OPTIONS[@]}" -s upgrade | awk '$1=="Inst" {print $2}')
        if [ -n "$UPGRADABLE_PKGS" ]; then
            log_message "Upgrading remaining phased/deferred packages..."
            echo "$UPGRADABLE_PKGS" | xargs apt-get "${APT_OPTIONS[@]}" install --only-upgrade -qq -y
        fi
    fi

    apt-get autoremove -qq -y
    apt-get clean -qq

    # Firmware updates via fwupdmgr (if available)
    if command -v fwupdmgr >/dev/null 2>&1; then
        log_message "Checking for firmware updates using fwupdmgr..."
        fwupdmgr refresh || true
        fwupdmgr update -y || log_error "fwupdmgr update failed or skipped."
    fi

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
