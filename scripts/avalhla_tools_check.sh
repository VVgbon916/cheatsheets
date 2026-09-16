#!/usr/bin/env bash
# ============================================================
# 🛡️ AVALHLA TOOL & RUNTIME DEPENDENCY AUDIT & INSTALLER
# ============================================================
set -Eeuo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'
pass() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[MISSING]${NC} $1"; }
info() { echo -e "${CYAN}==>${NC} $1"; }
fail() { echo -e "${RED}[ERROR]${NC} $1"; }

echo -e "${CYAN}====================================================="
echo "   AVALHLA ENVIRONMENT & TOOL DEPENDENCY AUDIT       "
echo -e "=====================================================${NC}"

MISSING_PKGS=()

check_tool() {
    local cmd="$1" pkg="$2"
    if command -v "$cmd" >/dev/null 2>&1; then
        pass "$cmd ($($cmd --version 2>&1 | head -n1 | cut -c1-50))"
    else
        warn "$cmd is NOT installed."
        MISSING_PKGS+=("$pkg")
    fi
}

info "Checking essential development & parser tools..."
check_tool python3    python3
check_tool curl       curl
check_tool jq         jq
check_tool git        git
check_tool gh         gh
check_tool shellcheck shellcheck
check_tool xmllint    libxml2
check_tool ffmpeg     ffmpeg-free
check_tool java       java-25-openjdk-devel
check_tool mvn        maven
check_tool rg         ripgrep
check_tool fzf        fzf

info "Testing Python 3 standard library modules..."
python3 - << 'EOF'
import sys
required = ["json","urllib.request","urllib.error",
            "xml.etree.ElementTree","xml.dom.minidom",
            "concurrent.futures","time","os"]
import importlib.util
missing = [m for m in required if importlib.util.find_spec(m) is None]
if missing:
    print(f"FAILED: Missing modules: {missing}", file=sys.stderr); sys.exit(1)
print("Python stdlib: all present.")
EOF
pass "Python 3 stdlib passes Avalhla runtime requirements."

info "Testing Ollama communication (http://localhost:11434)..."
if curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
    pass "Ollama daemon is online."
    MODELS=$(curl -s http://localhost:11434/api/tags | jq -r '.models[].name' 2>/dev/null || echo "")
    if echo "$MODELS" | grep -qE "deepseek-r1|avalhla"; then
        pass "DeepSeek-R1 / Avalhla model detected."
    else
        warn "No DeepSeek-R1 / Avalhla model found. Pull one with:"
        echo "      ollama pull deepseek-r1:14b"
    fi
    echo
    info "Verifying context length (want 16384)..."
    ctx=$(pgrep -af llama-server | grep -o '\-c [0-9]*' | awk '{print $2}' | head -1 || true)
    if [[ -n "$ctx" ]]; then
        if [[ "$ctx" -ge 16384 ]]; then
            pass "llama-server context = $ctx"
        else
            warn "llama-server context = $ctx (want ≥16384). Restart server with OLLAMA_CONTEXT_LENGTH=16384."
        fi
    else
        info "No llama-server currently running (start on next ollama run)."
    fi
else
    warn "Ollama is not running on http://localhost:11434."
    echo "      Start it on host:  OLLAMA_CONTEXT_LENGTH=16384 ollama serve"
fi

if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
    echo
    warn "Missing packages: ${MISSING_PKGS[*]}"
    if [ -f /run/.containerenv ] || [ -f /.dockerenv ]; then
        info "Inside Distrobox — attempting automated install via dnf..."
        sudo dnf install -y "${MISSING_PKGS[@]}"
        pass "Missing dependencies installed."
    else
        info "On Bazzite host. Install inside Distrobox (keep host immutable):"
        echo -e "${YELLOW}distrobox enter coding-lab -- sudo dnf install -y ${MISSING_PKGS[*]}${NC}"
    fi
else
    echo
    echo -e "${GREEN}🎉 PERFECT — Avalhla has 100% of required tools.${NC}"
fi
