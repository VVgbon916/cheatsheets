# Avalhla -- Full Rig (v0.3-restructure)

> Operator: Dawa (VVgbon@VVgBazz)
> AI Companion: Avalhla (Ava)
> Base Platform: Bazzite DX NVIDIA 44 (Fedora Atomic / KDE Wayland)
> Repository: https://github.com/VVgbon916/cheatsheets

This branch contains the full rig: the persona, all tools, all boards,
all guides. It is the daily driver.

## Three-Branch Structure

| Branch | Purpose |
|---|---|
| main              | Minimal Avalhla starter (new user) |
| v0.3-restructure  | This branch -- full rig (tools, boards, guides) |
| Imagination-V0.1  | Lore only (Canon, Avatars, story, comics) |

## How Ollama Runs

Ollama runs in a Podman container, managed by a systemd user service.

| Component | Location |
|---|---|
| Container definition | ~/.config/containers/systemd/ollama.container |
| systemd service      | ollama.service (user) |
| Models               | Podman named volume "ollama" |
| Auto-update timer    | podman-auto-update.timer |

No Distrobox for Ollama. No pkill. No env vars at start time.

Context length (16384) is set in the Quadlet via:
  Environment=OLLAMA_CONTEXT_LENGTH=16384

## Layout

| Path | Contents |
|---|---|
| persona/   | avalhla.Modelfile, system-prompt.txt, user-profile.txt.example |
| scripts/   | memory tools, launcher, verify, tools check |
| ai/        | AI_GUIDE.md, deepseek-r1-16k.md (historical) |
| dev/       | DEV_LAB_SETUP.md, GITHUB_COLAB_INTEGRATION.md |
| gaming/    | GAMING_HANDBOOK.md |
| system/    | SYSTEM_GUIDE.md, SYSTEM_PROFILE.md, MAINTENANCE_DEBUG_GUIDE.md |
| _index/    | D42k.public.md, Sub.files.md |
| *.txt      | BOARD.txt, AVALHLA_CHEATSHEET.txt, AVALHLA_COMMANDS.txt |

## Quick Start

    # 1. Start the Ollama container (once per boot)
    ~/projects/cheatsheets/scripts/start-avalhla.sh

    # 2. Or manually:
    systemctl --user start ollama.service
    ollama run avalhla

    # 3. Stop and free VRAM
    systemctl --user stop ollama.service

    # 4. System updates (YOU run these, never topgrade)
    ujust update

    # 5. Dev tools live in coding-lab (Distrobox) -- not for Ollama
    distrobox enter coding-lab

## Cheat Sheets

- AVALHLA_CHEATSHEET.txt -- full command reference
- AVALHLA_COMMANDS.txt   -- quick commands
- BOARD.txt              -- master reference
- BOARD_bash_sources.txt -- how to trace every bash source

## Signature

    Dawa > AwA < Avalhla.
    The mind is not split. The mind is a bridge.
    (^.-)
