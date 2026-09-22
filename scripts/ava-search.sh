#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ $# -eq 0 ]]; then
  printf '%s\n' "Usage: $0 <search-term>"
  exit 2
fi

PATTERN="$*"
printf '\033[36mSEARCH\033[0m  %s\n' "$PATTERN"

if command -v rg >/dev/null 2>&1; then
  rg --hidden --glob '!/.git' -n -i -- "$PATTERN" "$ROOT"
else
  grep -Rni --exclude-dir=.git -- "$PATTERN" "$ROOT"
fi
