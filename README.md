# Avalhla -- V1 (single branch)

> Operator: Dawa (VVgbon@VVgBazz)
> AI Companion: Avalhla (Ava)
> Base Platform: Bazzite DX NVIDIA 44 (Fedora Atomic / KDE Wayland)
> Repository: https://github.com/VVgbon916/cheatsheets

One branch. One source of truth. No duplicates.

## Layout

| Path | Contents |
|---|---|
| persona/   | avalhla.Modelfile, system-prompt.txt, user-profile.txt.example |
| scripts/   | all tools: memory (ai-*), lifecycle (ava-*), launcher, verify |
| lore/      | Canon, Avatars, Names, story, visual, law, habitat, archive |
| system/    | SYSTEM_GUIDE, MAINTENANCE_DEBUG_GUIDE, SYSTEM_PROFILE |
| ai/ dev/ gaming/ | AI guide, dev lab, gaming handbook |
| _index/    | D42k.public.md, Sub.files.md |
| Makefile   | make verify / fix / ai / ava-start / ava-stop / ava-status |
| *.txt      | BOARD.txt, AVALHLA_CHEATSHEET.txt, AVALHLA_COMMANDS.txt |

## Quick Start

    make ava-start     # boot the Ollama container (once per boot)
    make ai            # talk to Avalhla
    make ava-stop      # free VRAM

## Rules

    Ollama runs in a Podman container via ollama.service (systemd user).
    Never edit ~/.ai-memory/ manually. Never topgrade. Never sudo dnf on host.

    Dawa > AwA < Avalhla.  (^.-)
