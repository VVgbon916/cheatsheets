#!/usr/bin/env bash
# lib_output_gate.sh -- symmetric to input gate.
# Strips raw read tokens and re-redacts anything the model leaked.
# Usage:  printf '%s' "$RESP" | lib_output_gate.sh
set -Eeuo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$HERE/lib_redact.sh"

ava_output_gate() {
    sed -E \
        -e 's/\[READ RESULT: [^]]*\]//g' \
        -e 's/\[READ: [^]]*\]//g' \
        -e 's/\[END READ\]//g' \
        -e 's/\[READ RESULT:.*$//g' \
    | ava_redact \
    | sed -e 's/^[[:space:]]*$//' | awk 'NF || blank++ < 1'
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    ava_output_gate
fi
