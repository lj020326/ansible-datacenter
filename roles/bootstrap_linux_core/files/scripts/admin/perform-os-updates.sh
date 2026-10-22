#!/usr/bin/env bash

## ensure the state survives a reboot by storing the marker files in a persistent/non-volatile directory
#STATE_DIR="/var/run"
STATE_DIR="/var/lib/run-os-update"
REBOOT_MARKER="${STATE_DIR}/os-update-reboot-required"

# Exit immediately on errors or unbound variables
set -e; set -u; set -o pipefail

log_message() { echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1"; }
log_error() { echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $1" >&2; }

# Print a command in a form the user can copy-paste, then execute it.
# Usage: run_cmd <command> [args...]
# The full command line is echoed with a "CMD>" prefix before execution.
run_cmd() {
    # Build a shell-escaped representation for display
    local display_cmd=""
    local arg
    for arg in "$@"; do
        # Simple quoting: wrap in single quotes if it contains spaces or special chars
        if [[ "$arg" =~ [[:space:]|\$\`\\\"\'] ]]; then
            display_cmd+=" '${arg//\'/\'\\\'\'}'"
        else
            display_cmd+=" $arg"
        fi
    done
    # Strip leading space
    display_cmd="${display_cmd# }"
    log_message "CMD> ${display_cmd}"
    "$@"
}

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

    run_cmd apt-get update -qq -y

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
    run_cmd apt-get "${APT_OPTIONS[@]}" ${UPGRADE_CMD} -qq -y

    # Force update any remaining/phased upgradable packages explicitly if enabled
    if [[ "$INCLUDE_PHASED" == "true" ]]; then
        # Show the simulation command that discovers remaining packages
        log_message "CMD> apt-get ${APT_OPTIONS[*]} -s upgrade | awk '\$1==\"Inst\" {print \$2}'"
        UPGRADABLE_PKGS=$(apt-get "${APT_OPTIONS[@]}" -s upgrade | awk '$1=="Inst" {print $2}')
        if [ -n "$UPGRADABLE_PKGS" ]; then
            log_message "Upgrading remaining phased/deferred packages..."
            # Display the full xargs command the user could re-run
            log_message "CMD> echo \"${UPGRADABLE_PKGS}\" | xargs apt-get ${APT_OPTIONS[*]} install --only-upgrade -qq -y"
            echo "$UPGRADABLE_PKGS" | xargs apt-get "${APT_OPTIONS[@]}" install --only-upgrade -qq -y

            # Log any held packages for operational visibility
            HELD_PKGS=$(apt-mark showhold 2>/dev/null || true)
            if [ -n "$HELD_PKGS" ]; then
                log_message "Notice: The following packages are explicitly held back and will remain unupgraded:"
                echo "$HELD_PKGS" | while read -r pkg; do
                    log_message "  - $pkg (held)"
                done
            fi
        else
            log_message "No remaining phased/deferred packages found."
        fi
    fi

    run_cmd apt-get autoremove -qq -y
    run_cmd apt-get clean -qq

    # Firmware updates via fwupdmgr (if available)
    if command -v fwupdmgr >/dev/null 2>&1; then
        log_message "Checking for firmware updates using fwupdmgr..."
        run_cmd fwupdmgr refresh >/dev/null 2>&1 || true

        # Capture exit code without triggering 'set -e'
        FW_EXIT_CODE=0
        log_message "CMD> fwupdmgr update -y"
        fwupdmgr update -y || FW_EXIT_CODE=$?

        case "$FW_EXIT_CODE" in
            0)
                log_message "Firmware updates successfully applied."
                ;;
            2)
                log_message "No firmware updates available."
                ;;
            *)
                log_error "fwupdmgr update failed with exit code $FW_EXIT_CODE."
                ;;
        esac
    fi

# ---------------------------------------------------------
# CENTOS / RHEL / ROCKY / ALMA
# ---------------------------------------------------------
elif [[ "$OS_ID" == "centos" || "$OS_ID" == "rhel" || "$OS_LIKE" == *"rhel"* || "$OS_LIKE" == *"fedora"* ]]; then
    log_message "Detected RedHat-family system."

    # Prefer dnf (CentOS 8+) but fallback to yum (CentOS 7)
    if command -v dnf >/dev/null 2>&1; then
        log_message "Using dnf package manager."
        run_cmd dnf upgrade -y -q
        run_cmd dnf autoremove -y -q
        run_cmd dnf clean all -q
    elif command -v yum >/dev/null 2>&1; then
        log_message "Using yum package manager."
        run_cmd yum update -y -q
        run_cmd yum autoremove -y -q
        run_cmd yum clean all -q
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

# Check for NVIDIA driver / kernel module version mismatch
if [ -f /proc/driver/nvidia/version ]; then
    PROV_VER=$(grep -oP 'NVRM version:.*?\b\K[0-9]+\.[0-9]+(\.[0-9]+)?' /proc/driver/nvidia/version 2>/dev/null || true)
    MOD_VER=$(modinfo nvidia 2>/dev/null | awk '/^version:/ {print $2}' || true)
    if [ -n "$PROV_VER" ] && [ -n "$MOD_VER" ]; then
        # If loaded driver and modinfo versions differ, a reboot is required to load the new modules
        if [[ "$MOD_VER" != "$PROV_VER"* && "$PROV_VER" != "$MOD_VER"* ]]; then
            log_message "System reboot is required (NVIDIA driver version mismatch: loaded=$PROV_VER vs installed=$MOD_VER)."
            REBOOT_REQUIRED=1
        fi
    fi
fi

if [ "$REBOOT_REQUIRED" -eq 1 ]; then
    # Touch marker for run-os-update.sh orchestrator
    # Ensure state dir exists
    mkdir -p "${STATE_DIR}" 2>/dev/null || true
    touch "${REBOOT_MARKER}"
fi

exit 0
