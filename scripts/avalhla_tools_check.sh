#!/usr/bin/env bash
# ============================================================
# AVALHLA TOOL & RUNTIME DEPENDENCY AUDIT
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

info "Checking essential host tools..."
check_tool python3    python3
check_tool curl       curl
check_tool jq         jq
check_tool git        git
check_tool gh         gh
check_tool podman     podman
check_tool systemctl  systemd

info "Checking dev tools (may be in distrobox)..."
check_tool shellcheck shellcheck
check_tool rg         ripgrep
check_tool fzf        fzf
check_tool java       openjdk

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

info "Checking Ollama container (systemd user service)..."
if systemctl --user is-active --quiet ollama.service 2>/dev/null; then
    pass "ollama.service active"
else
    warn "ollama.service not active"
    echo "      Start: systemctl --user start ollama.service"
fi

info "Testing Ollama API (http://localhost:11434)..."
if curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
    pass "Ollama daemon online."
    MODELS=$(curl -s http://localhost:11434/api/tags | jq -r '.models[].name' 2>/dev/null || echo "")
    if echo "$MODELS" | grep -qE "^avalhla"; then
        pass "Avalhla model present."
    else
        warn "Avalhla model not found."
        echo "      Build: cd ~/projects/cheatsheets && ollama create avalhla -f persona/avalhla.Modelfile"
    fi
    if echo "$MODELS" | grep -qE "^qwen2.5-coder"; then
        pass "Base model qwen2.5-coder present."
    fi
else
    warn "Ollama API not reachable."
    echo "      Start the container: systemctl --user start ollama.service"
fi

info "Checking context length in Quadlet..."
QUADLET="$HOME/.config/containers/systemd/ollama.container"
if [[ -f "$QUADLET" ]]; then
    ctx=$(grep -oE 'OLLAMA_CONTEXT_LENGTH=[0-9]+' "$QUADLET" | head -1 | cut -d= -f2 || true)
    if [[ -z "$ctx" ]]; then
        warn "OLLAMA_CONTEXT_LENGTH not set in Quadlet (defaults to 4096)"
        echo "      Fix: ollama-ctx 16384"
    elif [[ "$ctx" -ge 16384 ]]; then
        pass "context = $ctx (Quadlet)"
    else
        warn "context = $ctx" "want >= 16384"
        echo "      Fix: ollama-ctx 16384"
    fi
else
    warn "Quadlet not found: $QUADLET"
fi

if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
    echo
    warn "Missing host tools: ${MISSING_PKGS[*]}"
    if [ -f /run/.containerenv ] || [ -f /.dockerenv ]; then
        info "Inside a container — attempting install via dnf..."
        sudo dnf install -y "${MISSING_PKGS[@]}"
        pass "Missing dependencies installed."
    else
        info "On Bazzite host."
        info "Dev tools belong in coding-lab (Distrobox):"
        echo -e "${YELLOW}distrobox enter coding-lab -- sudo dnf install -y ${MISSING_PKGS[*]}${NC}"
        info "Required tools for Avalhla (python3, curl, jq, podman) are already on host."
    fi
else
    echo
    echo -e "${GREEN}PERFECT — Avalhla has 100% of required tools.${NC}"
fi
