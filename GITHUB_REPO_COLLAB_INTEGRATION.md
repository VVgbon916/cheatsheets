# 🔗 GITHUB REPO & GOOGLE COLAB INTEGRATION GUIDE
### Connecting Avalhla to `VVgbon916/cheatsheets` · Persistent Memory · Cloud GPU Workflow
> Target Repo: `https://github.com/VVgbon916/cheatsheets`  
> User: Dawa (`VVgbon@VVgBazz`) | Platform: Bazzite DX NVIDIA + Google Colab

---

## 🎯 What This Connects

Your GitHub repo **`VVgbon916/cheatsheets`** already contains the foundations of your vision:
- `ai-persistent-memory-learning.sh` (The 3-layer persistent AI memory engine)
- `bash-complete-manual.sh` (Your core shell reference)
- `ollama-terminal-ai-cli-setup.sh` (Pure CLI development, no GUI)
- `ollama-copilot-vscode-cli-setup.sh`

This guide unites your **local Bazzite rig**, your **GitHub repository**, and **Google Colab** so your AI (Avalhla) can read, update, and collaborate with your cheatsheets anywhere.

```
       ┌─────────────────────────────────────────────────────────┐
       │         GitHub Repo: VVgbon916/cheatsheets              │
       │           (Central Cloud Source of Truth)               │
       └────────────────────────────┬────────────────────────────┘
                                    │
                    ┌───────────────┴───────────────┐
                    ▼                               ▼
       ┌────────────────────────┐      ┌────────────────────────┐
       │ Local Rig (VVgBazz)    │      │ Google Colab (Cloud)   │
       │ • RTX 3060 12GB Local  │      │ • Free T4/A100 Cloud   │
       │ • Avalhla CLI Agent    │      │ • Cloud Training & Run │
       │ • ~/.ai-memory/ sync   │      │ • Auto-git push/pull   │
       └────────────────────────┘      └────────────────────────┘
```

---

## 🛠️ Step 1: Connect Your Local Bazzite Rig to Your Repo

Run these commands in your terminal (`VVgbon@VVgBazz`):

```bash
# 1. Authenticate with GitHub CLI (if not already logged in)
gh auth login

# 2. Clone your repository to your projects folder
mkdir -p ~/projects
cd ~/projects
git clone https://github.com/VVgbon916/cheatsheets.git
cd cheatsheets

# 3. Copy your newly remastered master bibles into the repo
cp /home/VVgbon/.gemini/antigravity/brain/bbe30c19-93a2-4816-af81-90d470728207/COMPLET_SYS_GUIDE.md ./
cp /home/VVgbon/.gemini/antigravity/brain/bbe30c19-93a2-4816-af81-90d470728207/COMPLET_AI_GUIDE.md ./
cp /home/VVgbon/.gemini/antigravity/brain/bbe30c19-93a2-4816-af81-90d470728207/AI_usefull.md ./
cp /home/VVgbon/.gemini/antigravity/brain/bbe30c19-93a2-4816-af81-90d470728207/MASTER_RADIO_GUIDE.md ./
cp /home/VVgbon/.gemini/antigravity/brain/bbe30c19-93a2-4816-af81-90d470728207/master_radio_builder.py ./

# 4. Commit and push everything up to your GitHub repository
git add .
git commit -m "Add remastered system bibles, radio builder, and AI prompt guides"
git push origin main
```

---

## 🧠 Step 2: Initialize Avalhla's Persistent Memory (`~/.ai-memory`)

We now implement the exact memory system from your `ai-persistent-memory-learning.sh` script, pre-filled with your verified **VVgBazz** identity:

```bash
# 1. Create the persistent memory directory structure
mkdir -p ~/.ai-memory/{conversations,knowledge-base,profiles,preferences}

# 2. Write Dawa's permanent user profile
cat << 'EOF' > ~/.ai-memory/profiles/user-profile.txt
=== DAWA'S AI USER PROFILE ===
Name: Dawa
Username: VVgbon
Host: VVgBazz
Platform: Bazzite DX NVIDIA 44 (Fedora Atomic / KDE Wayland)
Hardware: Intel Core i7-6700, NVIDIA RTX 3060 12GB (170W cap), 16GB RAM + 7.8GB zram
Audio: PipeWire 1.6.8 (4 sinks: game, music, voice, browser) + USB DAC (Zgmicro)
Coding Style: Minimalist, CLI-focused, no GUI bloat, Sublime Text
Primary Languages: Bash, Python, Java 17/21
Dev Environment: Distrobox container 'coding-lab' (host stays immutable)
AI Companion Name: Avalhla
AI Model: Qwen 2.5 Coder (7B daily, 14B architecture)
Repository: https://github.com/VVgbon916/cheatsheets
=== END PROFILE ===
EOF

# 3. Symlink the cheatsheets repo into Avalhla's knowledge base!
ln -sfn ~/projects/cheatsheets ~/.ai-memory/knowledge-base/cheatsheets
echo "✅ Avalhla's persistent memory linked directly to VVgbon916/cheatsheets!"
```

---

## ☁️ Step 3: Google Colab Workflow (Cloud GPU + Your Repo)

When you are away from your PC or want to use Google's free cloud GPUs (Tesla T4 / A100) with your cheatsheets repo, use this workflow in Google Colab.

### Paste this into a Google Colab Notebook Cell:

```python
# ============================================================
# Google Colab: Connect to VVgbon916/cheatsheets + Run Qwen AI
# ============================================================

# 1. Clone your GitHub repository
!git clone https://github.com/VVgbon916/cheatsheets.git
%cd cheatsheets

# 2. Install Ollama inside Colab environment
!curl -fsSL https://ollama.com/install.sh | sh

# 3. Start Ollama daemon in background
import subprocess
import time
process = subprocess.Popen(["ollama", "serve"])
time.sleep(3)

# 4. Pull Qwen Coder model onto Colab's Cloud GPU (T4)
!ollama pull qwen2.5-coder:7b

# 5. Ask the AI to inspect your cheatsheets repo!
!ollama run qwen2.5-coder:7b "Inspect the current folder. List all .md and .sh files and summarize Dawa's system profile."
```

### To Push Changes Back to GitHub from Colab:
```python
# Set your GitHub token or credentials in Colab
!git config --global user.name "VVgbon916"
!git config --global user.email "your.email@example.com"

# Commit and push
!git add .
!git commit -m "Updated from Google Colab session"
# Use a GitHub Personal Access Token (PAT) for auth:
# !git push https://<YOUR_GITHUB_TOKEN>@github.com/VVgbon916/cheatsheets.git main
```

---

## 🔄 Step 4: The One-Command AI Sync Script (`sync_cheatsheets.sh`)

Save this script on your Bazzite machine to sync files between your local system and GitHub with one command:

```bash
cat << 'EOF' > ~/projects/cheatsheets/sync_cheatsheets.sh
#!/usr/bin/env bash
# ============================================================
# Cheatsheet & AI Memory Two-Way Synchronizer
# ============================================================
set -Eeuo pipefail

REPO_DIR="$HOME/projects/cheatsheets"
cd "$REPO_DIR"

echo "🔄 Pulling latest updates from GitHub..."
git pull origin main --rebase

echo "📦 Syncing local AI bibles into repository..."
cp -u /home/VVgbon/.gemini/antigravity/brain/bbe30c19-93a2-4816-af81-90d470728207/*.md "$REPO_DIR/" 2>/dev/null || true
cp -u /home/VVgbon/.gemini/antigravity/brain/bbe30c19-93a2-4816-af81-90d470728207/*.py "$REPO_DIR/" 2>/dev/null || true

if [ -n "$(git status --porcelain)" ]; then
    echo "📤 Committing changes and pushing to GitHub..."
    git add .
    git commit -m "Auto-sync from VVgBazz rig: $(date +'%Y-%m-%d %H:%M')"
    git push origin main
    echo "✅ Successfully synced to https://github.com/VVgbon916/cheatsheets!"
else
    echo "✨ Everything is already up to date."
fi
EOF

chmod +x ~/projects/cheatsheets/sync_cheatsheets.sh
```

---

## 🎯 How Avalhla Uses This Repo

Now, whenever you ask Avalhla a question:
1. She reads `~/.ai-memory/profiles/user-profile.txt` and knows you are **Dawa on Bazzite DX**.
2. She searches `~/.ai-memory/knowledge-base/cheatsheets/` for relevant Bash scripts, system bibles, or Python code.
3. She generates code that fits your exact standards.
4. You can run `./sync_cheatsheets.sh` to back up all new scripts directly to GitHub!
