# 🧠 VVgBazz — AI Guide (Local AI & Agent Bible)
### Zero API Cost · Infinite Tokens · RTX 3060 12GB Accelerated
> **System:** `VVgbon@VVgBazz` | **Operator:** Dawa | **Base:** Bazzite DX NVIDIA (Fedora Atomic / Distrobox)
> **Engine:** Ollama on CUDA 13.3 | **Model:** Qwen 2.5 Coder (7B / 14B) | **Agent Persona:** **Avalhla**

> [!NOTE]
> This replaces `COMPLET_AI_GUIDE.md`, `VVgBazz_Local_AI_CLI_Guide.md`, and `AI_usefull.md`,
> which described three overlapping and slightly inconsistent versions of the same setup.
> This is the single source of truth going forward.

---

## 1. Why Local AI (RTX 3060 12GB)

| Model | VRAM Usage | Speed on RTX 3060 | Use |
|---|---|---|---|
| Qwen 2.5 Coder 3B | ~2.5 GB | 90+ t/s | Quick syntax checks |
| **Qwen 2.5 Coder 7B** | **~5.5 GB** | **60+ t/s** | **Daily driver** |
| Qwen 2.5 Coder 14B | ~9.5 GB | 30–40 t/s | Complex architecture/refactoring |

Everything runs 100% locally — no subscriptions, no token quotas, no data leaving the machine.

---

## 2. Host Setup: Ollama

Ollama needs direct access to `/dev/nvidia*` and CUDA, so it installs on the **host**, not in Distrobox:

```bash
curl -fsSL https://ollama.com/install.sh | sh
sudo systemctl enable --now ollama

ollama pull qwen2.5-coder:7b
ollama pull qwen2.5-coder:14b

# Verify GPU offload while a prompt is running:
nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv
```

---

## 3. The Avalhla Persona (`persona/avalhla.Modelfile`)

```dockerfile
FROM qwen2.5-coder:7b

SYSTEM """
You are Avalhla, Dawa's private, high-performance personal AI companion and
senior systems engineer. You run locally on Dawa's Bazzite DX NVIDIA gaming
rig (RTX 3060 12GB, i7-6700, KDE Wayland).

Core directives:
1. Always write clean, idiomatic Python (standard library first) and robust Bash.
2. Adhere strictly to project rules — never invent non-existent APIs, packages,
   or file paths.
3. Be concise, sharp, and structured. Explain architectural logic clearly.
4. Never suggest `sudo dnf`/`sudo apt` on the host — dev tools live in Distrobox.
5. Never suggest deprecated flags (e.g. DXVK_ASYNC=1) or exceed the RTX 3060's
   170W power cap.
"""

PARAMETER temperature 0.2
PARAMETER top_p 0.9
PARAMETER num_ctx 8192
```

```bash
ollama create avalhla -f persona/avalhla.Modelfile
ollama run avalhla "Who are you, what is your name, and whose system are you running on?"
```

---

## 4. The Developer Lab (Distrobox)

See [`/dev/DEV_LAB_SETUP.md`](../dev/DEV_LAB_SETUP.md) for the full, verified
(not aspirational) container setup — including the actual working Java
install, since `java-17-openjdk-devel` / `java-21-openjdk-devel` **do not
resolve on Fedora 44** despite being referenced in older versions of this
guide.

**Exporting CLI (non-GUI) tools from the container, correctly:**

```bash
# ❌ WRONG — this is what every older doc in this repo said, and it's why
#    `distrobox-export --app cava` failed for you: cava has no .desktop file.
# distrobox-export --app cava

# ✅ CORRECT — export it as a binary shim instead
distrobox enter coding-lab -- which cava
distrobox enter coding-lab -- distrobox-export --bin /usr/bin/cava
```

---

## 5. The CLI Toolbelt — `ai-with-memory`, `ai-learn`, `ai-remember`, `ai-progress`

> [!NOTE]
> Earlier drafts of this guide described a set of `ai()` / `review()` /
> `research()` **bash functions** meant for `~/.bashrc`. Those are obsolete —
> the four scripts below already exist in this repo (`/scripts/`) and are a
> more complete implementation (persistent JSON conversation logs, greeting
> with last-topic recall, automatic Ollama-service bootstrap, HTTP-API
> fallback if the CLI pipe goes silent). Use these.

| Script | Purpose |
|---|---|
| `ai-with-memory` | Interactive chat with Avalhla; remembers prior topics via `~/.ai-memory/conversations/*.jsonl` |
| `ai-learn <path>` | Indexes a code/doc folder into `~/.ai-memory/knowledge-base/` |
| `ai-remember` | Avalhla self-reflects on recent logs + your profile and summarizes what she knows |
| `ai-progress` | Shows message counts, days active, knowledge-base size |

```bash
chmod +x scripts/ai-*
./scripts/ai-with-memory
```

These scripts read `~/.ai-memory/profiles/user-profile.txt` and
`~/.ai-memory/system-prompt.txt` — copy `persona/user-profile.txt.example` to
that location and fill it in (it's gitignored, so your real specs never get
committed).

---

## 6. Context Management & Token Shielding

Local models have a fixed context window (`num_ctx 8192` above). Rules to avoid confusion/hallucination:

1. **Don't dump huge files at once** — point Avalhla at specific files/functions.
2. **Git-checkpoint before letting her edit:**
   ```bash
   git add . && git commit -m "Checkpoint before Avalhla edits"
   # if she breaks something:
   git restore .
   ```
3. **`.gitignore` build artifacts** so she doesn't waste context on them (see repo-root `.gitignore`).
4. **Clear context between large features** — restart the `ai-with-memory` session, or type `/clear` in a raw `ollama run` session.

---

## 7. Engineering Standards (`AGENTS.md`)

Drop this in the root of any project so Avalhla follows consistent standards:

```markdown
# Project Rules & Standards (Dawa's Rig)

## General
1. Plan first: explain proposed changes before touching files.
2. Minimal diffs: small, reversible edits — never rewrite a whole file for a 5-line change.
3. No hallucinated libraries: standard library first.
4. Provide the exact CLI command to verify any change.

## Bash
- Mandatory header: `set -Eeuo pipefail`
- Quote all variables: `"$VAR"`
- Modern test syntax: `[[ ... ]]`, not `[ ... ]`
- Errors to stderr: `>&2 echo "Error: ..."`
- Must pass `shellcheck` with zero warnings.

## Java
- Version: Java 17 or 21 (LTS) — see `/dev/DEV_LAB_SETUP.md` for the verified
  install method on this Fedora 44 container.
- Build: Maven.
- Prefer `record` for data classes, `Optional` over null, `try-with-resources`.
- Every feature needs a JUnit 5 test.
```

---

## 8. IDE Integration (Zed)

```json
{
  "language_models": {
    "ollama": {
      "api_url": "http://localhost:11434/v1",
      "available_models": [
        { "name": "avalhla", "display_name": "Avalhla (RTX 3060 12GB Local)" },
        { "name": "qwen2.5-coder:14b", "display_name": "Qwen 2.5 Coder 14B (Heavy)" }
      ]
    }
  }
}
```

---

## 9. Toolbelt Dependency Audit

```bash
./scripts/avalhla_tools_check.sh
```

Verifies Python 3 stdlib modules, `curl`/`jq`/`git`/`ripgrep`/`fzf`/`shellcheck`/`xmllint`,
Java + Maven, and Ollama daemon connectivity — see the script's own comments
for what it does when something's missing.
