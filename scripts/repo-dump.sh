#!/bin/bash
# Dumps entire repo (tree + file contents) for AI review.
# Skips .git, binaries, caches.

REPO="${1:-$HOME/projects/cheatsheets}"
cd "$REPO" || { echo "Repo not found: $REPO"; exit 1; }

{
  echo "════════════════════════════════════════════════════════════════════"
  echo "  REPO DUMP: $REPO"
  echo "  Generated: $(date '+%Y-%m-%d %H:%M')"
  echo "  Branch:    $(git branch --show-current 2>/dev/null)"
  echo "  Commit:    $(git rev-parse --short HEAD 2>/dev/null)"
  echo "════════════════════════════════════════════════════════════════════"
  echo ""

  # ── TREE ────────────────────────────────────────────────────────────
  echo "════════════════════════════════════════════════════════════════════"
  echo "  FILE TREE"
  echo "════════════════════════════════════════════════════════════════════"
  find . -type f -not -path './.git/*' -not -path './node_modules/*' \
    -not -name "*.pyc" -not -name ".DS_Store" | sort
  echo ""

  # ── FILE CONTENTS ───────────────────────────────────────────────────
  echo "════════════════════════════════════════════════════════════════════"
  echo "  FILE CONTENTS"
  echo "════════════════════════════════════════════════════════════════════"
  echo ""

  find . -type f -not -path './.git/*' -not -path './node_modules/*' \
    -not -name "*.pyc" -not -name ".DS_Store" | sort | while read -r f; do
    # Skip binaries
    if file "$f" | grep -q "text\|script\|JSON\|empty"; then
      echo "──── $f ────"
      cat "$f"
      echo ""
      echo ""
    else
      echo "──── $f ──── (binary, skipped)"
      echo ""
    fi
  done
} > "$HOME/repo-dump.txt"

echo "✅ Dump written: $HOME/repo-dump.txt"
wc -l "$HOME/repo-dump.txt"
echo ""
echo "Paste the contents into chat."
