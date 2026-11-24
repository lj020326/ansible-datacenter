#!/bin/bash -eu

set -o pipefail

function main() {
    readonly template="$1"
    shift
    readonly content
    content="$(cat "$template")"

    eval "echo \"$content\""
}

main "$@"
