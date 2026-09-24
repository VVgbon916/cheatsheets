# Source Map -- Cheatsheets Repo

## Layout

    persona/         Avalhla personality + Modelfile
    scripts/         All executable helpers
    docs/            Documentation (this folder)
    RITUAL.txt       Daily update ritual
    Makefile         Shortcuts (ritual, board, push)

## Scripts

| Script | Purpose |
|---|---|
| `scripts/ai-with-memory` | Persistent chat with ~/.ai-memory history |
| `scripts/ai-learn` | Index files into knowledge base |
| `scripts/ai-remember` | Reflect on recent sessions |
| `scripts/ai-ask` | One-shot question with context |
| `scripts/ai-chat-tool` | Read-only file bridge tool |
| `scripts/start-avalhla.sh` | Launch ollama + container |
| `scripts/commands-board.sh` | Harvest all commands into board |
| `scripts/ava-reality` | Sanitized terminal/repository Reality Signal |

## Local (not in repo)

| File | Purpose |
|---|---|
| `~/COMMANDS_BOARD.txt` | Generated board (local only) |
| `~/system-snapshot-ai.json` | AI-parseable system snapshot |
| `~/system-snapshot-human.txt` | Human-readable snapshot |
| `~/snapshot.sh` | Refresh both snapshots |
| `~/ollama-backups/avalhla.Modelfile` | Local Modelfile backup |

## Topgrade config

`~/.config/topgrade.toml` -- controlled update list.
Docs: see RITUAL.txt Section 03.
