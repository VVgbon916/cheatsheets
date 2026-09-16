markdown

# 📂 Sub.files.md — Annotated File Map
`github.com/VVgbon916/cheatsheets` · branch `v0.3-restructure`

> **How to read this file:**
> - ⚠ **Pay attention** — a gotcha that will bite you
> - 🔴 **Common Error** — a thing people actually get wrong here
> - ✅ **Verify** — run this before trusting the file
> - 🔎 **Find** — the bash command to locate this file
> - 🔒 **Private** — never pushed to GitHub

---

## 🗂️ Top-level

| Path | What it is | Verify |
|---|---|---|
| `README.md` | Public repo overview | `cat README.md` |
| `CHANGELOG.md` | What changed and why | `head -40 CHANGELOG.md` |
| `.gitignore` | Blocks `private/` and secrets | `grep private .gitignore` |
| `Makefile` | One-word commands (`make verify`) | `make` |

🔎 **Find the repo:**
```bash
find ~ -type d -name "cheatsheets" 2>/dev/null

🔒 private/ — gitignored
File	Purpose
Dawa.txt	🔒 Passwords, PATs, SSH keys, network
D42k.md	🔒 The Bible

⚠ If git status shows these, .gitignore is broken:
bash

git check-ignore -v private/Dawa.txt private/D42k.md

🔴 Common Error: forcing them in.
bash

# ❌ NEVER
git add -f private/

📖 _index/
File	Purpose
D42k.public.md	Sanitized index — safe to push
Sub.files.md	This file

✅ Verify no secrets leaked:
bash

grep -riE "(ghp_|password|secret|token|api[_-]?key)" _index/

🧠 persona/
File	Purpose
avalhla.Modelfile	Ollama Modelfile
system-prompt.txt	System prompt
user-profile.txt.example	Template

⚠ user-profile.txt (without .example) is gitignored — copy the example:
bash

cp persona/user-profile.txt.example persona/user-profile.txt

🖥️ system/
File	Purpose
SYSTEM_GUIDE.md	Config / optimization
SYSTEM_PROFILE.md	Hardware audit
MAINTENANCE_DEBUG_GUIDE.md	Troubleshooting

🔴 Common Error: btrfs … / instead of /var:
bash

sudo btrfs filesystem usage /var   # ✅

🤖 ai/
File	Purpose
AI_GUIDE.md	AI / agent guide
deepseek-r1-16k.md	Verified 16K / 32K recipe

✅ Verify context:
bash

pgrep -af llama-server | grep -o '\-c [0-9]*'
# want 16384 (or 32768)

💻 dev/
File	Purpose
DEV_LAB_SETUP.md	Distrobox walkthrough
GITHUB_COLAB_INTEGRATION.md	gh CLI workflow

🔴 Common Error: exporting a CLI tool with --app:
bash

distrobox-export --bin /usr/bin/cava   # ✅

🎮 gaming/
File	Purpose
GAMING_HANDBOOK.md	Launch options, MangoHud

⚠ Remove DXVK_ASYNC=1 if you find it.
🛠️ scripts/
File	Purpose
verify-before-work.sh	Full pre-flight
ollama-ctx	Context switcher
review-cheatsheets.sh	Repo lint
avalhla_tools_check.sh	Dependency audit
bazzite-toolkit.sh	Bazzite helper
linux-toolkit.sh	Any Linux
windows-toolkit.ps1	Windows
android-toolkit.sh	Termux
ai-with-memory	Avalhla chat
ai-learn	Index dir
ai-remember	Review memories
ai-progress	Memory stats

✅ Verify executable:
bash

chmod +x scripts/*.sh scripts/ollama-ctx scripts/ai-*
find scripts -type f \( -name "*.sh" -o -name "ollama-ctx" -o -name "ai-*" \) ! -perm -u+x
# should return nothing

🗄️ archive/
File	Purpose
D42k.original.md	Old D42k, preserved
🧭 Cross-references

    Private bible ......... private/D42k.md

    Public index .......... _index/D42k.public.md

    Public README ......... README.md

    Persona ............... persona/system-prompt.txt

    Secret keyring ........ private/Dawa.txt

_Last updated: 2026-09-16_
