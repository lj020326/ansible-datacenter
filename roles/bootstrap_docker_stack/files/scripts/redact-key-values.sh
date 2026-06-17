#!/usr/bin/env bash

# Check if at least the input file argument is passed
if [ -z "$1" ] || [ ! -f "$1" ]; then
    echo "Usage: $0 <path_to_source_file> [path_to_output_file]"
    echo "Example: $0 openldap/ldif/10-bootstrap.ldif openldap/ldif/10-bootstrap-shared.ldif"
    exit 1
fi

SOURCE_FILE="$1"

# Determine the output filename (use 2nd argument if provided, otherwise append '-redacted')
if [ -n "$2" ]; then
    TARGET_FILE="$2"
else
    # Extract extension and base name to inject '-redacted' cleanly
    # e.g., path/to/file.ldif -> path/to/file-redacted.ldif
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

# Duplicate the source file to our target location to keep the original pristine
cp "$SOURCE_FILE" "$TARGET_FILE"

# Define the sensitive keys to search for (case-insensitive)
REDACT_KEYS=(
    "userPassword"
    "ssha_password"
    "sambaNTPassword"
    "nt_password"
    "password"
    "secret"
    "key"
)

echo "Redacting sensitive fields from '$SOURCE_FILE' into '$TARGET_FILE'..."

# Build sed commands dynamically
# ^([[:space:]]*-?[[:space:]]*) matches leading indentation and optional YAML list hyphens
# ($key) captures the specific sensitive attribute key group
# [[:space:]]*::?[[:space:]]* matches LDIF single/double colons or YAML mapping colons
# Build sed commands dynamically
#for key in "${REDACT_KEYS[@]}"; do
#    # Added [a-zA-Z0-9_\.]* to catch prefixing namespaces or parent keys
#    sed -i -E "s/^([[:space:]]*#?[[:space:]]*[a-zA-Z0-9_\.]*)($key)[[:space:]]*::?[[:space:]]*.*/\1\2: <redacted>/I" "$TARGET_FILE"
#done
# Build sed commands dynamically
#for key in "${REDACT_KEYS[@]}"; do
#    # Matches the line starting with spaces/comments/dashes, finds the exact key keyword,
#    # and targets everything up to the colon and the rest of the line.
#    sed -i -E "s/^([^:]*)($key)[[:space:]]*::?[[:space:]]*.*/\1\2: <redacted>/I" "$TARGET_FILE"
#done

# Build sed commands dynamically
for key in "${REDACT_KEYS[@]}"; do
    # Only redact if the colon is followed by an actual value (ignoring trailing spaces)
    sed -i -E "s/^([^:]*)($key)[[:space:]]*::?[[:space:]]*([^[:space:]#].*)/\1\2: <redacted>/I" "$TARGET_FILE"
done

echo "Redaction complete! Saved as: $TARGET_FILE"
