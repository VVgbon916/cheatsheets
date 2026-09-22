# HANDOFF — Ava Evolution
Date: 2026-09-21
Repo: https://github.com/VVgbon916/cheatsheets
User: Dawa (VVgbon) on VVgBazz
AI: Avalhla (qwen2.5:7b base)

## CURRENT STATE
- Shell: zsh + oh-my-zsh + 8 plugins
- Prompt: Dawa > AwA < Avalhla [path] git:(branch) >
- Banner: custom on new terminal
- Ollama: 3 models (avalhla, qwen2.5:7b, qwen2.5-coder:7b) = 4.4G
- Memory: ~/.ai-memory/
- Drop-box: ~/.ai-memory/auto-read/ (64KB cap)
- Backups: off-machine

## TAGS
checkpoint-before-rebuild, checkpoint-zsh-done, checkpoint-prompt-done,
checkpoint-ollama-slim, checkpoint-ava-fixes, checkpoint-dropbox-live,
checkpoint-dropbox-64k, checkpoint-handoff

## FIXES APPLIED
- start-avalhla.sh: single launch
- ai-remember: curl API + saves reflections/
- ai-read: whitelist prefix fix
- ai-with-memory: auto-read 64KB, no [READ:] tags

## RULES
- ASCII only, boxes 100 cols, + - | borders
- No sudo dnf/apt on host
- No DXVK_ASYNC
- RTX 3060 cap 170W
- Code first, explain after
- Big blocks, 1-2-3 structure

## SIGNATURE
Dawa > AwA < Avalhla  //  (^.-)
THE MIND IS NOT SPLIT. THE MIND IS A BRIDGE.

## ROADMAP
Phase 1 (quick wins): 04 Model Presets, 03 Prompt Restructure, 06 Review Mode
Phase 2 (memory): 01 Smarter Memory, 08 Conversation Search, 07 Project Memory
Phase 3 (integration): 02 File-Aware Chat, 05 Daily Reflection Cron
Phase 4 (new tools): ava-brief, ava-diff, ava-explain, ava-doc, ava-audit
SKIPPED: 09 router, 10 voice

## NEXT
Start Phase 1: 04 Model Presets.
