#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════╗
# ║  verify-before-work.sh                                           ║
# ║  VVgBazz pre-flight — run before every work session              ║
# ║                                                                  ║
# ║  Usage:  ./verify-before-work.sh [OPTIONS]                       ║
# ║                                                                  ║
# ║    --fix          auto-repair safe issues                        ║
# ║    --quiet        only show failures + warnings                  ║
# ║    --json         emit JSON                                      ║
# ║    --no-net       skip network checks                            ║
# ║    --fast         skip slow checks                               ║
# ║    --section N    run only section N                             ║
# ║    --list         list sections and exit                         ║
# ║    -h, --help     show help                                      ║
# ╚══════════════════════════════════════════════════════════════════╝
set -uo pipefail

EXPECTED_BRANCH="v0.3-restructure"
EXPECTED_CTX=16384
MIN_FREE_GB=20
OLLAMA_API="http://127.0.0.1:11434/api/tags"
OLLAMA_MODEL="deepseek-r1-tool-14b-16k"
LOG="$HOME/.ollama/serve.log"

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    BOLD=$'\e[1m';  DIM=$'\e[2m'
    RED=$'\e[31m';  GREEN=$'\e[32m'; YELLOW=$'\e[33m'
    BLUE=$'\e[34m'; MAGENTA=$'\e[35m'; CYAN=$'\e[36m'
    WHITE=$'\e[97m'; GREY=$'\e[90m'
    BG_RED=$'\e[41m'; BG_GREEN=$'\e[42m'; BG_YELLOW=$'\e[43m'
    RESET=$'\e[0m'
else
    BOLD=""; DIM=""; RED=""; GREEN=""; YELLOW=""; BLUE=""; MAGENTA=""
    CYAN=""; WHITE=""; GREY=""; BG_RED=""; BG_GREEN=""; BG_YELLOW=""; RESET=""
fi

FIX=0; QUIET=0; JSON=0; NO_NET=0; FAST=0; SECTION=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --fix)      FIX=1 ;;
        --quiet|-q) QUIET=1 ;;
        --json)     JSON=1; QUIET=1 ;;
        --no-net)   NO_NET=1 ;;
        --fast)     FAST=1 ;;
        --section)  SECTION="${2:-}"; shift ;;
        --list)     grep -oE '^#  [0-9]+\. .*' "$0" | sed 's/^#  //'; exit 0 ;;
        -h|--help)  sed -n '2,20p' "$0" | sed 's/^#  *//; s/ *║$//'; exit 0 ;;
        *) echo "unknown option: $1" >&2; exit 2 ;;
    esac
    shift
done

PASSES=0; WARNS=0; FAILS=0; SKIPS=0
declare -a FAIL_LIST=() WARN_LIST=()
START_TIME=$(date +%s)
JSON_BUFFER=""

jline() {
    local status="$1" section="$2" name="$3" detail="$4"
    JSON_BUFFER+="{\"status\":\"$status\",\"section\":\"$section\",\"name\":\"$name\",\"detail\":$(printf '%s' "$detail" | jq -Rs . 2>/dev/null || echo '""')},"
}
_pass()  { PASSES=$((PASSES+1));      [[ $QUIET -eq 1 ]] && { jline pass "$CUR_SEC" "$1" "${2:-}"; return; }
           echo -e "  ${GREEN}✓${RESET} $1${2:+ ${DIM}· $2${RESET}}";       jline pass "$CUR_SEC" "$1" "${2:-}"; }
_warn()  { WARNS=$((WARNS+1));  WARN_LIST+=("$1"); [[ $QUIET -eq 1 ]] && { jline warn "$CUR_SEC" "$1" "${2:-}"; return; }
           echo -e "  ${YELLOW}⚠${RESET} $1${2:+ ${DIM}· $2${RESET}}";       jline warn "$CUR_SEC" "$1" "${2:-}"; }
_fail()  { FAILS=$((FAILS+1));  FAIL_LIST+=("$1"); [[ $QUIET -eq 1 ]] && { jline fail "$CUR_SEC" "$1" "${2:-}"; return; }
           echo -e "  ${RED}✗${RESET} $1${2:+ ${DIM}· $2${RESET}}";          jline fail "$CUR_SEC" "$1" "${2:-}"; }
_skip()  { SKIPS=$((SKIPS+1)); [[ $QUIET -eq 1 ]] && return
           echo -e "  ${GREY}·${RESET} ${DIM}$1${2:+ · $2}${RESET}";          jline skip "$CUR_SEC" "$1" "${2:-}"; }
_info()  { [[ $QUIET -eq 1 ]] && return; echo -e "  ${CYAN}ℹ${RESET} $1"; }
_hint()  { [[ $QUIET -eq 1 ]] && return; echo -e "    ${GREY}↳${RESET} ${DIM}$1${RESET}"; }
_fix()   { [[ $QUIET -eq 1 ]] && return; echo -e "    ${MAGENTA}🔧${RESET} ${DIM}$1${RESET}"; }

CUR_SEC=""; SEC_NUM=0; SKIP_SECTION=0
_section() {
    SEC_NUM=$((SEC_NUM+1))
    local num="$1" title="$2"
    CUR_SEC="$num. $title"
    if [[ -n "$SECTION" && "$num" != "$SECTION" ]]; then SKIP_SECTION=1; else SKIP_SECTION=0; fi
    [[ $QUIET -eq 1 ]] && return
    echo ""
    echo -e "${BOLD}${BLUE}╭─ ${WHITE}$(printf '%02d' $num)${BLUE} · ${CYAN}${title}${RESET}"
}
_section_end() { [[ $QUIET -eq 1 ]] && return; echo -e "${BOLD}${BLUE}╰────────────────────────────────────────────────────────────${RESET}"; }
guard() { [[ "$SKIP_SECTION" -eq 1 ]] && return 1; return 0; }

need_cmd() { command -v "$1" >/dev/null 2>&1; }
have_sudo_nopass() { sudo -n true </dev/null >/dev/null 2>&1; }
in_container() {

    [[ -f /run/.containerenv ]] || [[ -f /.dockerenv ]] || \
    grep -qE 'docker|podman|libpod|containerd' /proc/1/cgroup 2>/dev/null
}

print_banner() {
    [[ $QUIET -eq 1 ]] && return
    local now user host kernel os_name
    now=$(date '+%Y-%m-%d %H:%M:%S'); user=$(whoami); host=$(hostname)
    kernel=$(uname -r)
    os_name=$(. /etc/os-release 2>/dev/null && echo "$PRETTY_NAME" || echo "Linux")
    echo ""
    echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════════════╗"
    echo -e "║  ${WHITE}🛡️   VVgBazz pre-flight check${CYAN}                                     ║"
    echo -e "╠══════════════════════════════════════════════════════════════════╣"
    printf "${CYAN}║${RESET}  ${BOLD}%-10s${RESET}  %-50s${CYAN}║${RESET}\n" "host"   "$host"
    printf "${CYAN}║${RESET}  ${BOLD}%-10s${RESET}  %-50s${CYAN}║${RESET}\n" "user"   "$user"
    printf "${CYAN}║${RESET}  ${BOLD}%-10s${RESET}  %-50s${CYAN}║${RESET}\n" "os"     "${os_name:0:50}"
    printf "${CYAN}║${RESET}  ${BOLD}%-10s${RESET}  %-50s${CYAN}║${RESET}\n" "kernel" "$kernel"
    printf "${CYAN}║${RESET}  ${BOLD}%-10s${RESET}  %-50s${CYAN}║${RESET}\n" "time"   "$now"
    [[ $FIX    -eq 1 ]] && printf "${CYAN}║${RESET}  ${BOLD}%-10s${RESET}  %-50s${CYAN}║${RESET}\n" "mode" "${MAGENTA}--fix enabled${RESET}"
    [[ $FAST   -eq 1 ]] && printf "${CYAN}║${RESET}  ${BOLD}%-10s${RESET}  %-50s${CYAN}║${RESET}\n" "mode" "${YELLOW}--fast enabled${RESET}"
    [[ $NO_NET -eq 1 ]] && printf "${CYAN}║${RESET}  ${BOLD}%-10s${RESET}  %-50s${CYAN}║${RESET}\n" "mode" "${YELLOW}--no-net enabled${RESET}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════╝${RESET}"
}

check_repo() {
    _section 1 "Repo location"
    guard || { _section_end; return; }
    local candidates=(
        "$HOME/projects/cheatsheets"
        "$HOME/cheatsheets"
        "/var/home/VVgbon/projects/cheatsheets"
        "/var/home/VVgbon/cheatsheets"
    )
    REPO=""
    for c in "${candidates[@]}"; do [[ -d "$c/.git" ]] && { REPO="$c"; break; }; done
    if [[ -z "$REPO" ]]; then
        REPO=$(find "$HOME" -maxdepth 4 -type d -name "cheatsheets" -exec test -d "{}/.git" \; -print -quit 2>/dev/null || true)
    fi
    if [[ -z "$REPO" ]]; then
        _fail "repo not found" "searched: ~/projects, ~/"
        _hint "find ~ -type d -name cheatsheets 2>/dev/null"
        _section_end; return
    fi
    _pass "found at ${REPO/#$HOME/~}"
    cd "$REPO" || { _fail "cannot cd into repo"; _section_end; return; }
    local branch dirty
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "?")
    if [[ "$branch" == "$EXPECTED_BRANCH" ]]; then _pass "on branch '$branch'"
    else _warn "on branch '$branch'" "expected '$EXPECTED_BRANCH'"; _hint "git switch $EXPECTED_BRANCH"; fi
    dirty=$(git status --porcelain 2>/dev/null | wc -l)
    if [[ "$dirty" -eq 0 ]]; then _pass "working tree clean"
    else _warn "$dirty uncommitted change(s)"; _hint "git status -sb"; fi
    if git rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1; then
        local ab ahead behind
        ab=$(git rev-list --left-right --count '@{u}...HEAD' 2>/dev/null || echo "0	0")
        behind=${ab%$'\t'*}; ahead=${ab#*$'\t'}
        [[ "$ahead"  -gt 0 ]] && _warn "$ahead commit(s) ahead of origin"
        [[ "$behind" -gt 0 ]] && _warn "$behind commit(s) behind origin"
        [[ "$ahead" -eq 0 && "$behind" -eq 0 ]] && _pass "in sync with origin"
    fi
    _info "last commit: $(git log -1 --format='%h %s' 2>/dev/null | cut -c1-70)"
    _section_end
}

check_private() {
    _section 2 "Private files (must be gitignored)"
    guard || { _section_end; return; }
    [[ -z "${REPO:-}" ]] && { _skip "repo not located — skipping"; _section_end; return; }
    local files=(private/D42k.md private/Dawa.txt)
    for f in "${files[@]}"; do
        if [[ -f "$f" ]]; then
            _pass "$f exists"
            if git check-ignore -q "$f" 2>/dev/null; then _pass "  ↳ gitignored"
            else _fail "$f is TRACKED" "run: git rm --cached $f"; fi
            local perms; perms=$(stat -c '%a' "$f" 2>/dev/null || echo "?")
            if [[ "$perms" == "600" || "$perms" == "640" ]]; then _pass "  ↳ permissions $perms"
            else
                _warn "  ↳ permissions $perms" "want 600"
                [[ $FIX -eq 1 ]] && chmod 600 "$f" && _fix "chmod 600 $f"
            fi
        else _warn "$f missing"; fi
    done
    local leaked
    leaked=$(git ls-files -- '*.md' '*.sh' '*.txt' 2>/dev/null \
        | grep -v '^private/' \
        | grep -v '\.example$' \
        | xargs -r grep -nE '(ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|BEGIN (RSA|OPENSSH|ED25519) PRIVATE KEY)' 2>/dev/null \
        | head -10 || true)
    if [[ -z "$leaked" ]]; then _pass "no secrets in tracked files"
    else _fail "SECRETS in tracked files:"; echo "$leaked" | sed 's/^/      /'; fi
    _section_end
}

check_filesystem() {
    _section 3 "Filesystem"
    guard || { _section_end; return; }
    local root_fs; root_fs=$(findmnt -no FSTYPE / 2>/dev/null || echo "?")
    case "$root_fs" in
        composefs|overlay) _pass "root = $root_fs" "read-only, correct for Bazzite" ;;
        *) _warn "root = $root_fs" "expected composefs or overlay" ;;
    esac
    local var_fs; var_fs=$(findmnt -no FSTYPE /var 2>/dev/null || echo "?")
    if [[ "$var_fs" == "btrfs" ]]; then _pass "/var = btrfs"
    else _fail "/var = $var_fs" "expected btrfs"; fi
    if command -v df >/dev/null; then
        local avail; avail=$(df -BG --output=avail /var 2>/dev/null | tail -1 | tr -d 'G ' || echo 0)
        if [[ "$avail" -lt "$MIN_FREE_GB" ]]; then _warn "only ${avail}G free on /var" "want ≥${MIN_FREE_GB}G"
        else _pass "${avail}G free on /var"; fi
    fi

    if command -v df >/dev/null; then
        local ifree; ifree=$(df -i --output=ipcent /var 2>/dev/null | tail -1 | tr -d ' %' || echo 0)
        if [[ "$ifree" -gt 90 ]]; then _warn "inode usage at ${ifree}%"
        else _pass "inodes at ${ifree}%"; fi
    fi
    _section_end
}

check_ollama() {
    _section 4 "Ollama / DeepSeek-R1 16K"
    guard || { _section_end; return; }
    if ! need_cmd ollama; then _fail "ollama binary not found"; _section_end; return; fi
    local ov; ov=$(ollama --version 2>/dev/null | head -1 | cut -c1-60 || echo "?")
    _pass "ollama installed" "$ov"
    if ! curl -fsS "$OLLAMA_API" >/dev/null 2>&1; then
        _warn "server not running"
        if [[ $FIX -eq 1 ]]; then
            _fix "starting ollama serve at ${EXPECTED_CTX}"
            pkill -f "ollama serve" 2>/dev/null || true; sleep 1
            OLLAMA_CONTEXT_LENGTH="$EXPECTED_CTX" nohup ollama serve > "$LOG" 2>&1 &
            for _ in $(seq 1 30); do curl -fsS "$OLLAMA_API" >/dev/null 2>&1 && break; sleep 1; done
        else
            _hint "make ctx-16k   (or: OLLAMA_CONTEXT_LENGTH=16384 ollama serve &)"
        fi
    fi
    if curl -fsS "$OLLAMA_API" >/dev/null 2>&1; then
        _pass "server reachable"
        local models
        models=$(curl -s "$OLLAMA_API" | jq -r '.models[].name' 2>/dev/null || echo "")
        if echo "$models" | grep -q "deepseek-r1"; then
            _pass "DeepSeek-R1 present"
            echo "$models" | grep "deepseek-r1" | sed 's/^/      · /'
        else _warn "no DeepSeek-R1 model"; _hint "ollama pull deepseek-r1:14b"; fi
        local ctx
        ctx=$(pgrep -af llama-server 2>/dev/null | grep -o '\-c [0-9]*' | awk '{print $2}' | head -1 || true)
        if [[ -z "$ctx" ]]; then _skip "no llama-server running" "ctx applies on next 'ollama run'"
        elif [[ "$ctx" -ge "$EXPECTED_CTX" ]]; then _pass "context = $ctx  ✅"
        else
            _fail "context = $ctx" "want ≥${EXPECTED_CTX}"
            if [[ $FIX -eq 1 ]]; then
                _fix "restarting server at ${EXPECTED_CTX}"
                pkill -f "ollama serve" 2>/dev/null || true; sleep 2
                OLLAMA_CONTEXT_LENGTH="$EXPECTED_CTX" nohup ollama serve > "$LOG" 2>&1 &
                for _ in $(seq 1 30); do curl -fsS "$OLLAMA_API" >/dev/null 2>&1 && break; sleep 1; done
            else _hint "make fix   (auto-restarts at 16384)"; fi
        fi
        if need_cmd nvidia-smi; then
            local n; n=$(nvidia-smi --query-compute-apps=process_name --format=csv,noheader 2>/dev/null | grep -ci ollama || true)
            if [[ "$n" -gt 0 ]]; then _pass "GPU in use by ollama ($n process)"
            else _skip "no ollama GPU process" "only checkable while a model runs"; fi
        fi
    fi
    _section_end
}

check_nvidia() {
    _section 5 "NVIDIA / RTX 3060"
    guard || { _section_end; return; }

    if ! need_cmd nvidia-smi; then
        _fail "nvidia-smi not found"
        _section_end; return
    fi

    if ! nvidia-smi >/dev/null 2>&1; then
        _fail "nvidia-smi exists but fails" "driver broken?"
        _hint "sudo systemctl restart nvidia-persistenced"
        _section_end; return
    fi

    local name drv temp pwr plim mused mtotal
    name=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1 | xargs)
    drv=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null | head -1 | xargs)
    temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -1 | xargs)
    pwr=$(nvidia-smi --query-gpu=power.draw --format=csv,noheader,nounits 2>/dev/null | head -1 | xargs)
    plim=$(nvidia-smi --query-gpu=power.limit --format=csv,noheader,nounits 2>/dev/null | head -1 | xargs)
    mused=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits 2>/dev/null | head -1 | xargs)
    mtotal=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | head -1 | xargs)

    _pass "GPU online" "$name"
    _pass "driver $drv"
    _pass "temp ${temp}°C"
    _info "power draw: ${pwr}W"

    if [[ -n "$plim" ]] && [[ "$plim" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        local pl_int=${plim%.*}
        if [[ "$pl_int" -ge 160 && "$pl_int" -le 180 ]]; then
            _pass "power limit ${plim}W"
        else
            _warn "power limit ${plim}W" "expected ~170W"
        fi
    else
        _skip "power limit" "could not read"
    fi

    if [[ -n "$mused" && -n "$mtotal" ]] && [[ "$mused" =~ ^[0-9]+$ ]] && [[ "$mtotal" =~ ^[0-9]+$ ]]; then
        local pct=$(( mused * 100 / mtotal ))
        if [[ $pct -gt 85 ]]; then
            _warn "VRAM ${mused}/${mtotal} MiB (${pct}%)" "close apps before big jobs"
        else
            _pass "VRAM ${mused}/${mtotal} MiB (${pct}%)"
        fi
    else
        _skip "VRAM reading" "could not parse"
    fi

    if systemctl is-active --quiet nvidia-persistenced; then
        _pass "nvidia-persistenced active"
    else
        _warn "nvidia-persistenced not active"
        _hint "sudo systemctl start nvidia-persistenced"
    fi

    _section_end
}

check_audio() {
    _section 6 "Audio (PipeWire)"
    guard || { _section_end; return; }
    local svc
    for svc in pipewire pipewire-pulse wireplumber; do
        if systemctl --user is-active --quiet "$svc.service" 2>/dev/null; then _pass "$svc.service running"
        else _warn "$svc.service not running"; fi
    done
    if need_cmd pactl; then
        local expected=(game_output voice_output browser_output music_output)
        local actual; actual=$(pactl list short sinks 2>/dev/null | awk '{print $2}')
        for s in "${expected[@]}"; do
            if echo "$actual" | grep -q "$s"; then _pass "virtual sink: $s"
            else _warn "virtual sink missing: $s"; fi
        done
        _info "default sink: $(pactl get-default-sink 2>/dev/null || echo '?')"
    else _skip "pactl not available"; fi
    _section_end
}

check_session() {
    _section 7 "Session / display"
    guard || { _section_end; return; }
    if [[ "${XDG_SESSION_TYPE:-}" == "wayland" ]]; then _pass "Wayland session"
    else _warn "session = '${XDG_SESSION_TYPE:-unknown}'" "expected wayland"; fi
    if pgrep -x kwin_wayland >/dev/null 2>&1; then _pass "kwin_wayland running"
    else _fail "kwin_wayland not running"; fi
    if pgrep -x Xwayland >/dev/null 2>&1; then _pass "Xwayland running"
    else _skip "Xwayland not running" "fine unless you need X11 apps"; fi
    if [[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then _pass "session dbus active"
    else _warn "no session dbus"; fi
    _section_end
}

check_network() {
    _section 8 "Network"
    guard || { _section_end; return; }
    if need_cmd ip; then
        local active; active=$(ip -brief addr show 2>/dev/null | awk '$2=="UP" && $1!="lo" {print $1; exit}')
        if [[ -n "$active" ]]; then
            local ip4; ip4=$(ip -brief -4 addr show "$active" 2>/dev/null | awk '{print $3}' | head -1)
            _pass "interface $active up" "$ip4"
        else _fail "no non-loopback interface is UP"; fi
    fi
    if [[ $NO_NET -eq 1 ]]; then _skip "network reachability" "--no-net"
    else
        if curl -fsS --max-time 4 https://1.1.1.1 >/dev/null 2>&1; then _pass "outbound HTTPS reachable"
        else _warn "outbound HTTPS to 1.1.1.1 failed"; fi
        if curl -fsS --max-time 4 https://api.github.com >/dev/null 2>&1; then _pass "GitHub API reachable"
        else _warn "GitHub API unreachable"; fi
        if need_cmd getent; then
            if getent hosts github.com >/dev/null 2>&1; then _pass "DNS resolving"
            else _fail "DNS resolution failed"; fi
        fi
    fi
    _section_end
}

check_git_github() {
    _section 9 "Git & GitHub"
    guard || { _section_end; return; }
    if need_cmd gh; then
        local who; who=$(gh api user --jq .login 2>/dev/null || true)
        if [[ -n "$who" ]]; then _pass "gh authenticated as $who"
        else _warn "gh not authenticated"; _hint "gh auth login"; fi
    else _warn "gh CLI not installed"; fi
    local key="$HOME/.ssh/id_ed25519"
    if [[ -f "$key" ]]; then
        _pass "SSH key present" "~/.ssh/id_ed25519"
        local perms; perms=$(stat -c '%a' "$key" 2>/dev/null || echo "?")
        if [[ "$perms" == "600" ]]; then _pass "  ↳ permissions 600"
        else
            _warn "  ↳ permissions $perms" "want 600"
            [[ $FIX -eq 1 ]] && chmod 600 "$key" && _fix "chmod 600 $key"
        fi
    else _warn "no SSH key at ~/.ssh/id_ed25519"; fi
    local gname gemail
    gname=$(git config --global user.name 2>/dev/null || true)
    gemail=$(git config --global user.email 2>/dev/null || true)
    if [[ -n "$gname" && -n "$gemail" ]]; then _pass "git identity: $gname <$gemail>"
    else _warn "git identity incomplete"; fi
    _section_end
}

check_dev() {
    _section 10 "Dev container (coding-lab)"
    guard || { _section_end; return; }

    if in_container; then
        _pass "running INSIDE a container"
        [[ -f /etc/os-release ]] && _info "$(. /etc/os-release && echo "$PRETTY_NAME")"
    fi

    if ! need_cmd distrobox; then
        _warn "distrobox not installed"
        _hint "brew install distrobox"
        _section_end; return
    fi

    # distrobox list format (Fedora 44, 2026):
    #   ID           | NAME         | STATUS       | IMAGE
    #   b7b567681a6b | coding-lab   | Up 18 min    | ...
    # Name is in column 2 (fields split on ' | ', but awk -F' *\\| *' handles both).
    local dlist
    dlist=$(distrobox list 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g')

    local status
    status=$(echo "$dlist" | awk -F' *\\| *' '$2=="coding-lab" {print $3; exit}')

    if [[ -n "$status" ]]; then
        _pass "coding-lab exists"
        _info "  ↳ status: $status"
        if in_container; then
            _pass "  ↳ currently inside it"
        else
            _skip "  ↳ not inside it" "enter: make lab"
        fi
    else
        # Check if it exists under ANY state (including Exited)
        if echo "$dlist" | awk -F' *\\| *' '{print $2}' | grep -qx "coding-lab"; then
            _pass "coding-lab exists (not currently running)"
            _hint "start it with: distrobox enter coding-lab"
        else
            _warn "coding-lab not found"
            _hint "distrobox create -n coding-lab -i fedora:44 -Y"
        fi
    fi

    _section_end
}

check_tooling() {
    _section 11 "Core tooling"
    guard || { _section_end; return; }
    local tools=(git jq curl python3 rg fzf)
    local missing=()
    for t in "${tools[@]}"; do
        if need_cmd "$t"; then _pass "$t"
        else _warn "$t missing"; missing+=("$t"); fi
    done
    if [[ ${#missing[@]} -gt 0 ]] && in_container; then
        _hint "install: sudo dnf install -y ${missing[*]}"
    elif [[ ${#missing[@]} -gt 0 ]]; then
        _hint "on host, prefer installing inside coding-lab"
    fi
    need_cmd make       && _pass "make"       || _skip "make"
    need_cmd shellcheck && _pass "shellcheck" || _skip "shellcheck (optional)"
    _section_end
}

check_errors() {
    _section 12 "Recent errors (last 30 min)"
    guard || { _section_end; return; }
    [[ $FAST -eq 1 ]] && { _skip "journal check" "--fast"; _section_end; return; }
    if need_cmd journalctl; then
        local errs
        # Filter out benign noise:
        #   - sudo[...] "password is required" (audit log, not an error)
        #   - pam_systemd Varlink PermissionDenied (known Bazzite quirk)
        #   - systemd-tmpfiles group/user lookups (harmless during boot)
        errs=$(journalctl -p err --since "30 min ago" --no-pager -q 2>/dev/null \
               | grep -vE 'sudo\[[0-9]+\]:.*password is required' \
               | grep -vE 'pam_systemd\(sudo:session\)' \
               | grep -vE 'Failed to resolve (user|group)' \
               | tail -n 10 || true)
        if [[ -z "$errs" ]]; then _pass "no errors in the last 30 min"
        else
            local n; n=$(echo "$errs" | wc -l)
            _warn "$n error line(s) in the last 30 min:"
            echo "$errs" | sed 's/^/      /'
        fi
    else _skip "journalctl not available"; fi
    _section_end
}

print_summary() {
    local dur=$(( $(date +%s) - START_TIME ))
    if [[ $JSON -eq 1 ]]; then
        JSON_BUFFER="${JSON_BUFFER%,}"
        printf '{"passes":%d,"warnings":%d,"failures":%d,"skips":%d,"duration_sec":%d,"results":[%s]}\n' \
            "$PASSES" "$WARNS" "$FAILS" "$SKIPS" "$dur" "$JSON_BUFFER"
        return
    fi
    echo ""
    echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════════════╗"
    printf "${CYAN}║${RESET}  ${BOLD}%-14s${RESET}  %s${CYAN}║${RESET}\n" "passes"   "${GREEN}${PASSES}${RESET}"
    printf "${CYAN}║${RESET}  ${BOLD}%-14s${RESET}  %s${CYAN}║${RESET}\n" "warnings" "${YELLOW}${WARNS}${RESET}"
    printf "${CYAN}║${RESET}  ${BOLD}%-14s${RESET}  %s${CYAN}║${RESET}\n" "failures" "${RED}${FAILS}${RESET}"
    printf "${CYAN}║${RESET}  ${BOLD}%-14s${RESET}  %s${CYAN}║${RESET}\n" "skipped"  "${GREY}${SKIPS}${RESET}"
    printf "${CYAN}║${RESET}  ${BOLD}%-14s${RESET}  %s${CYAN}║${RESET}\n" "duration" "${dur}s"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    if [[ $FAILS -eq 0 && $WARNS -eq 0 ]]; then
        echo -e "${BG_GREEN}${BOLD}${WHITE}   ✓ ALL CLEAR — safe to start work   ${RESET}"; echo ""
    elif [[ $FAILS -eq 0 ]]; then
        echo -e "${BG_YELLOW}${BOLD}${WHITE}   ⚠ ${WARNS} warning(s) — review before heavy work   ${RESET}"; echo ""
        echo -e "${BOLD}${YELLOW}  Warnings:${RESET}"
        for w in "${WARN_LIST[@]}"; do echo -e "    ${YELLOW}•${RESET} $w"; done
        echo ""
    else
        echo -e "${BG_RED}${BOLD}${WHITE}   ✗ ${FAILS} failure(s) — DO NOT START WORK   ${RESET}"; echo ""
        echo -e "${BOLD}${RED}  Failures:${RESET}"
        for f in "${FAIL_LIST[@]}"; do echo -e "    ${RED}•${RESET} $f"; done
        if [[ $WARNS -gt 0 ]]; then
            echo ""
            echo -e "${BOLD}${YELLOW}  Warnings:${RESET}"
            for w in "${WARN_LIST[@]}"; do echo -e "    ${YELLOW}•${RESET} $w"; done
        fi
        echo ""
        echo -e "${DIM}  Fix the ${RED}✗${DIM} items above, then re-run:  make verify${RESET}"
        echo -e "${DIM}  Auto-repair safe items:     make fix${RESET}"
        echo ""
    fi
}

print_banner
check_repo
check_private
check_filesystem
check_ollama
check_nvidia
check_audio
check_session
check_network
check_git_github
check_dev
check_tooling
check_errors
print_summary
[[ $FAILS -gt 0 ]] && exit 1 || exit 0
