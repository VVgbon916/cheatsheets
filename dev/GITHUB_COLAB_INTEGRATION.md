# 🔗 GitHub Repo & Google Colab Integration
### Connecting Avalhla to `VVgbon916/cheatsheets` · Persistent Memory · Cloud GPU Workflow
> Target Repo: `https://github.com/VVgbon916/cheatsheets`

---

## What This Connects

Unites your local Bazzite rig, this GitHub repo, and Google Colab so Avalhla
can read, update, and collaborate with your docs/scripts anywhere.

```
       ┌─────────────────────────────────────────────────────────┐
       │         GitHub Repo: VVgbon916/cheatsheets              │
       └────────────────────────────┬────────────────────────────┘
                    ┌───────────────┴───────────────┐
                    ▼                               ▼
       ┌────────────────────────┐      ┌────────────────────────┐
       │ Local Rig (VVgBazz)    │      │ Google Colab (Cloud)   │
       │ Avalhla CLI Agent      │      │ Free T4/A100 Cloud     │
       │ ~/.ai-memory/ sync     │      │ Auto-git push/pull     │
       └────────────────────────┘      └────────────────────────┘
```

---

## Step 1: Clone the Repo Locally

```bash
gh auth login
mkdir -p ~/projects && cd ~/projects
git clone https://github.com/VVgbon916/cheatsheets.git
cd cheatsheets
```

> [!NOTE]
> Earlier versions of this guide had you `cp` a stack of markdown files from
> a Gemini-Antigravity temp brain directory into the repo — that path was
> specific to a different AI tool's session and doesn't exist for you. If
> you're editing files, just edit them in place in your clone.

---

## Step 2: Initialize Avalhla's Persistent Memory

```bash
mkdir -p ~/.ai-memory/{conversations,knowledge-base,profiles,preferences}

# Copy the ONE canonical profile template and fill in your real values —
# do not redefine the profile inline here; persona/user-profile.txt.example
# is the single source of truth.
cp persona/user-profile.txt.example ~/.ai-memory/profiles/user-profile.txt
$EDITOR ~/.ai-memory/profiles/user-profile.txt

cp persona/system-prompt.txt ~/.ai-memory/system-prompt.txt

# Symlink the repo into Avalhla's knowledge base
ln -sfn ~/projects/cheatsheets ~/.ai-memory/knowledge-base/cheatsheets
```

> [!CAUTION]
> `~/.ai-memory/conversations/` and `~/.ai-memory/knowledge-base/` are
> gitignored on purpose (see repo-root `.gitignore`) — this repo is public,
> and those directories can contain real conversation logs and your real
> hardware/identity details. Don't force-add them.

---

## Step 3: Google Colab Workflow (Cloud GPU + This Repo)

Paste into a Colab cell:

```python
!git clone https://github.com/VVgbon916/cheatsheets.git
%cd cheatsheets

!curl -fsSL https://ollama.com/install.sh | sh

import subprocess, time
process = subprocess.Popen(["ollama", "serve"])
time.sleep(3)

!ollama pull qwen2.5-coder:7b
!ollama run qwen2.5-coder:7b "Inspect the current folder and summarize its structure."
```

Push changes back:
```python
!git config --global user.name "VVgbon916"
!git config --global user.email "<your-email>"
!git add .
!git commit -m "Updated from Google Colab session"
# Use a GitHub Personal Access Token (PAT):
# !git push https://<YOUR_GITHUB_TOKEN>@github.com/VVgbon916/cheatsheets.git main
```

---

## Step 4: One-Command Sync Script

```bash
cat << 'EOF' > scripts/sync_cheatsheets.sh
#!/usr/bin/env bash
set -Eeuo pipefail

REPO_DIR="$HOME/projects/cheatsheets"
cd "$REPO_DIR"

echo "🔄 Pulling latest updates from GitHub..."
git pull origin main --rebase

if [ -n "$(git status --porcelain)" ]; then
    echo "📤 Committing and pushing changes..."
    git add .
    git commit -m "Auto-sync from VVgBazz rig: $(date +'%Y-%m-%d %H:%M')"
    git push origin main
else
    echo "✨ Already up to date."
fi
EOF
chmod +x scripts/sync_cheatsheets.sh
```

---

## How Avalhla Uses This Repo

1. She reads `~/.ai-memory/profiles/user-profile.txt` for your identity/hardware.
2. She searches `~/.ai-memory/knowledge-base/cheatsheets/` for relevant docs/scripts.
3. She generates code matching your standards (see `/ai/AI_GUIDE.md` §7, `AGENTS.md`).
4. `./scripts/sync_cheatsheets.sh` pushes new work back to GitHub.
