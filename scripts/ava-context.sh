#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

printf '\033[36mAVA FAST CONTEXT\033[0m\n'
printf '\033[34m────────────────────────────────────\033[0m\n'

cat "$ROOT/reference/AI/INDEX.md"
printf '\n'
cat "$ROOT/reference/AI/CONTEXT.md"
printf '\n'
printf '\033[35mSOURCE POINTER\033[0m\n'
printf 'Repository root: %s\n' "$ROOT"
printf 'Reference root:   %s\n' "$ROOT/reference"
