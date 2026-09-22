#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
REF="$ROOT/reference"

C_RESET=$'\033[0m'
C_CYAN=$'\033[36m'
C_BLUE=$'\033[34m'
C_MAGENTA=$'\033[35m'
C_YELLOW=$'\033[33m'

case "${1:-overview}" in
  overview)
    printf '%b\n' "${C_CYAN}AVALHLA REFERENCE${C_RESET}"
    printf '%b\n' "${C_BLUE}────────────────────────────────────${C_RESET}"
    printf 'Reference: %s\n' "$REF"
    printf 'Human docs: %s\n' "$(find "$REF/HUMAN" -type f 2>/dev/null | wc -l)"
    printf 'AI docs:    %s\n' "$(find "$REF/AI" -type f 2>/dev/null | wc -l)"
    printf 'Meta docs:  %s\n' "$(find "$REF/META" -type f 2>/dev/null | wc -l)"
    ;;
  human) exec "${PAGER:-less}" "$REF/HUMAN/README.md" ;;
  ai) exec "${PAGER:-less}" "$REF/AI/CONTEXT.md" ;;
  reflections) exec "${PAGER:-less}" "$REF/META/REFLECTIONS.md" ;;
  *) printf '%s\n' "Usage: $0 {overview|human|ai|reflections}"; exit 2 ;;
esac
