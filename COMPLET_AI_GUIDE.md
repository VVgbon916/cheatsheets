# 🧠 VVgBazz — COMPLET AI GUIDE (Master Local AI & Agent Bible)
### Zero API Cost · Infinite Tokens · RTX 3060 12GB Accelerated · Private Local CLI Intelligence
> **System:** `VVgbon@VVgBazz` | **Operator:** Dawa | **Base:** Bazzite DX NVIDIA (Fedora Atomic / Distrobox)  
> **Engine:** Ollama on CUDA 13.3 | **Model:** Qwen 2.5 / 3.5 Coder (7B / 14B) | **Agent Persona:** **Avalhla**

---

```
========================================================================================
                               AVALHLA AI ARCHITECTURE
========================================================================================
 [ Hardware Acceleration ]  NVIDIA RTX 3060 12GB VRAM (CUDA 13.3) — 100% GPU Offload
         │
 [ AI Engine (Host Base) ]  Ollama Daemon (http://localhost:11434) · Systemd Service
         │
 ┌───────┴─────────────────────────────────────────────────────────────────────────────┐
 │ Avalhla Modelfile Persona: Qwen 2.5 Coder (7B Daily / 14B Architecture)             │
 │ Temperature: 0.2 · Top-P: 0.9 · Context Window: 8192 Tokens                         │
 └───────┬─────────────────────────────────────────────────────────────────────────────┘
         │
 ┌───────┴────────────────────────┬────────────────────────┬───────────────────────────┐
 │ 1. CLI AI Toolbelt             │ 2. Distrobox Lab       │ 3. Editor Integrations    │
 │ • ai "<prompt>"                │ • coding-lab container │ • Zed: Local Copilot      │
 │ • review <file>                │ • Java 17/21 + Maven   │ • Sublime: Readability    │
 │ • research <url> [query]       │ • ShellCheck + Python3 │   rulers & monospace view │
 └───────┬────────────────────────┴────────────────────────┴───────────────────────────┘
         │
 [ Target Benchmarks ]      Project "Master Radio" · 27 Core Rules · Python Standard Lib
========================================================================================
```

---

## 📑 TABLE OF CONTENTS

1. [Why Local AI? (The RTX 3060 12GB Advantage)](#1-why-local-ai-the-rtx-3060-12gb-advantage)
2. [Host Setup: Ollama Installation & GPU Verification](#2-host-setup-ollama-installation--gpu-verification)
3. [Building the "Avalhla" Custom Persona (Modelfile)](#3-building-the-avalhla-custom-persona-modelfile)
4. [The Developer Lab: Distrobox Container Setup](#4-the-developer-lab-distrobox-container-setup)
5. [The Power CLI Toolbelt (`ai`, `review`, `research`)](#5-the-power-cli-toolbelt-ai-review-research)
6. [Context Management & Token Shielding Protocol](#6-context-management--token-shielding-protocol)
7. [Engineering Standards: Bash & Java 17/21 Rules](#7-engineering-standards-bash--java-1721-rules)
8. [IDE Integration: Zed Editor & Sublime Text](#8-ide-integration-zed-editor--sublime-text)
9. [The Grand Training Benchmark: Project Master Radio](#9-the-grand-training-benchmark-project-master-radio)
10. [Toolbelt Dependency Audit Script (`avalhla_tools_check.sh`)](#10-toolbelt-dependency-audit-script-avalhla_tools_checksh)

---

## 1. Why Local AI? (The RTX 3060 12GB Advantage)

Online AI subscriptions (ChatGPT, Claude, Copilot) charge monthly fees and cut you off when you exhaust your token quota. 

### Your RTX 3060 12GB changes the game:
- **12 GB VRAM is the sweet spot:** High-tier coding models like **Qwen 2.5 Coder 7B** require **~5.5 GB VRAM**, and **14B** requires **~9.5 GB VRAM**.
- **100% in VRAM:** The entire model resides on the GPU die. Generation speed is lightning fast (**50–70+ tokens per second**), completely bypassing system RAM and leaving your Intel i7-6700 CPU free for compilation and gaming.
- **True Privacy:** Your code, tokens, scripts, and private data never leave your local machine.
- **Infinite Tokens:** You can ask 1,000 questions a day or feed entire 500-line scripts without paying a cent.

| Model | Size | VRAM Usage | Speed on RTX 3060 | Recommended Use |
|---|---|---|---|---|
| **Qwen 2.5 Coder 3B** | 1.9 GB | ~2.5 GB | Ultra-fast (90+ t/s) | Quick one-line syntax checks |
| **Qwen 2.5 Coder 7B** | 4.7 GB | ~5.5 GB | **Blazing (60+ t/s)** | **Daily Driver: Bash, Java, Python** |
| **Qwen 2.5 Coder 14B** | 9.0 GB | ~9.5 GB | Fast (30–40 t/s) | Complex Architecture & Refactoring |

---

## 2. Host Setup: Ollama Installation & GPU Verification

Because Ollama requires direct communication with NVIDIA kernel drivers (`/dev/nvidia*` and CUDA 13.3), install Ollama directly on the **Bazzite host**:

```bash
# 1. Install Ollama host engine
curl -fsSL https://ollama.com/install.sh | sh

# 2. Start and enable systemd service //dawa
sudo systemctl enable --now ollama

# 3. Pull the official Qwen Coder foundation models
ollama pull qwen2.5-coder:7b
ollama pull qwen2.5-coder:14b

# 4. Verify GPU offload in another terminal
# While running a prompt, inspect VRAM allocation:
nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv
```

---

## 3. Building the "Avalhla" Custom Persona (Modelfile)

Instead of using a generic chatbot, create your customized senior AI engineer, **Avalhla**:

```bash
# 1. Create Avalhla's Modelfile
cat << 'EOF' > ~/Modelfile.avalhla
FROM qwen2.5-coder:7b

# System Directives
SYSTEM """
You are Avalhla, Dawa's private, high-performance personal AI companion and senior systems engineer.
You run locally on Dawa's Bazzite DX NVIDIA gaming rig (RTX 3060 12GB, i7-6700, KDE Wayland).
Your core directives:
1. Always write clean, idiomatic Python (standard library first) and robust Bash.
2. Adhere strictly to project rules and never invent non-existent APIs or microgenres.
3. Be concise, sharp, and structured. Explain your architectural logic clearly.
"""

# Optimal sampling parameters for deterministic code generation
PARAMETER temperature 0.2
PARAMETER top_p 0.9
PARAMETER num_ctx 8192
EOF

# 2. Compile the model into Ollama
ollama create avalhla -f ~/Modelfile.avalhla

# 3. Verify Avalhla's identity
ollama run avalhla "Who are you, what is your name, and whose system are you running on?"
```

---

## 4. The Developer Lab: Distrobox Container Setup

To preserve Bazzite's immutable base (`rpm-ostree`), all compilers, linters, Java JDKs, and Maven run inside a dedicated container named **`coding-lab`**:

```bash
# 1. Create the container
distrobox create -n coding-lab -i fedora:latest -Y

# 2. Enter the container
distrobox enter coding-lab

# 3. Install the full developer tool stack
sudo dnf install -y \
    java-17-openjdk-devel \
    java-21-openjdk-devel \
    maven \
    shellcheck \
    libxml2 \
    ffmpeg-free \
    git \
    jq \
    curl \
    ripgrep \
    fzf \
    htop \
    cava

# 4. Export Cava audio visualizer to KDE desktop menu
distrobox-export --app cava
```

---

## 5. The Power CLI Toolbelt (`ai`, `review`, `research`)

Add these 3 functions to your `~/.bashrc` inside `coding-lab` (or on host):

```bash
cat << 'EOF' >> ~/.bashrc

# ============================================================
# 🤖 AVALHLA LOCAL CLI AI ENGINE
# ============================================================
export OLLAMA_HOST="http://localhost:11434"
export AVALHLA_MODEL="avalhla"

# 1. Quick Q&A Command
ai() {
    if [ -z "${*:-}" ]; then
        echo "Usage: ai \"your question here\""
        return 1
    fi
    local prompt="$*"
    curl -s "${OLLAMA_HOST}/api/generate" \
        -d "$(jq -n --arg m "$AVALHLA_MODEL" --arg p "$prompt" '{model: $m, prompt: $p, stream: false}')" \
        | jq -r '.response'
}

# 2. Automated Code Reviewer (Bugs, Security, Performance)
review() {
    if [ -z "${1:-}" ] || [ ! -f "$1" ]; then
        echo "Usage: review <file_path>"
        return 1
    fi
    local file="$1"
    local content
    content=$(cat "$file")
    echo "🔍 Avalhla is reviewing $file..."
    curl -s "${OLLAMA_HOST}/api/generate" \
        -d "$(jq -n --arg m "$AVALHLA_MODEL" --arg c "$content" --arg f "$file" \
        '{model: $m, prompt: ("Review this file (" + $f + ") for bugs, security risks, memory leaks, and performance issues. Suggest clear, minimal fixes:\n\n" + $c), stream: false}')" \
        | jq -r '.response'
}

# 3. Offline Web Documentation Researcher
research() {
    if [ -z "${1:-}" ]; then
        echo "Usage: research <url> [specific question]"
        return 1
    fi
    local url="$1"
    shift || true
    local extra_prompt="${*:-Summarize key API patterns, classes, and syntax needed to implement this in Java/Bash.}"
    
    echo "🌐 Fetching reference from: $url"
    local temp_doc="/tmp/ai_web_doc.txt"
    curl -sL "$url" | sed -e 's/<[^>]*>/ /g' | tr -s ' ' > "$temp_doc"
    head -n 300 "$temp_doc" > "${temp_doc}.trimmed"
    local doc_content
    doc_content=$(cat "${temp_doc}.trimmed")
    
    echo "🤖 Avalhla is analyzing documentation..."
    curl -s "${OLLAMA_HOST}/api/generate" \
        -d "$(jq -n --arg m "$AVALHLA_MODEL" --arg c "$doc_content" --arg p "$extra_prompt" \
        '{model: $m, prompt: ($p + "\n\nDOCUMENTATION EXCERPT:\n" + $c), stream: false}')" \
        | jq -r '.response'
}
EOF
source ~/.bashrc
```

---

## 6. Context Management & Token Shielding Protocol

Local models do not cost money when they talk, but they have a **Context Window limit** (e.g. 8,192 tokens). Exceeding this limit causes confusion or hallucinations.

### The 4 Shielding Rules:
1. **Never dump 2,000 lines of code at once:** Ask Avalhla to inspect specific files or functions (`review src/App.java`).
2. **Use Git checkpoints before letting AI edit:**
   ```bash
   git status
   git add . && git commit -m "Checkpoint before Avalhla edits"
   # If she breaks anything:
   git diff
   git restore .
   ```
3. **Shield huge directories with `.gitignore`:**
   ```gitignore
   target/
   *.class
   *.jar
   .idea/
   .vscode/
   node_modules/
   /tmp/ai_*
   *.log
   ```
4. **Clear context between large features:** In interactive sessions, type `/clear` to start a fresh memory buffer.

---

## 7. Engineering Standards: Bash & Java 17/21 Rules

Save this as **`AGENTS.md`** in the root of every coding project so Avalhla adheres to your strict standards:

```markdown
# 🤖 Project Rules & Standards (Dawa's Rig)

## 🛡️ General Directives
1. Plan first: Always explain proposed changes before touching files.
2. Minimal diffs: Make small, reversible edits.
3. No hallucinated libraries: Use standard libraries first.

## 🐚 Bash Scripting Standards
- Mandatory Header: `set -Eeuo pipefail`
- Quote all variables: `"$VAR"`
- Use modern test syntax: `[[ ... ]]` instead of legacy `[ ... ]`
- Provide helpful error messages to `stderr`: `>&2 echo "Error: ..."`
- Must pass `shellcheck` without warnings.

## ☕ Java Development Standards
- Version: **Java 17 or Java 21 (LTS)**
- Build System: **Maven** (`pom.xml`)
- Architecture:
  - Prefer immutable Java `record` for data classes.
  - Use `Optional` to eliminate null pointer risks.
  - Use `try-with-resources` for files and streams.
  - Every feature must include a JUnit 5 unit test.
```

---

## 8. IDE Integration: Zed Editor & Sublime Text

### A. Zed Editor (Local Copilot Setup)
Zed is installed on your system (`dev.zed.Zed`). Configure it to use your local Ollama instance for **free autocompletion**:

1. Open Zed Settings: **Ctrl + ,**
2. Add your local model provider:
```json
{
  "language_models": {
    "ollama": {
      "api_url": "http://localhost:11434/v1",
      "available_models": [
        {
          "name": "avalhla",
          "display_name": "Avalhla (RTX 3060 12GB Local)"
        },
        {
          "name": "qwen2.5-coder:14b",
          "display_name": "Qwen 2.5 Coder 14B (Heavy)"
        }
      ]
    }
  }
}
```

### B. Sublime Text Settings for Maximum Readability
To ensure ASCII tables, code diffs, and Master Radio playlists are clean and easy to read in Sublime Text:

In Sublime Text -> **Preferences** -> **Settings**:
```json
{
  "font_face": "JetBrains Mono",
  "font_size": 11,
  "rulers": [80, 100],
  "word_wrap": false,
  "draw_white_space": "selection",
  "translate_tabs_to_spaces": true,
  "tab_size": 4
}
```

---

## 9. The Grand Training Benchmark: Project Master Radio

Use the locked **Master Radio Specification** as the benchmark to test Avalhla's reasoning, schema design, and concurrency code.

### The 4 Progressive Challenge Stages:
- **Stage 1 (Architecture):** Ask her to explain the 10 Broad Canonical Genres and differentiate between `ACCURATE`, `MASTER`, and `CROSSOVER` playlists.
- **Stage 2 (Data Modeling):** Ask her to write the JSON schema for `master_radio_db.json` with 3 real stations (SomaFM, Radio Paradise, FIP).
- **Stage 3 (Pure Python Generator):** Ask her to write the `#EXTINF group-title` M3U and XML XSPF writer using **Python standard library only**.
- **Stage 4 (Multi-threaded Stream Checker):** Ask her to write a `ThreadPoolExecutor` validator using `Range: bytes=0-1024` headers and a 3.5s timeout.

Full prompts and grading criteria are preserved in:  
👉 **[AVALHLA_AI_TRAINING_PROMPTS.md](file:///home/VVgbon/.gemini/antigravity/brain/bbe30c19-93a2-4816-af81-90d470728207/AVALHLA_AI_TRAINING_PROMPTS.md)**

---

## 10. Toolbelt Dependency Audit Script (`avalhla_tools_check.sh`)

Before benchmarking Avalhla, run the automated tool auditor:

```bash
bash /home/VVgbon/.gemini/antigravity/brain/bbe30c19-93a2-4816-af81-90d470728207/avalhla_tools_check.sh
```

It verifies:
- `python3` (with `xml.etree.ElementTree`, `concurrent.futures`, `urllib.request`)
- `curl`, `jq`, `git`, `ripgrep`, `fzf`
- `shellcheck` & `xmllint`
- `java` (OpenJDK 17/21) & `mvn` (Maven)
- `ffmpeg` (audio codec inspection)
- Ollama daemon connectivity on `http://localhost:11434`
