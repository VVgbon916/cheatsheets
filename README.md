# 🛡️ VVgBazz & Avalhla V0.3 — System & AI Ecosystem

> **Operator:** Dawa (`VVgbon@VVgBazz`) | **AI Companion:** Avalhla (Ava)
> **Base Platform:** Bazzite DX NVIDIA 44 (Fedora 44 Atomic / KDE Wayland)
> **Repository:** [VVgbon916/cheatsheets](https://github.com/VVgbon916/cheatsheets)

See [`CHANGELOG.md`](./CHANGELOG.md) for the full list of what changed and why.

## Layout

| Path | Contents |
|---|---|
| [`/persona`](./persona) | `avalhla.Modelfile` (canonical persona), `system-prompt.txt`, `user-profile.txt.example`. The real filled-in `user-profile.txt` is gitignored — copy the example locally. |
| [`/system`](./system) | `SYSTEM_GUIDE.md` (config/optimization), `SYSTEM_PROFILE.md` (point-in-time hardware audit), `MAINTENANCE_DEBUG_GUIDE.md`. |
| [`/ai`](./ai) | `AI_GUIDE.md` — single canonical AI/agent guide (merged 3 overlapping docs). |
| [`/dev`](./dev) | `DEV_LAB_SETUP.md` (verified-working Distrobox setup), `GITHUB_COLAB_INTEGRATION.md`. |
| [`/gaming`](./gaming) | `GAMING_HANDBOOK.md` — corrected launch options, MangoHud, `gh` CLI usage. |
| [`/scripts`](./scripts) | `ai-with-memory`, `ai-learn`, `ai-remember`, `ai-progress` (the real CLI toolbelt), `avalhla_tools_check.sh`. |

## What changed from V0.2 → V0.3

This wasn't just a folder reshuffle — the old flat repo had **real bugs
duplicated across multiple files**. Full details in `CHANGELOG.md`; headline
fixes:

- `distrobox-export --app cava` (fails — cava has no `.desktop` file) → fixed
  to `--bin` everywhere it appeared.
- `java-17-openjdk-devel` / `java-21-openjdk-devel` (don't resolve on
  Fedora 44) → replaced with the verified working method everywhere.
- Dead `file:///home/VVgbon/.gemini/antigravity/brain/...` links (from a
  different AI tool's temp session) → replaced with relative repo links.
- Three near-duplicate AI guides → merged into one `/ai/AI_GUIDE.md`.
- Radio project (`MASTER_RADIO_GUIDE.md`, `master_radio_builder.py`,
  `AVALHLA_AI_TRAINING_PROMPTS.md`) → removed entirely.

## Quick Start

```bash
# 1. Update the entire system safely (OS, Flatpaks, containers)
topgrade

# 2. Start chatting with Avalhla on your RTX 3060
./scripts/ai-with-memory

# 3. Enter your isolated development environment
distrobox enter coding-lab

# 4. Verify coding-lab dependencies
./scripts/avalhla_tools_check.sh
```

## ⛔ Immutable OS Rules (full detail in `/persona/system-prompt.txt`)

1. Never `rpm-ostree install` random packages on the host — layered packages
   are limited to `coolercontrol`, `liquidctl`, `mangohud`, `topgrade`, `gh`.
2. All dev tooling runs inside `distrobox enter coding-lab`.
3. GUI apps install via Flatpak.
4. RTX 3060 power cap: 170W. CPU governor via TuneD only.
5. CLI tools with no `.desktop` file (e.g. `cava`) export with
   `distrobox-export --bin`, never `--app`.

## License & Credits

- Maintained by **Dawa** (`VVgbon916`).
- Built for **Bazzite DX** / the **Universal Blue** project.
- Local AI: **Qwen 2.5 Coder** via **Ollama**.
