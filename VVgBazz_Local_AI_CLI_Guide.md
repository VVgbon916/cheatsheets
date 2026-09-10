# 🧠 Dawa's Local AI CLI Engineering Manual
### Zero API Cost · Infinite Tokens · RTX 3060 12GB Accelerated · Bazzite DX & Distrobox
> System: `VVgbon@VVgBazz` | Kernel: 7.2.3-ogc3.1 | Driver: 610.57.04 | CUDA: 13.3

---

## 💡 Why Your Rig is Ideal for Local AI

1. **RTX 3060 (12 GB VRAM):** 
   - 12 GB VRAM is the sweet spot. You can load **Qwen 2.5 Coder 7B** (uses ~5.5 GB VRAM) or **14B** (uses ~9.5 GB VRAM) **100% inside GPU memory**.
   - Output generation will be practically instantaneous (40–70+ tokens/sec on 7B), leaving your i7-6700 free for compiling and gaming.
2. **Zero Subscriptions or Token Limits:**
   - No monthly bills, no quota cut-offs.
   - You only manage your **Context Window** (how much text you feed it at once).
3. **The "Bazzite Way":**
   - **Ollama on Host:** Accesses NVIDIA CUDA directly with zero container friction.
   - **Development in Distrobox (`coding-lab`):** Java 17/21, Maven, ShellCheck, and Git live in an isolated container. Bazzite's atomic base stays 100% clean.

---

## ⚡ Part 1: Host Setup (Install Ollama on Bazzite)

Run this in your main terminal (`VVgbon@VVgBazz`):

```bash
# 1. Install Ollama on the host (picks up NVIDIA CUDA automatically)
curl -fsSL https://ollama.com/install.sh | sh

# 2. Start and enable Ollama system service
sudo systemctl enable --now ollama

# 3. Pull the recommended coding models for your 12GB VRAM
ollama pull qwen2.5-coder:7b     # Daily driver (super fast, uses ~5.5GB VRAM)
ollama pull qwen2.5-coder:14b    # Heavyweight for complex Java architecture (~9.5GB)

# 4. Verify GPU offloading on RTX 3060
ollama run qwen2.5-coder:7b "Confirm: Are you running with GPU acceleration?"
```

> [!TIP]
> In a separate terminal, run `nvidia-smi`. You will see `ollama_llama_server` occupying ~5.5 GB of VRAM under `Processes`.

---

## 📦 Part 2: Distrobox "Coding Lab" Setup

Never install Java or Maven on the Bazzite host with `rpm-ostree`. Create a dedicated container:

```bash
# 1. Create a Fedora container with full host integration
distrobox create -n coding-lab -i fedora:latest

# 2. Enter your new development environment
distrobox enter coding-lab
```

---

## 🛠️ Part 3: Automated Environment Installer (`setup_env.sh`)

Save this script inside `~/ai-dev/setup_env.sh` and run it inside `coding-lab`:

```bash
#!/usr/bin/env bash
# ============================================================
# Dawa's Coding-Lab Auto Configurator
# Run this INSIDE the distrobox container: 'coding-lab'
# ============================================================
set -Eeuo pipefail

echo "🚀 Setting up Dawa's AI-Dev Environment..."

# 1. Install Java, Maven, ShellCheck, and Dev Utilities
sudo dnf install -y \
    java-17-openjdk-devel \
    java-21-openjdk-devel \
    maven \
    shellcheck \
    git \
    jq \
    curl \
    ripgrep \
    fzf

# 2. Append AI CLI Shortcuts to ~/.bashrc
cat << 'EOF' >> ~/.bashrc

# ============================================================
# 🤖 LOCAL AI CLI SHORTCUTS (Ollama on Host -> Distrobox)
# ============================================================
export OLLAMA_HOST="http://localhost:11434"
export DEFAULT_MODEL="qwen2.5-coder:7b"

# Quick Q&A with AI
ai() {
    if [ -z "${*:-}" ]; then
        echo "Usage: ai \"your question here\""
        return 1
    fi
    local prompt="$*"
    curl -s "${OLLAMA_HOST}/api/generate" \
        -d "$(jq -n --arg m "$DEFAULT_MODEL" --arg p "$prompt" '{model: $m, prompt: $p, stream: false}')" \
        | jq -r '.response'
}

# Review any file for bugs, safety, and performance
review() {
    if [ -z "${1:-}" ] || [ ! -f "$1" ]; then
        echo "Usage: review <file_path>"
        return 1
    fi
    local file="$1"
    local content
    content=$(cat "$file")
    echo "🔍 AI is reviewing $file..."
    curl -s "${OLLAMA_HOST}/api/generate" \
        -d "$(jq -n --arg m "$DEFAULT_MODEL" --arg c "$content" --arg f "$file" \
        '{model: $m, prompt: ("Review this file (" + $f + ") for bugs, security risks, memory leaks, and performance issues. Suggest clear, minimal fixes:\n\n" + $c), stream: false}')" \
        | jq -r '.response'
}

# Fetch live web documentation and summarize for coding
research() {
    if [ -z "${1:-}" ]; then
        echo "Usage: research <url> [specific question]"
        return 1
    fi
    local url="$1"
    shift || true
    local extra_prompt="${*:-Summarize the key API patterns, classes, and syntax needed to implement this in Java/Bash.}"
    
    echo "🌐 Downloading reference from: $url"
    local temp_doc="/tmp/ai_web_doc.txt"
    curl -sL "$url" | sed -e 's/<[^>]*>/ /g' | tr -s ' ' > "$temp_doc"
    
    # Truncate to first 300 lines to prevent context overflow
    head -n 300 "$temp_doc" > "${temp_doc}.trimmed"
    local doc_content
    doc_content=$(cat "${temp_doc}.trimmed")
    
    echo "🤖 Analyzing documentation..."
    curl -s "${OLLAMA_HOST}/api/generate" \
        -d "$(jq -n --arg m "$DEFAULT_MODEL" --arg c "$doc_content" --arg p "$extra_prompt" \
        '{model: $m, prompt: ($p + "\n\nDOCUMENTATION EXCERPT:\n" + $c), stream: false}')" \
        | jq -r '.response'
}
EOF

echo "✅ Environment configured successfully!"
echo "👉 Run: source ~/.bashrc"
```

---

## 📜 Part 4: Project Rulebook (`AGENTS.md`)

Place this `AGENTS.md` file in the root of any project you work on. It prevents the AI from hallucinating or destroying your codebase:

```markdown
# 🤖 Project Rules & Standards (Dawa's Rig)

## 🎯 Target Platform
- Host: Bazzite DX (Fedora Atomic, KDE Wayland)
- Container: Distrobox (`coding-lab`)
- Hardware: Intel i7-6700, NVIDIA RTX 3060 12GB

## 🛡️ General Operating Rules
1. **Plan First:** Always propose your intended changes and affected files before modifying code.
2. **Small Diffs:** Never rewrite whole files when a 5-line change suffices.
3. **No Phantom APIs:** Stick to official standard libraries and verified dependencies.
4. **Verification Step:** Provide the exact CLI command to verify any change.

## 🐚 Bash Standards
- Always start scripts with: `set -Eeuo pipefail`
- Quote all variables: `"$VAR"`
- Prefer modern test syntax: `[[ ... ]]` over `[ ... ]`
- Redirect operational errors to stderr: `>&2 echo "Error: ..."`
- Must pass `shellcheck` validation without warnings.

## ☕ Java Standards
- Target Version: **Java 17 or Java 21 (LTS)**
- Build Tool: **Maven** (using standard `src/main/java` and `src/test/java`)
- Modern Idioms:
  - Prefer Java `record` for immutable data objects.
  - Use `var` for local variables with obvious types.
  - Use `Optional` to avoid `NullPointerException`.
  - Use `try-with-resources` for streams and files.
- Testing: Every bugfix or new feature must have a corresponding JUnit 5 test.

## 🌐 Research Protocol
- When asked to use external documentation, extract verified facts only.
- Cite the source URL and do not invent parameters.
```

---

## 📁 Part 5: Project Token Shield (`.gitignore`)

Save this `.gitignore` in your projects so tools never read huge binary directories:

```gitignore
# Maven & Java build artifacts
target/
*.class
*.jar
*.war
*.ear

# Distrobox / IDE configs
.idea/
*.iml
.vscode/
.settings/
.project
.classpath

# Temporary AI research dumps
/tmp/ai_web_doc*
/tmp/ai_research*
*.log
```

---

## 📝 Part 6: Integrating with Zed Editor

Since you already have **Zed** installed (`dev.zed.Zed`):

1. Launch Zed on Bazzite.
2. Open Settings (**Ctrl + ,**).
3. Add Ollama as your custom OpenAI-compatible language model provider:
   ```json
   {
     "language_models": {
       "ollama": {
         "api_url": "http://localhost:11434/v1",
         "available_models": [
           {
             "name": "qwen2.5-coder:7b",
             "display_name": "Qwen 2.5 Coder 7B (Local RTX 3060)"
           },
           {
             "name": "qwen2.5-coder:14b",
             "display_name": "Qwen 2.5 Coder 14B (Local RTX 3060)"
           }
         ]
       }
     }
   }
   ```
4. Now you have local autocomplete and in-editor AI with **zero token cost**!

---

## 🚀 Daily Workflow Example

```bash
# 1. Open your container
distrobox enter coding-lab

# 2. Ask a quick Bash syntax question
ai "How do I extract only matching IP addresses from a log file with awk?"

# 3. Research live online documentation
research "https://raw.githubusercontent.com/koalaman/shellcheck/master/README.md" "How to disable a specific warning code inline?"

# 4. Review your Java code
review src/main/java/com/dawa/service/NetworkManager.java

# 5. Compile and test
mvn clean test
```
