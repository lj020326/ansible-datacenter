#!/usr/bin/env bash

# Exit immediately if a pipeline returns a non-zero status.
set -eo pipefail

# --- Defaults ---
MATCH_SUBSTRING=true    # Default: true (Redact key names containing patterns)
CASE_INSENSITIVE=true  # Default: true (Case-insensitive matching)
WRITE_TO_FILE=false    # Default: false (Do not write to file by default)
SOURCE_FILE=""
TARGET_FILE=""

# Sensitive keys to search for
REDACT_KEYS=(
    "key"
    "password"
    "secret"
    "token"
)

# --- Usage Function ---
usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] <path_to_source_file> [path_to_output_file]

A script to redact sensitive fields from a configuration/LDIF/YAML file.
By default, it prints the redacted content directly to stdout without modifying files.

Options:
  -s, --exact-match     Disable substring matching. Only redact exact key matches.
                        (Default: Matches any key *containing* the pattern)
  -c, --case-sensitive  Enable case sensitivity.
                        (Default: Case-insensitive matching)
  -w, --write           Save the redacted output to a file instead of just displaying it.
                        If no output path is given, defaults to '<filename>.redacted.<ext>'.
  -h, --help            Display this help message and exit.

Examples:
  $(basename "$0") config.yaml
  $(basename "$0") -w input.ldif
  $(basename "$0") --exact-match --case-sensitive -w input.ldif output.ldif
EOF
    exit 1
}

# --- Parse Arguments ---
# Standardizing GNU-style long options to short options for standard getopts parsing
for arg in "$@"; do
    shift
    case "$arg" in
        '--exact-match')    set -- "$@" "-s" ;;
        '--case-sensitive')  set -- "$@" "-c" ;;
        '--write')          set -- "$@" "-w" ;;
        '--help')           set -- "$@" "-h" ;;
        *)                  set -- "$@" "$arg" ;;
    esac
done

while getopts "scwh" opt; do
    case "$opt" in
        s) MATCH_SUBSTRING=false ;;
        c) CASE_INSENSITIVE=false ;;
        w) WRITE_TO_FILE=true ;;
        h) usage ;;
        *) usage ;;
    esac
done
shift $((OPTIND-1))

# Check required source file argument
if [ -z "$1" ] || [ ! -f "$1" ]; then
    echo "Error: Source file missing or not found." >&2
    usage
fi

SOURCE_FILE="$1"

# Determine target filename if writing to file is enabled
if [ "$WRITE_TO_FILE" = true ]; then
    if [ -n "$2" ]; then
        TARGET_FILE="$2"
    else
        DIR=$(dirname "$SOURCE_FILE")
        FILENAME=$(basename "$SOURCE_FILE")
        BASE="${FILENAME%.*}"
        EXT="${FILENAME##*.}"

        if [ "$BASE" = "$EXT" ]; then
            TARGET_FILE="${DIR}/${BASE}.redacted"
        else
            TARGET_FILE="${DIR}/${BASE}.redacted.${EXT}"
        fi
    fi
fi

# --- Processing Logic ---

# Read the file content into a variable to manipulate it safely without touching the original file
CONTENT=$(cat "$SOURCE_FILE")

# Determine sed flag for case sensitivity
SED_I_FLAG=""
if [ "$CASE_INSENSITIVE" = true ]; then
    SED_I_FLAG="I"
fi

for key in "${REDACT_KEYS[@]}"; do
    # Build regex patterns based on whether substring matching is enabled
    if [ "$MATCH_SUBSTRING" = true ]; then
        # Group 1: Leading chars/spaces before the keyword
        # Group 2: The keyword itself
        # Group 3: Chars between the keyword and the delimiter
        # Group 4: The delimiter itself (any mix of : and =), plus any trailing spaces
        REGEX_PATTERN="^([^:=]*)(${key})([^:=]*)([[:space:]]*[:=]+[[:space:]]*)([^[:space:]#].*)"
    else
        # Exact match version
        REGEX_PATTERN="^([^:=]*)(${key})([[:space:]]*[:=]+[[:space:]]*)([^[:space:]#].*)"
    fi

    # In the replace pattern, \4 preserves the exact spacing/delimiter found in the line
    if [ "$MATCH_SUBSTRING" = true ]; then
        REPLACE_PATTERN="\1\2\3\4<redacted>"
    else
        REPLACE_PATTERN="\1\2\3<redacted>"
    fi

    # Perform the redaction via standard streams
    CONTENT=$(echo "$CONTENT" | sed -E "s|${REGEX_PATTERN}|${REPLACE_PATTERN}|${SED_I_FLAG}")
done

# --- Outputs ---

# Always display the result content
echo "--- REDACTED CONTENT START ---"
echo "$CONTENT"
echo "--- REDACTED CONTENT END ---"

# Conditionally save to file if requested
if [ "$WRITE_TO_FILE" = true ]; then
    echo "$CONTENT" > "$TARGET_FILE"
    echo ""
    echo "Success! Redacted file saved to: $TARGET_FILE"
fi
