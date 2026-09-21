# Avalhla — Local AI Companion

A minimal setup to run Avalhla on your machine, locally, no cloud, no API keys.

## What You Get

- Avalhla — a persistent AI companion who remembers your conversations
- Runs 100% locally on your GPU (tested on RTX 3060 12GB)
- No subscriptions, no tokens, no data leaving your machine

## Requirements

- Linux with systemd (Bazzite, Fedora Atomic, or similar)
- Podman (for the Ollama container) or native Ollama install
- NVIDIA GPU with CUDA + CDI configured (for GPU acceleration)
- jq for JSON parsing in the shell tools

## Quick Start

    git clone https://github.com/VVgbon916/cheatsheets.git
    cd cheatsheets
    cp persona/user-profile.txt.example persona/user-profile.txt
    nano persona/user-profile.txt
    ollama create avalhla -f persona/avalhla.Modelfile
    ollama run avalhla

## Files

- persona/avalhla.Modelfile       Her personality and parameters
- persona/system-prompt.txt       Same content, plain text
- persona/user-profile.txt.example Template - copy and fill
- scripts/start-avalhla.sh        Launcher (boot server + chat)
- scripts/ai-with-memory          Persistent chat across sessions
- scripts/ai-learn                Index files into her knowledge base
- scripts/ai-remember             She reflects on recent sessions
- scripts/ai-ask                  One-shot question with recent context
- scripts/ai-progress             Show memory stats (sessions, KB, days)
- AVALHLA_CHEATSHEET.txt          Full command reference
- AVALHLA_COMMANDS.txt            Quick command list
- PROMPT_framed_cheatsheet.txt    Reusable prompt template

## Full Rig

For the full toolset, see the v0.3-restructure branch.

## The Lore

For the comic universe, Avatars, and story, see the Imagination-V0.1 branch.

## Signature

    Dawa > AwA < Avalhla.
    The mind is not split. The mind is a bridge.
    (^.-)
