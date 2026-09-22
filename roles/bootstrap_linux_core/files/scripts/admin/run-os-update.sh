#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e
# Treat unset variables as an error
set -u
# Ensure pipelines fail if any command in the pipe fails
set -o pipefail

BASE_DIR="/etc/run-os-update"
PRE_DIR="${BASE_DIR}/pre-update.d"
UPDATE_DIR="${BASE_DIR}/update.d"
POST_DIR="${BASE_DIR}/post-update.d"

STATE_POST_PENDING="/var/run/os-update-pending-post"
REBOOT_MARKER="/var/run/os-update-reboot-required"

# Helper function for consistent logging
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1"
}

log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $1" >&2
}

# ---------------------------------------------------------
# RESUME STATE CHECK
# ---------------------------------------------------------
if [ -f "$STATE_POST_PENDING" ]; then
    log_message "Resuming OS update sequence post-reboot..."

    # Run Post-Update Hooks
    if [ -d "$POST_DIR" ] && [ "$(ls -A $POST_DIR)" ]; then
        log_message "Executing post-update hooks..."
        run-parts --report "$POST_DIR" || { log_error "Post-update hooks failed!"; exit 1; }
    else
        log_message "No post-update hooks found. Skipping."
    fi

    rm -f "$STATE_POST_PENDING"
    rm -f "$REBOOT_MARKER"
    log_message "OS update sequence fully completed after reboot."
    exit 0
fi

# ---------------------------------------------------------
# NORMAL UPDATE FLOW
# ---------------------------------------------------------
log_message "Starting OS update."

# 1. Run Pre-Update Hooks (e.g., stopping Docker, unmounting specific drives)
if [ -d "$PRE_DIR" ] && [ "$(ls -A $PRE_DIR)" ]; then
    log_message "Executing pre-update hooks..."
    run-parts --report "$PRE_DIR" || { log_error "Pre-update hooks failed!"; exit 1; }
else
    log_message "No pre-update hooks found. Skipping."
fi

# 2. Run the Core Update Tasks (e.g., apt-get upgrade, dnf update)
if [ -d "$UPDATE_DIR" ] && [ "$(ls -A $UPDATE_DIR)" ]; then
    log_message "Executing update tasks..."
    run-parts --report "$UPDATE_DIR" || { log_error "Update tasks failed!"; exit 1; }
else
    log_message "No update tasks found. Skipping."
fi

# 3. Check if Reboot Was Triggered
if [ -f "$REBOOT_MARKER" ]; then
    log_message "Reboot required detected. Staging post-update state and rebooting in 1 minute..."
    touch "$STATE_POST_PENDING"

    # Schedule reboot in 1 minute to allow log flushing and clean exit
    /sbin/shutdown -r +1 "Automated OS update completed. Rebooting system."
    exit 0
fi

# 4. Run Post-Update Hooks (No Reboot Needed Case)
# (e.g., starting Docker, mounting specific drives, service health checks)
if [ -d "$POST_DIR" ] && [ "$(ls -A $POST_DIR)" ]; then
    log_message "Executing post-update hooks..."
    run-parts --report "$POST_DIR" || { log_error "Post-update hooks failed!"; exit 1; }
else
    log_message "No post-update hooks found. Skipping."
fi

log_message "OS update completed successfully."
exit 0
