#!/usr/bin/env bash
# ============================================================
# 🛡️ AVALHLA TOOL & RUNTIME DEPENDENCY AUDIT & INSTALLER
# Ensures Avalhla has 100% of the tools she needs to build,
# test, validate audio streams, and inspect XML/Python code.
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

# 1. Helper to check command availability
check_tool() {
    local cmd="$1"
    local pkg_name="$2"
    if command -v "$cmd" >/dev/null 2>&1; then
        pass "$cmd ($($cmd --version 2>&1 | head -n1 | cut -c1-50))"
    else
        warn "$cmd is NOT installed."
        MISSING_PKGS+=("$pkg_name")
    fi
}

info "Checking essential development & parser tools..."
check_tool python3 python3
check_tool curl curl
check_tool jq jq
check_tool git git
check_tool shellcheck shellcheck
check_tool xmllint libxml2
check_tool ffmpeg ffmpeg-free
check_tool java java-17-openjdk-devel
check_tool mvn maven
check_tool rg ripgrep
check_tool fzf fzf

# 2. Check Python standard library modules required by Master Radio
info "Testing Python 3 core module readiness..."
python3 - << 'EOF'
import sys
required_modules = [
    "json",
    "urllib.request",
    "urllib.error",
    "xml.etree.ElementTree",
    "xml.dom.minidom",
    "concurrent.futures",
    "time",
    "os"
]
missing = []
for mod in required_modules:
    try:
        __import__(mod)
    except ImportError:
        missing.append(mod)

if missing:
    print(f"FAILED: Missing Python modules: {missing}", file=sys.stderr)
    sys.exit(1)
else:
    print("Python 3 standard library modules: ALL PRESENT & VERIFIED.")
EOF
pass "Python 3 standard library passes Master Radio requirements."

# 3. Check Ollama API Connectivity
info "Testing Ollama communication (Host -> http://localhost:11434)..."
if curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
    pass "Ollama daemon is online and responding."
    MODELS=$(curl -s http://localhost:11434/api/tags | jq -r '.models[].name' 2>/dev/null || echo "")
    if echo "$MODELS" | grep -qE "qwen|avalhla"; then
        pass "Avalhla / Qwen model detected in Ollama."
    else
        warn "No Qwen / Avalhla model found in Ollama yet. Pull one with: ollama pull qwen2.5-coder:7b"
    fi
else
    warn "Ollama is not running on http://localhost:11434."
    echo "      Start it on host with: sudo systemctl enable --now ollama"
fi

# 4. Auto-Repair / Install if inside Distrobox
if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
    echo
    warn "The following packages are needed for Avalhla: ${MISSING_PKGS[*]}"
    if [ -f /run/.containerenv ] || [ -f /.dockerenv ]; then
        info "Inside Distrobox container! Attempting automated installation via dnf..."
        sudo dnf install -y "${MISSING_PKGS[@]}"
        pass "All missing dependencies successfully installed inside container!"
    else
        info "On Bazzite host. To keep host immutable, install these inside Distrobox:"
        echo -e "${YELLOW}distrobox enter coding-lab -- sudo dnf install -y ${MISSING_PKGS[*]}${NC}"
    fi
else
    echo
    echo -e "${GREEN}🎉 PERFECT! Avalhla has 100% of all tools and dependencies ready to work!${NC}"
fi
