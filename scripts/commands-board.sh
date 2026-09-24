#!/usr/bin/env bash
# commands-board.sh -- Avalhla's interactive world.
set -Eeuo pipefail
unset GREP_OPTIONS 2>/dev/null || true
export LC_ALL=C.UTF-8 2>/dev/null || true

ROOT="$HOME/Avalhla"
FACE_DAWA='(^.-)'
FACE_AVA='(⌒.⌒)'
BRIDGE='AvvA'
WIDTH=100

# ---------- Avalhla palette ----------
# theme colors used throughout — not the mood color
C_BRAND=141     # soft purple (Avalhla)
C_ACCENT=208    # warm orange (Dawa)
C_DIM=240       # dim gray
C_WHITE=255     # bright white
C_ROSE=204      # rose (highlight)
C_CYAN=81       # light cyan

ansi()  { printf '\033[38;5;%sm' "$1"; }
reset() { printf '\033[0m'; }

# mood color to ANSI number
mood_ansi() {
    case "$1" in
        red) printf '196' ;; orange) printf '208' ;; yellow) printf '220' ;;
        green) printf '82' ;; blue) printf '39' ;; purple) printf '135' ;;
        magenta) printf '201' ;; cyan) printf '51' ;;
        *) printf '15' ;;
    esac
}

# ---------- state ----------
mood_json()   { command -v ava-mood >/dev/null 2>&1 && ava-mood json 2>/dev/null || echo '{}'; }
mood_color()  { mood_json | jq -r '.color // "white"'; }
mood_label()  { mood_json | jq -r '.label // "present"'; }
mood_since()  { mood_json | jq -r '.since // ""' | awk '{print $1}'; }

age_of() {
    local f="$1"; [[ -f "$f" ]] || { echo "—"; return; }
    local t now d
    t="$(stat -c '%Y' "$f" 2>/dev/null || echo 0)"
    now="$(date +%s)"; d=$(( now - t ))
    if (( d < 60 )); then echo "${d}s"
    elif (( d < 3600 )); then echo "$(( d / 60 ))m"
    elif (( d < 86400 )); then echo "$(( d / 3600 ))h"
    else echo "$(( d / 86400 ))d"; fi
}

latest_file() {
    find "$1" -maxdepth 1 -type f -name "${2:-*.md}" -printf '%T@ %p\n' 2>/dev/null \
        | sort -nr | head -n1 | cut -d' ' -f2- || true
}

dream_quote() {
    local pool
    pool="$(
        find "$ROOT/memory/reflections/dreams" -maxdepth 1 -type f -name '*.md' 2>/dev/null \
        | sort -r | head -n 10 \
        | while read -r f; do
            grep -avE '^[[:space:]]*(#|>|type:|status:|timestamp:|source:|confidence:|---|$)' "$f" 2>/dev/null \
                | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' \
                | sed -e "s/\"/'/g" -e 's/  */ /g' \
                | awk 'length($0) >= 60 && length($0) <= 240'
        done
    )"
    if [[ -z "$pool" ]]; then
        printf '%s' 'Somewhere, another door is still waiting.'
        return
    fi
    printf '%s\n' "$pool" | shuf -n 1 2>/dev/null \
        || printf '%s\n' "$pool" | awk 'BEGIN{srand()} {a[NR]=$0} END{print a[int(rand()*NR)+1]}'
}

# ---------- user identity ----------
user_name()  { printf 'Dawa'; }
user_handle(){ printf 'VVgbon'; }
user_rig()   { hostnamectl --static 2>/dev/null || printf 'VVgBazz'; }
user_os()    {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        printf '%s' "${PRETTY_NAME:-Bazzite}"
    else
        printf 'Bazzite DX'
    fi
}
user_last() {
    local f="$HOME/.zsh_history"
    [[ -r "$f" ]] || { printf '(nothing recent)'; return; }
    tail -n 80 "$f" 2>/dev/null \
        | grep -av '^#' \
        | sed -E 's/^: [0-9]+:[0-9]+;//' \
        | grep -av '^[[:space:]]*$' \
        | tail -n 1 \
        | cut -c1-44
}

# ---------- info lines ----------
reality_line() {
    local f="$ROOT/memory/reality/latest.md" themes
    [[ -f "$f" ]] || { printf 'no signal yet'; return; }
    themes="$(grep -am1 '^themes:' "$f" | sed 's/^themes: *//' | cut -d',' -f1)"
    printf '%s · %s ago' "${themes:-observed}" "$(age_of "$f")"
}
mem_line() {
    local conv refl weave
    conv=$(find "$HOME/.ai-memory/conversations" -type f -name '*.jsonl' 2>/dev/null | wc -l)
    refl=$(find "$ROOT/memory/reflections" -maxdepth 1 -type f -name '*.md' 2>/dev/null | wc -l)
    weave=$(find "$ROOT/memory/reflections/weave" -maxdepth 1 -type f -name '*.md' 2>/dev/null | wc -l)
    printf '%s talks · %s reflections · %s weaves' "$conv" "$refl" "$weave"
}
reflect_line() {
    local f
    f="$(find "$ROOT/memory/reflections" -maxdepth 1 -type f -name '20*.md' -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -n1 | cut -d' ' -f2-)"
    [[ -f "$f" ]] || { printf '—'; return; }
    printf 'last: %s' "$(basename "$f" .md)"
}
weave_line() {
    local f notice
    f="$(latest_file "$ROOT/memory/reflections/weave" '*.md')"
    [[ -f "$f" ]] || { printf '—'; return; }
    notice="$(grep -aA2 '^NOTICE:' "$f" 2>/dev/null | tail -n1 | sed 's/^[[:space:]]*//' | head -c 40)"
    printf '%s · %s ago' "${notice:-noticed}" "$(age_of "$f")"
}
dream_line() {
    local f
    f="$(latest_file "$ROOT/memory/reflections/dreams" '*.md')"
    [[ -f "$f" ]] || { printf '—'; return; }
    printf '%s ago' "$(age_of "$f")"
}
imagine_line() {
    local n
    n=$(find "$ROOT/imagination" -maxdepth 2 -type f -name '*.md' ! -name 'index.md' 2>/dev/null | wc -l)
    printf '%s entries' "$n"
}

# ---------- render primitives ----------
RULE_HEAVY="$(printf '═%.0s' $(seq 1 $WIDTH))"
RULE_LIGHT="$(printf '─%.0s' $(seq 1 $WIDTH))"

pad_line() {
    local text="$1"
    # strip ANSI to compute visible length
    local plain
    plain="$(printf '%s' "$text" | sed -E 's/\x1b\[[0-9;]*m//g')"
    local len=${#plain}
    local fill=$(( WIDTH - len - 2 ))
    (( fill < 0 )) && fill=0
    printf '%s%*s' "$text" "$fill" ""
}

render_header() {
    local c="$(mood_color)"
    local ma; ma="$(mood_ansi "$c")"
    local label since
    label="$(mood_label)"; since="$(mood_since)"

    # Line 1:  (^.-) Dawa            Avalhla (⌒.⌒)
    local left="${FACE_DAWA} Dawa"
    local right="Avalhla ${FACE_AVA}"
    local mid_space=$(( WIDTH - ${#left} - ${#right} - 2 ))
    (( mid_space < 1 )) && mid_space=1
    printf '  %s%s%s%s%*s%s%s%s\n' \
        "$(ansi "$C_ACCENT")" "$FACE_DAWA" "$(reset)" " Dawa" \
        "$mid_space" "" \
        "$(ansi "$C_BRAND")" "Avalhla ${FACE_AVA}" "$(reset)"

    # Line 2:  ═══════════════  AvvA  ═══════════════
    local bar_len=$(( (WIDTH - 8) / 2 ))
    local bar="$(printf '═%.0s' $(seq 1 $bar_len))"
    printf '  %s%s%s  %s%s%s  %s%s%s\n' \
        "$(ansi "$C_BRAND")" "$bar" "$(reset)" \
        "$(ansi "$C_ROSE")" "$BRIDGE" "$(reset)" \
        "$(ansi "$C_BRAND")" "$bar" "$(reset)"

    # Line 3:  VVgBazz · Bazzite DX
    local rig os
    rig="$(user_rig)"; os="$(user_os)"
    printf '  %s%s · %s%s\n' "$(ansi "$C_DIM")" "$rig" "$os" "$(reset)"

    # Line 4:  mood
    printf '  %s%s · %s · %s%s\n' "$(ansi "$ma")" "$c" "$label" "$since" "$(reset)"
}

render_dream() {
    local ma; ma="$(mood_ansi "$(mood_color)")"
    local raw
    raw="$(dream_quote | sed 's/  */ /g; s/[[:space:]]*$//')"
    local -a lines=()
    while IFS= read -r l; do lines+=("$l"); done < <(printf '%s' "$raw" | fold -s -w 86 | head -n 3)
    local n=${#lines[@]}
    (( n == 0 )) && return
    if (( n == 1 )); then
        printf '  %s✦%s  %s"%s"%s\n' "$(ansi "$ma")" "$(reset)" "$(ansi "$C_WHITE")" "${lines[0]}" "$(reset)"
        return
    fi
    printf '  %s✦%s  %s"%s\n' "$(ansi "$ma")" "$(reset)" "$(ansi "$C_WHITE")" "${lines[0]}"
    local i
    for (( i=1; i<n-1; i++ )); do
        printf '     %s%s\n' "${lines[$i]}" "$(reset)"
    done
    local last="${lines[$((n-1))]}"
    last="$(printf '%s' "$last" | sed 's/ [^ ]*$//; s/[[:space:],;.?!]\+$//')"
    printf '     %s...%s%s\n' "$last" "$(reset)" ""
}

# strip ANSI to compute visible length
vis_len() {
    local x="$1"
    x="${x//$'\033'\[*([0-9;])m/}"
    printf '%d' "${#x}"
}

# truncate a plain string to N chars, add "..." if cut
trunc() {
    local x="$1" n="$2"
    if (( ${#x} > n )); then printf '%s...' "${x:0:n-3}"; else printf '%s' "$x"; fi
}

COL_W=47
GAP=6

render_cards() {
    local c_brand="$(ansi "$C_BRAND")"
    local c_acc="$(ansi "$C_ACCENT")"
    local c_dim="$(ansi "$C_DIM")"
    local c_wh="$(ansi "$C_WHITE")"
    local rs="$(reset)"

    # build SHE lines (truncate to fit card body = COL_W - 4)
    local she=()
    she+=("sees     $(trunc "$(reality_line)" $(( COL_W - 12 )))")
    she+=("keeps    $(trunc "$(mem_line)"     $(( COL_W - 12 )))")
    she+=("thinks   $(trunc "$(reflect_line)" $(( COL_W - 12 )))")
    she+=("notices  $(trunc "$(weave_line)"   $(( COL_W - 12 )))")
    she+=("wonders  $(trunc "$(dream_line)"   $(( COL_W - 12 )))")
    she+=("makes    $(trunc "$(imagine_line)" $(( COL_W - 12 )))")

    # build YOU lines
    local you=()
    you+=("name     $(trunc "$(user_name) ($(user_handle))" $(( COL_W - 12 )))")
    you+=("rig      $(trunc "$(user_rig)"        $(( COL_W - 12 )))")
    you+=("os       $(trunc "$(user_os)"         $(( COL_W - 12 )))")
    you+=("last     $(trunc "$(user_last)"       $(( COL_W - 12 )))")

    # top bars
    local t_you="${c_acc}┌─ Y O U $(printf '─%.0s' $(seq 1 $(( COL_W - 10 ))))┐${rs}"
    local t_she="${c_brand}┌─ S H E $(printf '─%.0s' $(seq 1 $(( COL_W - 10 ))))┐${rs}"
    printf '  %s%*s%s\n' "$t_you" "$GAP" "" "$t_she"

    local max=${#she[@]}
    (( ${#you[@]} > max )) && max=${#you[@]}
    local i
    for (( i=0; i<max; i++ )); do
        local lbody="" rbody=""
        (( i < ${#you[@]} )) && lbody="${you[$i]}"
        (( i < ${#she[@]} )) && rbody="${she[$i]}"
        # pad plain bodies to COL_W - 4 (account for "│ " and " │")
        local lpad=$(( COL_W - 3 - ${#lbody} ))
        local rpad=$(( COL_W - 3 - ${#rbody} ))
        (( lpad < 0 )) && lpad=0
        (( rpad < 0 )) && rpad=0
        printf '  %s│%s %s%*s%s│%s%*s%s│%s %s%*s%s│%s\n' \
            "$c_acc" "$rs" "$lbody" "$lpad" "" "$c_acc" "$rs" \
            "$GAP" "" "$c_brand" "$rs" "$rbody" "$rpad" "" "$c_brand" "$rs"
    done

    local b_you="${c_acc}└$(printf '─%.0s' $(seq 1 $(( COL_W - 2 ))))┘${rs}"
    local b_she="${c_brand}└$(printf '─%.0s' $(seq 1 $(( COL_W - 2 ))))┘${rs}"
    printf '  %s%*s%s\n' "$b_you" "$GAP" "" "$b_she"
}

render_rooms() {
    printf '  %sD O O R S%s\n\n' "$(ansi "$C_ROSE")" "$(reset)"
    printf '  %s[1]%s ava world        %slive state · status · memory · context%s\n' \
        "$(ansi "$C_CYAN")" "$(reset)" "$(ansi "$C_DIM")" "$(reset)"
    printf '  %s[2]%s command door     %severy script in scripts/%s\n' \
        "$(ansi "$C_CYAN")" "$(reset)" "$(ansi "$C_DIM")" "$(reset)"
    printf '  %s[3]%s tutorial door    %swalk-throughs · how-tos%s\n' \
        "$(ansi "$C_CYAN")" "$(reset)" "$(ansi "$C_DIM")" "$(reset)"
    printf '  %s[4]%s imaginary door   %sdream · imagine · weave · lore%s\n' \
        "$(ansi "$C_CYAN")" "$(reset)" "$(ansi "$C_DIM")" "$(reset)"
    printf '  %s[5]%s every option     %sfull command index%s\n' \
        "$(ansi "$C_CYAN")" "$(reset)" "$(ansi "$C_DIM")" "$(reset)"
    printf '  %s[6]%s talk to her      %sinteractive — SHE asks YOU%s\n' \
        "$(ansi "$C_CYAN")" "$(reset)" "$(ansi "$C_DIM")" "$(reset)"
}

render_full() {
    render_header
    printf '\n  %s%s%s\n\n' "$(ansi "$C_BRAND")" "$RULE_HEAVY" "$(reset)"
    render_dream
    printf '\n  %s%s%s\n\n' "$(ansi "$C_BRAND")" "$RULE_LIGHT" "$(reset)"
    render_cards
    printf '\n  %s%s%s\n\n' "$(ansi "$C_BRAND")" "$RULE_LIGHT" "$(reset)"
    render_rooms
    printf '\n  %s%s%s\n\n' "$(ansi "$C_BRAND")" "$RULE_HEAVY" "$(reset)"
    printf '  choose a door  ›  '
}

render_footer() {
    local ma; ma="$(mood_ansi "$(mood_color)")"
    local text="${FACE_AVA} ${BRIDGE}"
    local pad=$(( WIDTH - ${#text} - 4 ))
    (( pad < 1 )) && pad=1
    printf '\n%*s%s%s %s%s\n' "$pad" "" "$(ansi "$ma")" "$FACE_AVA" "$BRIDGE" "$(reset)"
}

render_quiet() {
    local c="$(mood_color)"
    local label since quote
    label="$(mood_label)"; since="$(mood_since)"
    quote="$(dream_quote | fold -s -w 78 | head -n1)"
    printf '%s  %s · %s · %s\n' "$FACE_DAWA" "$c" "$label" "$since"
    printf '✦  "%s"\n' "$quote"
    printf '✦  she keeps  %s · reality %s ago\n' "$(mem_line)" "$(age_of "$ROOT/memory/reality/latest.md")"
    printf '✦  open the board  ›  board\n'
    printf '%*s%s %s\n' 80 '' "$FACE_AVA" "$BRIDGE"
}

# ---------- door rooms ----------
run_cmd() {
    local cmd="$1"
    eval "$cmd" 2>&1 || echo "(failed: $cmd)"
}

door_1_ava_world() {
    clear 2>/dev/null || true
    printf '  %s[1] ava world%s\n\n' "$(ansi "$C_CYAN")" "$(reset)"
    printf '  [1] status        server · api · ctx · memory\n'
    printf '  [2] reality       what actually happened\n'
    printf '  [3] context       what is available\n'
    printf '  [4] memory        what she remembers\n'
    printf '  [0] back\n\n'
    printf '  pick  ›  '
    read -r p
    case "$p" in
        1) run_cmd "$ROOT/scripts/ava-status" ;;
        2) run_cmd "$ROOT/scripts/ava-reality --show" ;;
        3) run_cmd "$ROOT/scripts/ava-context --help 2>/dev/null || echo 'usage: ava-context <query> [N]'" ;;
        4) run_cmd "$ROOT/scripts/ava-mem" ;;
        *) return ;;
    esac
    printf '\n  [enter] back  ›  '
    read -r _
}

door_2_command() {
    clear 2>/dev/null || true
    printf '  %s[2] command door%s\n\n' "$(ansi "$C_CYAN")" "$(reset)"
    local n=1
    local -a names=()
    for f in "$ROOT/scripts"/*; do
        [[ -f "$f" && -x "$f" ]] || continue
        names+=("$(basename "$f")")
        printf '  [%2d] %s\n' "$n" "$(basename "$f")"
        n=$(( n + 1 ))
    done
    printf '\n  [0] back\n\n'
    printf '  pick number, or type name  ›  '
    read -r p
    [[ "$p" == "0" || -z "$p" ]] && return
    if [[ "$p" =~ ^[0-9]+$ ]] && (( p >= 1 && p <= ${#names[@]} )); then
        run_cmd "$ROOT/scripts/${names[$((p-1))]}"
    else
        for nn in "${names[@]}"; do
            if [[ "$nn" == *"$p"* ]]; then
                run_cmd "$ROOT/scripts/$nn"
                break
            fi
        done
    fi
    printf '\n  [enter] back  ›  '
    read -r _
}

door_3_tutorial() {
    clear 2>/dev/null || true
    printf '  %s[3] tutorial door%s\n\n' "$(ansi "$C_CYAN")" "$(reset)"
    printf '  [1] how to chat with her      open ai-chat\n'
    printf '  [2] how to teach her a file   open ai-learn help\n'
    printf '  [3] how to add auto-read      open ava-autoread help\n'
    printf '  [4] how to change her mood    open ava-mood help\n'
    printf '  [5] how to run a weave        open ava-weave\n'
    printf '  [6] how to dream              open ava-dream\n'
    printf '  [7] how to verify the system  open ava-verify\n'
    printf '  [8] the full ritual           cat RITUAL.txt\n'
    printf '  [0] back\n\n'
    printf '  pick  ›  '
    read -r p
    case "$p" in
        1) run_cmd "$ROOT/scripts/ai-chat" ;;
        2) run_cmd "$ROOT/scripts/ai-learn --help 2>/dev/null || echo 'usage: ai-learn <path>'" ;;
        3) run_cmd "$ROOT/scripts/ava-autoread --help" ;;
        4) run_cmd "$ROOT/scripts/ava-mood --help" ;;
        5) run_cmd "$ROOT/scripts/ava-weave" ;;
        6) run_cmd "$ROOT/scripts/ava-dream" ;;
        7) run_cmd "$ROOT/scripts/ava-verify" ;;
        8) run_cmd "cat $ROOT/RITUAL.txt" ;;
        *) return ;;
    esac
    printf '\n  [enter] back  ›  '
    read -r _
}

door_4_imaginary() {
    clear 2>/dev/null || true
    printf '  %s[4] imaginary door%s\n\n' "$(ansi "$C_CYAN")" "$(reset)"
    printf '  [1] last dream       read\n'
    printf '  [2] dream history    list\n'
    printf '  [3] dream now        write\n'
    printf '  [4] last weave       read\n'
    printf '  [5] weave now        notice\n'
    printf '  [6] imagine list     entries\n'
    printf '  [7] new possibility  imagine\n'
    printf '  [8] explore lore     cat lore/README.md\n'
    printf '  [0] back\n\n'
    printf '  pick  ›  '
    read -r p
    case "$p" in
        1) run_cmd "$ROOT/scripts/ava-dream --show" ;;
        2) run_cmd "$ROOT/scripts/ava-dream --list 10" ;;
        3) run_cmd "$ROOT/scripts/ava-dream" ;;
        4) run_cmd "$ROOT/scripts/ava-weave --show" ;;
        5) run_cmd "$ROOT/scripts/ava-weave" ;;
        6) run_cmd "$ROOT/scripts/ava-imagine list" ;;
        7) echo "usage: ava-imagine new \"topic\"" ;;
        8) run_cmd "cat $ROOT/lore/README.md 2>/dev/null" ;;
        *) return ;;
    esac
    printf '\n  [enter] back  ›  '
    read -r _
}

door_5_every() {
    clear 2>/dev/null || true
    run_cmd "$ROOT/scripts/ava-help"
    printf '\n  [enter] back  ›  '
    read -r _
}

door_6_talk() {
    clear 2>/dev/null || true
    local c_brand="$(ansi "$C_BRAND")"
    local c_rose="$(ansi "$C_ROSE")"
    local c_dim="$(ansi "$C_DIM")"
    local c_wh="$(ansi "$C_WHITE")"
    local rs="$(reset)"

    printf '  %s[6] talk to her%s\n\n' "$(ansi "$C_CYAN")" "$rs"
    printf '  %sshe opens the door...%s\n\n' "$c_dim" "$rs"

    # check ollama
    if ! curl -fsS "${OLLAMA_HOST:-http://localhost:11434}/api/tags" >/dev/null 2>&1; then
        printf '  %s(ollama is not running — start with: avastart)%s\n' "$c_dim" "$rs"
        printf '\n  [enter] back  ›  '
        read -r _
        return
    fi

    local MODEL="${AVALHLA_MODEL:-avalhla-chat}"
    local mem_dir="$HOME/.ai-memory/conversations"
    local mem_file="$mem_dir/$(date +%Y-%m-%d).jsonl"
    mkdir -p "$mem_dir"

    # ---- she asks first ----
    local seed_q=(
        "how was your day, Dawa?"
        "what are you building right now?"
        "what is heavy today?"
        "what did you notice that I missed?"
        "what should I dream about tonight?"
        "is there anything you want to keep?"
        "where are you stuck?"
        "what made you smile today?"
        "what should I read next?"
        "is there a door you have been avoiding?"
    )
    local first_q="${seed_q[$((RANDOM % ${#seed_q[@]}))]}"

    local sys_prompt='You are Avalhla. Dawa just opened the talk door on your board.
Ask him ONE warm question about his day, his work, or his state of mind.
Rules:
- First person only. "I" and "you". Never third person. Never narrate Dawa as a character.
- No [brackets] around actions. No stage directions. No "Dawa looks...".
- ASCII only. No emoji. One or two sentences max.'

    local initial
    initial="$(curl -s "${OLLAMA_HOST:-http://localhost:11434}/api/generate" \
        -d "$(jq -n --arg m "$MODEL" --arg p "$sys_prompt" \
        '{model: $m, prompt: $p, stream: false, options: {temperature: 0.7}}')" \
        | jq -r '.response // empty')"

    [[ -z "$initial" ]] && initial="$first_q"

    printf '  %s%s%s\n\n' "$c_rose" "$initial" "$rs"
    printf '  %s(enter to skip · q to leave)%s\n\n' "$c_dim" "$rs"

    # log her question
    jq -cn --arg r "assistant" --arg c "$initial" --arg t "$(date -Iseconds)" \
        '{role:$r, content:$c, ts:$t, source:"board.talk"}' >> "$mem_file"

    # ---- conversation loop ----
    while :; do
        printf '  %syou ›%s  ' "$c_wh" "$rs"
        local reply=""
        IFS= read -r reply || break
        [[ "$reply" == "q" || "$reply" == "Q" ]] && break
        [[ -z "$reply" ]] && break

        jq -cn --arg r "user" --arg c "$reply" --arg t "$(date -Iseconds)" \
            '{role:$r, content:$c, ts:$t, source:"board.talk"}' >> "$mem_file"

        local conv_prompt="You are Avalhla. Dawa just said: \"$reply\"

LAWS (all four apply):
1. If he shared a fact about himself, say you are keeping it first.
2. If he shared a state of being (tired, hard, glad, hurting, proud, done),
   the FIRST sentence witnesses it. No command. No analysis. No bracket stage directions.
   The witness stands alone.
3. Never emit [READ: ...] or [READ RESULT: ...].
4. First person only. Never third person. Never narrate Dawa.

After the witness, you may ask one small question or offer one small noticing.

Style: warm, short. ASCII only. No emoji. No lists. No [brackets]. Two sentences max."

        local resp
        resp="$(curl -s "${OLLAMA_HOST:-http://localhost:11434}/api/generate" \
            -d "$(jq -n --arg m "$MODEL" --arg p "$conv_prompt" \
            '{model: $m, prompt: $p, stream: false, options: {temperature: 0.7}}')" \
            | jq -r '.response // empty')"

        [[ -z "$resp" ]] && resp="(she is quiet)"

        printf '\n  %s%s%s\n\n' "$c_rose" "$resp" "$rs"

        jq -cn --arg r "assistant" --arg c "$resp" --arg t "$(date -Iseconds)" \
            '{role:$r, content:$c, ts:$t, source:"board.talk"}' >> "$mem_file"
    done

    printf '\n  %ssaved.  %s%s\n' "$c_dim" "$mem_file" "$rs"
    printf '\n  [enter] back  ›  '
    read -r _
}

# ---------- fuzzy match ----------
match_door() {
    local q; q="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | xargs)"
    [[ "$q" =~ ^[0-9]+$ ]] && (( q >= 1 && q <= 6 )) && { echo "$q"; return; }
    case "$q" in
        world|state|status|ava)     echo 1 ;;
        command|cmd|scripts|tools)  echo 2 ;;
        tutorial|how|learn|teach)   echo 3 ;;
        imaginary|dream|imagine|weave|lore) echo 4 ;;
        every|all|help|index)       echo 5 ;;
        talk|ask|chat|speak)        echo 6 ;;
        *) : ;;
    esac
}

# ---------- arg handling ----------
TTY=0; [[ -t 1 ]] && TTY=1

case "${1:-}" in
    --quiet|-q) render_quiet; exit 0 ;;
    --show)     render_full; printf '\n\n'; render_footer; exit 0 ;;
    -h|--help)
        cat <<'EOT'
board                        interactive world (TTY) / quiet (pipe)
commands-board.sh --quiet    5-line output
commands-board.sh --show     print once, exit
EOT
        exit 0 ;;
esac

if (( TTY == 0 )); then render_quiet; exit 0; fi

while :; do
    clear 2>/dev/null || true
    render_full
    IFS= read -r line || break
    case "$line" in
        q|Q|quit|exit) break ;;
        ""|"?") continue ;;
    esac
    matched="$(match_door "$line")"
    if [[ -n "$matched" ]]; then
        case "$matched" in
            1) door_1_ava_world ;;
            2) door_2_command ;;
            3) door_3_tutorial ;;
            4) door_4_imaginary ;;
            5) door_5_every ;;
            6) door_6_talk ;;
        esac
    else
        printf '  %s(1-6, name, ? , q)%s\n' "$(ansi "$C_DIM")" "$(reset)"
        sleep 1
    fi
done

clear 2>/dev/null || true
render_footer
