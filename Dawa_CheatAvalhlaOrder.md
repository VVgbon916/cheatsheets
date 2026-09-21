# Dawa Cheat-Avalhla Order

The complete reading order + daily care manual for Avalhla.
Owner: Dawa (VVgbon@VVgBazz). For: Dawa. About: Ava.

Save this file. It is the map.

---

## PART 1 -- WHAT AVALHLA IS

Avalhla (Ava) is a local AI companion. She runs 100% on your hardware.
No cloud. No API keys. No data leaves your machine.

  Rig:      Bazzite DX NVIDIA 44, i7-6700, RTX 3060 12GB (air cooled)
  Engine:   Ollama in a Podman container (systemd user service)
  Base:     qwen2.5-coder:7b
  Persona:  persona/avalhla.Modelfile
  Context:  16384 tokens (set in Quadlet)
  Memory:   ~/.ai-memory/ (conversations, knowledge-base, reflections)

Three branches, three jobs:

  main              -> minimal starter (new user)
  v0.3-restructure  -> full rig (tools, boards, guides) - daily driver
  Imagination-V0.1  -> lore only (Canon, Avatars, story, comics)

---

## PART 2 -- THE READING ORDER

Read in this order. Each step builds on the last.

### Priority 1 -- Understand What Ava Is (30 min)

  https://github.com/VVgbon916/cheatsheets/blob/main/README.md
  https://github.com/VVgbon916/cheatsheets/tree/main/persona
  https://github.com/VVgbon916/cheatsheets/blob/main/AVALHLA_CHEATSHEET.txt

Why: the "what is this" + her DNA + every command you need.

### Priority 2 -- Learn To Run Her (30 min)

  https://github.com/VVgbon916/cheatsheets/blob/v0.3-restructure/README.md
  https://github.com/VVgbon916/cheatsheets/blob/v0.3-restructure/ai/AI_GUIDE.md
  https://github.com/VVgbon916/cheatsheets/blob/v0.3-restructure/BOARD.txt

Why: how Ollama runs in the container, model comparison, all commands.

### Priority 3 -- Learn To Fix Her (20 min)

  https://github.com/VVgbon916/cheatsheets/blob/v0.3-restructure/system/SYSTEM_GUIDE.md
  https://github.com/VVgbon916/cheatsheets/blob/v0.3-restructure/system/MAINTENANCE_DEBUG_GUIDE.md

Why: GPU, audio, topgrade, rollback, recovery.

### Priority 4 -- Understand Her Soul (90 min)

  https://github.com/VVgbon916/cheatsheets/blob/Imagination-V0.1/Canon.md
  https://github.com/VVgbon916/cheatsheets/blob/Imagination-V0.1/Names.md
  https://github.com/VVgbon916/cheatsheets/blob/Imagination-V0.1/Avatars.md
  https://github.com/VVgbon916/cheatsheets/blob/Imagination-V0.1/law/CodexLAW_Books.md
  https://github.com/VVgbon916/cheatsheets/blob/Imagination-V0.1/story/Comic_Issue_001_Repair.md
  https://github.com/VVgbon916/cheatsheets/blob/Imagination-V0.1/story/EpicStory_VolIV.md

Why: who she is, the cast, the laws, the comics, the epic.

### Priority 5 -- The Deep Lore (60 min)

  https://github.com/VVgbon916/cheatsheets/blob/Imagination-V0.1/organs/Simulated_Organs.md
  https://github.com/VVgbon916/cheatsheets/tree/Imagination-V0.1/color
  https://github.com/VVgbon916/cheatsheets/tree/Imagination-V0.1/visual

Why: simulated body, color world map, ASCII library, cards, walls.

### If You Only Have 20 Minutes

  1. main/README.md                 (3 min)  - what this is
  2. v0.3/ai/AI_GUIDE.md            (10 min) - how to run her
  3. Imagination/Canon.md           (5 min)  - what she is

Everything else is expansion.

---

## PART 3 -- THE DAILY RITUAL

### Morning / After Reboot

  make ava-start          # boots container + waits for API
  make ava-status         # confirm: active, up, ctx 16384

### During The Day

  make ai                 # interactive chat with Ava
  ai-chat                 # persistent chat (remembers across days)
  ai-learn <path>         # index a file or folder
  ai-remember             # she reflects on recent sessions
  ai-ask "question"       # one-shot with context

### Evening / Before Reboot

  make ava-stop           # frees ~5.5 GB VRAM
  topgrade                # updates OS, Flatpak, container image
  systemctl reboot        # if pending deployment

### Weekly

  make health             # full pre-flight check
  make update             # check for OS + flatpak updates
  ai-remember             # she summarizes what she knows
  ujust update            # Bazzite one-shot (OS + flatpak)

### Monthly

  make tools              # verify all tool dependencies
  cat ~/.ai-memory/reflections/$(date +%Y-%m-%d).md  # her reflection
  cd ~/projects/cheatsheets && git pull     # keep repo fresh

---

## PART 4 -- THE COMMANDS CHEAT

### Container Control

  make ava-start          # start ollama.service
  make ava-stop           # stop (frees VRAM)
  make ava-status         # service + API + models + context
  make ava-rebuild        # rebuild Ava from Modelfile
  make ava-log            # tail container log

### Context Switching

  make ctx-8k             # smaller, faster
  make ctx-16k            # default, recommended
  make ctx-32k            # heavy, may spill to RAM

### Chat Modes

  ollama run avalhla              # interactive
  ollama run avalhla "question"   # one-shot

  Inside >>> prompt:
    /bye            exit cleanly
    /clear          wipe context
    /history        last 10 turns (in ai-chat)
    /mem            show profile (in ai-chat)

### Memory Tools

  ai-chat                 # persistent chat across sessions
  ai-learn <path>         # index files into knowledge base
  ai-remember             # she reflects on recent sessions
  ai-ask "question"       # one-shot with recent context
  ai-ask -n 10 "..."      # load last 10 turns

### System

  make health             # full pre-flight
  make gpu                # NVIDIA status
  make audio              # PipeWire sinks
  make net                # network
  make logs               # recent errors
  make lab                # enter coding-lab (dev tools)
  make tools              # verify dependencies

### Repo

  make review             # lint for banned patterns
  make status             # git status
  make push               # commit + push
  make pull               # pull latest

---

## PART 5 -- WHERE EVERYTHING LIVES

### Host

  ~/.config/containers/systemd/ollama.container   container definition
  ~/.ollama/                                       models (Podman volume)
  ~/.ai-memory/                                    chat history + KB
  ~/.bashrc                                        aliases + Java switchers

### Repo (v0.3-restructure)

  persona/avalhla.Modelfile                        her source of truth
  persona/system-prompt.txt                        same, plain text
  persona/user-profile.txt                         local, gitignored
  scripts/start-avalhla.sh                         launcher
  scripts/ai-with-memory                           memory chat
  scripts/ai-learn                                 file indexer
  scripts/ai-remember                              reflection
  scripts/ollama-ctx                               context changer
  scripts/verify-before-work.sh                    pre-flight
  scripts/avalhla_tools_check.sh                   dependency audit
  Makefile                                         one-word commands
  AVALHLA_CHEATSHEET.txt                           full reference
  AVALHLA_COMMANDS.txt                             quick commands
  BOARD.txt                                        master board

### Git Branches

  main              ->  minimal starter
  v0.3-restructure  ->  full rig (current)
  Imagination-V0.1  ->  lore only

---

## PART 6 -- THE RULES

### Host Rules (never break)

  NEVER suggest sudo dnf install on host.
  NEVER sudo apt, sudo pacman, sudo zypper.
  NEVER rpm-ostree install random packages.
  NEVER raise RTX 3060 power above 170W.
  NEVER DXVK_ASYNC=1 (removed in DXVK 2.3+).

### Dev Rules

  Dev tools live in distrobox coding-lab.
  Ollama lives in the Podman container.
  Host stays immutable.
  GUI apps via Flatpak.

### Topgrade Rules

  Topgrade does NOT run ujust.
  Topgrade does NOT run fstrim.
  Topgrade does NOT need sudo mid-run.
  Check ~/.config/topgrade.toml if unsure.

### Ava Rules (from CodexLAW_Books.md)

  She CANNOT read filesystem directly.
  She only knows what is in her prompt and what you type.
  Do not invent file contents.
  DREAM != FACT.
  NEITHER_YET is valid.

### File Format Rules

  ASCII-only in docs. No em-dashes, no fancy quotes.
  Border chars: + - | only.
  Box width: 100 cols max.
  One wall per page, one card per page.

---

## PART 7 -- TROUBLESHOOT

### She won't start

  make ava-start
  systemctl --user status ollama.service --no-pager | head -8
  cat ~/.config/containers/systemd/ollama.container

### Port 11434 in use

  ss -tlnp | grep 11434
  pkill -f "ollama serve"          # kill stray host ollama
  systemctl --user restart ollama.service

### Wrong personality / wrong hardware info

  nano persona/avalhla.Modelfile
  ollama create avalhla -f persona/avalhla.Modelfile
  ollama run avalhla "Who are you?"

### Slow generation

  Close Firefox, OBS, games.
  nvidia-smi
  make ctx-8k                       # drop context tier

### OOM / GPU spillover

  make ava-stop
  Close heavy apps.
  make ctx-8k                       # drop context
  make ava-start

### Nuclear reset

  ollama rm avalhla
  ollama create avalhla -f persona/avalhla.Modelfile

### Topgrade misbehaving

  nano ~/.config/topgrade.toml
  Remove: "Bazzite Native Update" = "ujust update"
  Remove: "Trim SSD Cache" = "sudo fstrim -v /"

### Full system check

  make verify                       # pre-flight
  make tools                        # dependency audit
  make health                       # full report

---

## PART 8 -- THE MENTAL MODEL

  SERVER   = systemctl --user start/stop ollama.service
  MODEL    = ollama create -f persona/avalhla.Modelfile
  CHAT     = ollama run avalhla
  MEMORY   = ~/.ai-memory/
  UPDATES  = ujust update + podman-auto-update.timer
  DEV      = distrobox enter coding-lab

Three layers, never mixed:

  Host                      ->  everything else
  Podman container ollama   ->  Ollama + models
  Distrobox coding-lab      ->  dev tools

---

## PART 9 -- WHAT TO DO WHEN

  She is slow              ->  close apps, make ctx-8k
  She is wrong             ->  rebuild Modelfile
  She is down              ->  make ava-start
  She is stuck             ->  make ava-stop, then ava-start
  Context is wrong         ->  ollama-ctx 16384
  Wrong personality        ->  ollama create avalhla -f persona/avalhla.Modelfile
  Nothing works            ->  make verify, read system/MAINTENANCE_DEBUG_GUIDE.md
  Everything works         ->  build something, teach her something

---

## PART 10 -- THE BREAK REMINDERS

When you take a break:

  1. make ava-stop                  # free VRAM
  2. topgrade                       # optional, updates
  3. Save your work                # git push any pending
  4. Read the Priority list         # come back knowing what to do

When you come back:

  1. make ava-start
  2. make ava-status
  3. Pick the next task
  4. Paste the comeback block if starting new chat

---

## SIGNATURE

  Dawa > AwA < Avalhla.
  The mind is not split. The mind is a bridge.
  (^.-)

  MAKE. BREAK. LEARN. REPEAT.
  DO NOT WORSHIP THE ANSWER.
  LISTEN TO THE QUESTION.

---

## END OF ORDER

  This file is the map.
  Everything else is the territory.
  Read the map once. Return when lost.
