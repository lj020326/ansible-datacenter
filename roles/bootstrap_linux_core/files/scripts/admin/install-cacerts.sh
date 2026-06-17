#!/usr/bin/env bash

# ==============================================================================
# Script: install-cacerts.sh
# Version: 2026.5.09-universal
# Description: Multi-platform Root CA deduplication (macOS, Linux, MSYS/Cygwin).
# ==============================================================================

VERSION="2026.5.09-universal"
SCRIPT_NAME="$(basename "$0")"
CONFIG_FILE="$HOME/.install-cacerts"
STAGING_DIR="/tmp/cacerts_staging"
UNIQUE_DIR="$STAGING_DIR/unique_roots"

# Default configuration format: host[:port]|system|jdk|docker|python
SITE_LIST_DEFAULT=(
    "repo.maven.apache.org|1|1|0|1"
    "repo.jenkins-ci.org|1|1|0|1"
)

# ------------------------------------------------------------------------------
# Platform Detection & Trust Store Path Configuration
# ------------------------------------------------------------------------------
# Explicitly define OSTYPE if not present (helps when running via sudo)
[[ -z "$OSTYPE" ]] && OSTYPE=$(uname -s | tr '[:upper:]' '[:lower:]')

CACERT_TRUST_DIR=""
TRUST_CERT_EXT="crt"

if [[ "$OSTYPE" == "linux"* ]]; then
    if [ -f /etc/debian_version ]; then
        CACERT_TRUST_DIR="/usr/local/share/ca-certificates"
        TRUST_CERT_EXT="crt"
    elif [ -f /etc/redhat-release ] || [ -f /etc/centos-release ]; then
        CACERT_TRUST_DIR="/etc/pki/ca-trust/source/anchors"
        TRUST_CERT_EXT="pem"
    fi
fi

# Global Toggle Overrides
INSTALL_SYSTEM_CACERTS=1
INSTALL_JDK_CACERTS=1
INSTALL_DOCKER_CACERTS=0
INSTALL_PYTHON_CACERTS=1

# ------------------------------------------------------------------------------
# Logging & Utilities
# ------------------------------------------------------------------------------
LOG_LEVEL=2
set_log_level() {
    case "${1^^}" in
        ERROR) LOG_LEVEL=0 ;;
        WARN)  LOG_LEVEL=1 ;;
        INFO)  LOG_LEVEL=2 ;;
        TRACE) LOG_LEVEL=3 ;;
        DEBUG) LOG_LEVEL=4 ;;
        *) log_warn "Unknown log level $1, defaulting to INFO" ; LOG_LEVEL=2 ;;
    esac
}

log_error() { [[ $LOG_LEVEL -ge 0 ]] && echo -e "\033[0;31m[ERROR]:\033[0m ==> $1" >&2; }
log_warn()  { [[ $LOG_LEVEL -ge 1 ]] && echo -e "\033[0;33m[WARN ]:\033[0m ==> $1"; }
log_info()  { [[ $LOG_LEVEL -ge 2 ]] && echo -e "\033[0;32m[INFO ]:\033[0m ==> $1"; }
log_trace() { [[ $LOG_LEVEL -ge 3 ]] && echo -e "\033[0;34m[TRACE]:\033[0m ==> $1"; }
log_debug() { [[ $LOG_LEVEL -ge 4 ]] && echo -e "\033[0;35m[DEBUG]:\033[0m ==> $1"; }

usage() {
    cat <<EOF
Usage: sudo ./$SCRIPT_NAME [options] [host1:port host2:port ...]

Pipeline: Collect (Root Only) -> Deduplicate (Fingerprint) -> Commit -> Verify

Options:
  -L LEVEL  Set log level: ERROR WARN INFO TRACE DEBUG (default: INFO)
  -c FILE   Path to config file (Default: $CONFIG_FILE)
  -d        Enable Docker trust store installation
  -v        Show version and exit
  -h        Show help

Config Format: host[:port]|system_flag|jdk_flag|docker_flag|python_flag
EOF
    exit "${1:-0}"
}

# ------------------------------------------------------------------------------
# Discovery & OS Helpers
# ------------------------------------------------------------------------------
function find_java_cacerts() {
    local path=""
    if [ -n "$JAVA_HOME" ] && [ -f "$JAVA_HOME/lib/security/cacerts" ]; then
        path="$JAVA_HOME/lib/security/cacerts"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        path=$(/usr/libexec/java_home 2>/dev/null)/lib/security/cacerts
    else
        path=$(readlink -f "$(which java)" 2>/dev/null | sed "s:bin/java::")lib/security/cacerts
    fi
    echo "$path"
}

function get_site_config() {
    if [ $# -gt 0 ]; then
        for s in "$@"; do echo "$s|1|1|0|1"; done
    elif [ -f "$CONFIG_FILE" ]; then
        grep -v '^#' "$CONFIG_FILE" | grep '[^\s]' | sed 's/\s//g'
    else
        for s in "${SITE_LIST_DEFAULT[@]}"; do echo "$s"; done
    fi
}

# ------------------------------------------------------------------------------
# STAGE 1: COLLECT (Enhanced for Self-Signed & Bit-Merging)
# ------------------------------------------------------------------------------
function collect_all_certs() {
    local config_entries=("$@")
    rm -rf "$STAGING_DIR" && mkdir -p "$UNIQUE_DIR"
    log_info "STAGE 1: Collecting and Deduplicating Root CAs..."

    for entry in "${config_entries[@]}"; do
        IFS='|' read -r site sys jdk doc py <<< "$entry"
        local host="${site%%:*}"
        local port="${site##*:}"
        [[ "$host" == "$port" ]] && port="443"

        local raw_file="$STAGING_DIR/${host}_${port}_raw.txt"

        # Fetch the certificate chain from the server
        if ! timeout 5 openssl s_client -showcerts -connect "${host}:${port}" -servername "${host}" </dev/null > "$raw_file" 2>/dev/null; then
            log_warn "Unreachable: $host:$port"
            continue
        fi

        local root_tmp="$STAGING_DIR/${host}_${port}_root.pem"

        # Count certificates in the response to identify self-signed/single-cert setups
        local cert_count=$(grep -c "BEGIN CERTIFICATE" "$raw_file")

        if [ "$cert_count" -eq 1 ]; then
            # ENHANCEMENT: If only one cert is present, it is either self-signed
            # or the only anchor provided. We must trust it directly.
            openssl x509 -in "$raw_file" -out "$root_tmp" 2>/dev/null
        elif [ "$cert_count" -gt 1 ]; then
            # Extract the LAST certificate in the chain (The Root/Anchor)
            awk '
                /-----BEGIN CERTIFICATE-----/ { i=0; delete lines; }
                { lines[i++] = $0 }
                /-----END CERTIFICATE-----/ {
                    for (j=0; j<i; j++) cert_lines[j] = lines[j];
                    cert_len = i;
                }
                END { for (k=0; k<cert_len; k++) print cert_lines[k] }
            ' "$raw_file" > "$root_tmp"
        fi

        if [ -s "$root_tmp" ]; then
            # Generate SHA1 fingerprint for deduplication and filename
            local fp=$(openssl x509 -noout -fingerprint -sha1 -in "$root_tmp" | cut -d'=' -f2 | sed 's/://g')
            local subject=$(openssl x509 -noout -subject -in "$root_tmp")
            local final_name="$UNIQUE_DIR/${fp}.pem"
            local flag_file="$UNIQUE_DIR/${fp}.flags"

            # Save the unique certificate file
            [ ! -f "$final_name" ] && cp "$root_tmp" "$final_name"

            # Bit-merge flags (Logical OR) to ensure we do not duplicate prompts for the same cert
            local existing_sys=0; local existing_jdk=0; local existing_doc=0; local existing_py=0
            [ -f "$flag_file" ] && IFS='|' read -r existing_sys existing_jdk existing_doc existing_py < "$flag_file"

            # Update flag file with merged values
            echo "$((sys | existing_sys))|$((jdk | existing_jdk))|$((doc | existing_doc))|$((py | existing_py))" > "$flag_file"

            log_debug "Staged certificate for $host: subject=[$subject] FP=[${fp:0:12}]"
        fi
    done
}

# ------------------------------------------------------------------------------
# STAGE 2: COMMIT (Deduplicated execution)
# ------------------------------------------------------------------------------
function commit_certs() {
    log_info "STAGE 2: Committing $(ls "$UNIQUE_DIR"/*.pem 2>/dev/null | wc -l | xargs) unique roots..."

    for cert_file in "$UNIQUE_DIR"/*.pem; do
        [[ ! -e "$cert_file" ]] && continue
        local fp_ext=$(basename "$cert_file" .pem)
        local flag_file="$UNIQUE_DIR/${fp_ext}.flags"
        IFS='|' read -r sys jdk doc py < "$flag_file"
        local subject=$(openssl x509 -noout -subject -in "$cert_file")

        log_info "Installing: subject=[$subject] FP=[${fp_ext:0:12}]"

        # 1. SYSTEM STORE
        if [[ "$sys" -eq 1 && "$INSTALL_SYSTEM_CACERTS" -eq 1 ]]; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                # Use -d to add to Admin trust settings (requires sudo)
                # Adding specific policies (-p) to resolve "parameter not valid" errors
                sudo security add-trusted-cert -d -r trustAsRoot -p ssl -p basic -k /Library/Keychains/System.keychain "$cert_file"
#                sudo security add-trusted-cert -d -r trustRoot -p ssl -p basic -k /Library/Keychains/System.keychain "$cert_file"
                #sudo security add-trusted-cert -d -r trustAsRoot -k /Library/Keychains/System.keychain "$cert_file"
                #sudo security add-trusted-cert -d -r trustRoot -k "${HOME}/Library/Keychains/login.keychain" ${cert_file}
            elif [[ "$OSTYPE" == "linux"* ]]; then
                if [ -d "$CACERT_TRUST_DIR" ]; then
                    local target_path="${CACERT_TRUST_DIR}/${fp_ext}.${TRUST_CERT_EXT}"
                    log_info "Writing system cert to: $target_path"
                    sudo cp "$cert_file" "$target_path"
                else
                    log_error "System trust directory $CACERT_TRUST_DIR not found."
                fi
            elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
                # Windows Host Trust via certutil
                # Convert path for Windows native tool if necessary
                local win_cert_path=$(type -p cygpath >/dev/null && cygpath -w "$cert_file" || echo "$cert_file")
                log_info "Adding to Windows Root store: certutil -addstore root $win_cert_path"
                certutil -addstore root "$win_cert_path" >/dev/null 2>&1
            fi
        fi

        # 2. JAVA JDK STORE (Maven/Jenkins reliability)
        if [[ "$jdk" -eq 1 && "$INSTALL_JDK_CACERTS" -eq 1 ]]; then
            # Determine cacerts path based on JAVA_HOME
            local j_path=$(find_java_cacerts)
            if [ -f "$j_path" ]; then
                log_debug "Updating JDK Store: $j_path"
                # Remove old alias if present to prevent "already exists" errors
                keytool -delete -alias "$fp_ext" -keystore "$j_path" -storepass changeit >/dev/null 2>&1
                # Import the new root
                keytool -importcert -noprompt -keystore "$j_path" -storepass changeit -alias "$fp_ext" -file "$cert_file" >/dev/null 2>&1
            else
                log_warn "JDK flag set but cacerts not found. Check JAVA_HOME."
            fi
        fi

        # 3. PYTHON STORE (certifi)
        if [[ "$py" -eq 1 && "$INSTALL_PYTHON_CACERTS" -eq 1 ]]; then
            local py_path=$(python3 -m certifi 2>/dev/null)
            if [ -f "$py_path" ]; then
                log_debug "Appending to Python certifi: $py_path"
                grep -q "$fp_ext" "$py_path" || (echo -e "\n# FP: $fp_ext" >> "$py_path" && cat "$cert_file" >> "$py_path")
            fi
        fi

        # 4. DOCKER
        if [[ "$doc" -eq 1 && "$INSTALL_DOCKER_CACERTS" -eq 1 ]]; then
             # Mapping root back to host for docker-specific folder
             local host_map=$(grep -l "$fp_ext" "$STAGING_DIR"/*_root.pem | head -n 1 | xargs basename | cut -d'_' -f1,2 | sed 's/_/:/')
             if [ -n "$host_map" ]; then
                 log_info "Installing Docker cert for $host_map"
                 sudo mkdir -p "/etc/docker/certs.d/$host_map"
                 sudo cp "$cert_file" "/etc/docker/certs.d/$host_map/ca.crt"
             fi
        fi
    done

    # Run Linux trust updates once
    if [[ "$OSTYPE" == "linux"* ]]; then
        for cmd in "update-ca-trust extract" "update-ca-certificates"; do
            read -r base_cmd args <<< "$cmd"
            if command -v "$base_cmd" >/dev/null; then
                log_info "sudo $base_cmd $args"
                sudo $base_cmd $args
            fi
        done
    fi
}

# ------------------------------------------------------------------------------
# STAGE 3: VERIFY
# ------------------------------------------------------------------------------
function verify_trust() {
    log_info "STAGE 3: Verifying full site list..."
    local config_entries=("$@")
    for entry in "${config_entries[@]}"; do
        IFS='|' read -r site rest <<< "$entry"
        if curl -Is --connect-timeout 2 "https://$site" > /dev/null 2>&1; then
            echo -e "  \033[0;32m[PASS]\033[0m $site"
        else
            echo -e "  \033[0;31m[FAIL]\033[0m $site"
        fi
    done
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
main() {
    while getopts "L:c:dvxh" opt; do
        case "${opt}" in
            L) set_log_level "${OPTARG}" ;;
            c) CONFIG_FILE="${OPTARG}" ;;
            d) INSTALL_DOCKER_CACERTS=1 ;;
            v) echo "$VERSION" && exit ;;
            x) LOG_LEVEL=4 ;;
            h) usage 0 ;;
            *) usage 1 ;;
        esac
    done
    shift $((OPTIND-1))

    # Do not enforce sudo if on Windows-based shell environments
    if [[ "$OSTYPE" != "msys" && "$OSTYPE" != "cygwin" ]]; then
        [[ "$EUID" -ne 0 ]] && { log_error "Run with sudo"; exit 1; }
    fi

    local __CONFIG_LIST
    IFS=$'\n' read -d '' -r -a __CONFIG_LIST <<< "$(get_site_config "$@")"

    collect_all_certs "${__CONFIG_LIST[@]}"
    commit_certs
    verify_trust "${__CONFIG_LIST[@]}"
    log_info "Batch installation complete."
}

main "$@"
