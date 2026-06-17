#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e
# Treat unset variables as an error
set -u
# Ensure pipelines fail if any command in the pipe fails
set -o pipefail

BASE_DIR="/etc/daily-maintenance"
PRE_DIR="${BASE_DIR}/pre-update.d"
UPDATE_DIR="${BASE_DIR}/update.d"
POST_DIR="${BASE_DIR}/post-update.d"

# Helper function for consistent logging
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1"
}

log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $1" >&2
}

log_message "Starting daily maintenance wave."

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

# 3. Run Post-Update Hooks (e.g., starting Docker, service health checks)
if [ -d "$POST_DIR" ] && [ "$(ls -A $POST_DIR)" ]; then
    log_message "Executing post-update hooks..."
    run-parts --report "$POST_DIR" || { log_error "Post-update hooks failed!"; exit 1; }
else
    log_message "No post-update hooks found. Skipping."
fi

log_message "Daily maintenance wave completed successfully."
exit 0
