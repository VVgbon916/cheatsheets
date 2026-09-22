#!/bin/bash
# Commands Board — harvests aliases, functions, sourced files, Make targets.
# Reads USER rc files only. Skips framework/completion noise.

OUT="$HOME/COMMANDS_BOARD.txt"

{
  echo "+==================================================================================================+"
  echo "|                                                                                                  |"
  echo "|                          C O M M A N D S   B O A R D                                             |"
  echo "|               All aliases, functions, sourced files, Make targets // local only                  |"
  echo "|                                                                                                  |"
  echo "|                          Dawa > AwA < Avalhla  //  (^.-)                                         |"
  echo "|                                                                                                  |"
  echo "+==================================================================================================+"
  echo ""
  echo "Generated: $(date '+%Y-%m-%d %H:%M')"
  echo "Shell:     $SHELL"
  echo "Host:      $(hostname)"
  echo ""

  # ── SECTION 01: ALIASES ─────────────────────────────────────────────────────────────
  echo "+==================================================================================================+"
  echo "|  SECTION 01  //  ALIASES                                                                         |"
  echo "+==================================================================================================+"
  echo ""
  grep -hE "^[[:space:]]*alias " \
    ~/.zshrc ~/.bashrc ~/.zsh_aliases ~/.bash_aliases 2>/dev/null | sort -u
  echo ""

  # ── SECTION 02: FUNCTIONS ───────────────────────────────────────────────────────────
  echo "+==================================================================================================+"
  echo "|  SECTION 02  //  SHELL FUNCTIONS  (yours only)                                                   |"
  echo "+==================================================================================================+"
  echo ""
  grep -hE "^[[:space:]]*(function )?[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(\)[[:space:]]*\{" \
    ~/.zshrc ~/.bashrc ~/.zsh_functions ~/.bash_functions 2>/dev/null \
    | sed -E 's/^[[:space:]]*(function )?([a-zA-Z_][a-zA-Z0-9_]*).*/\2/' | sort -u
  echo ""

  # ── SECTION 03: SOURCED FILES ───────────────────────────────────────────────────────
  echo "+==================================================================================================+"
  echo "|  SECTION 03  //  SOURCED FILES                                                                   |"
  echo "+==================================================================================================+"
  echo ""
  echo "# Sources from rc files:"
  grep -hE "^[[:space:]]*(source|\.) " \
    ~/.zshrc ~/.bashrc ~/.zprofile ~/.bash_profile 2>/dev/null \
    | sed -E 's/^[[:space:]]*(source|\.)[[:space:]]+//' \
    | sed -E 's/[[:space:]]*#.*$//' \
    | sort -u
  echo ""
  echo "# Shell config files in ~/ (maxdepth 2):"
  find ~ -maxdepth 2 \( -name ".*rc" -o -name ".*profile" -o -name ".*aliases" \) 2>/dev/null | sort
  echo ""

  # ── SECTION 04: PATH ADDITIONS ──────────────────────────────────────────────────────
  echo "+==================================================================================================+"
  echo "|  SECTION 04  //  PATH ADDITIONS                                                                  |"
  echo "+==================================================================================================+"
  echo ""
  echo "$PATH" | tr ':' '\n' | grep -vE "^(/usr|/bin|/sbin|/lib)" | sort -u
  echo ""

  # ── SECTION 05: MAKE TARGETS ────────────────────────────────────────────────────────
  echo "+==================================================================================================+"
  echo "|  SECTION 05  //  MAKE TARGETS  (all Makefiles in ~/Avalhla)                                     |"
  echo "+==================================================================================================+"
  echo ""
  find ~/Avalhla -maxdepth 3 \( -name "Makefile" -o -name "makefile" \) 2>/dev/null | sort | while read -r mf; do
    dir=$(dirname "$mf")
    echo "── ${dir/#$HOME/~} ──"
    grep -E "^[a-zA-Z_][a-zA-Z0-9_-]*:" "$mf" 2>/dev/null \
      | grep -v "^\." \
      | sed 's/:.*$//' \
      | sed 's/^/    make /'
    echo ""
  done

  # ── SECTION 06: UJUST COMMANDS ──────────────────────────────────────────────────────
  echo "+==================================================================================================+"
  echo "|  SECTION 06  //  UJUST COMMANDS  (Bazzite)                                                       |"
  echo "+==================================================================================================+"
  echo ""
  if command -v ujust >/dev/null 2>&1; then
    ujust --list 2>/dev/null | head -60
  else
    echo "    (ujust not found)"
  fi
  echo ""

  # ── SECTION 07: QUICK TOOL LISTS ────────────────────────────────────────────────────
  echo "+==================================================================================================+"
  echo "|  SECTION 07  //  QUICK TOOL LISTS                                                                |"
  echo "+==================================================================================================+"
  echo ""
  echo "── Homebrew formulas ──"
  brew list --formula 2>/dev/null | head -40 | sed 's/^/    /'
  echo ""
  echo "── Top 20 Flatpaks (by name) ──"
  flatpak list --app --columns=name 2>/dev/null | sort | head -20 | sed 's/^/    /'
  echo ""
  echo "── Podman containers (user) ──"
  podman ps -a --format '    {{.Names}}  {{.Status}}' 2>/dev/null || echo "    (podman not available)"
  echo ""

  echo "+==================================================================================================+"
  echo "|                                                                                                  |"
  echo "|                          Dawa > AwA < Avalhla  //  (^.-)                                         |"
  echo "|                          EVERY COMMAND. ONE BOARD. LOCAL ONLY.                                   |"
  echo "|                                                                                                  |"
  echo "+==================================================================================================+"
} > "$OUT"

echo "✅ Board written: $OUT"
wc -l "$OUT"
