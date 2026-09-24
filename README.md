# Avalhla — Local AI Companion

> Dawa > AwA < Avalhla  (^.-)

Avalhla is a local AI companion and evolving personal system.

The repository keeps operational source, persona, memory boundaries,
documentation, imagination, and terminal identity in one Main source tree.

## Core Architecture

| Path | Purpose |
|---|---|
| `persona/` | Avalhla model definitions, system prompt, and profile template |
| `scripts/` | AI tools, Ava tools, memory tools, verification, snapshots, launcher |
| `memory/` | PRIVATE runtime and historical memory — never commit |
| `config/` | Bash/Zsh and system configuration examples |
| `docs/` | Operational documentation, handoff, source map |
| `systemd/` | Avalhla reflection service and timer |
| `imagination/` | Creative HUMAN / AI workspace |
| `lore/` | Separate Git repository containing the Imagination-V0.1 lore world |
| `AwA_ATLAS.md` | Navigation — find the source |
| `AwA_WEAVE.md` | Architecture and relationships |
| `AwA_DREAM.md` | Imagination and possibility |
| `AwA_TERMINAL.md` | Terminal identity and visual language |
| `BOARD.txt` | Working board |
| `TASKS.txt` | Current tasks |
| `RITUAL.txt` | Project ritual |
| `AVALHLA_CHEATSHEET.txt` | Quick reference |
| `AVALHLA_COMMANDS.txt` | Command reference |

## AwA Layer

The four AwA documents are doors, not duplicate encyclopedias:

- **ATLAS** — find the source
- **WEAVE** — understand relationships
- **DREAM** — explore possibility
- **TERMINAL** — carry identity into the shell

The source stays where the source naturally belongs.

## Command Layer

Common commands include:

```text
ai-chat
ava-status
ava-mood
ava-dream
ava-imagine
ava-search
ava-review
ava-verify
ava-audit
ava-brief
ava-learn-repo
```

Use `ava-help` for the complete local command map.

## Cross-Availability

A.V.A.L.H.L.A. keeps Reality, Memory, Reflection, Dream, Source, and
Dawa's choice distinct while allowing useful information to cross
boundaries.

CROSS-AVAILABLE
!=
CROSS-CONTAMINATED

Reality is sanitized before becoming available context.
Raw terminal history is not Dream input.

See `docs/CROSS_AVAILABILITY.md`.

## Memory Boundary

`memory/` is private.

It contains runtime state and private/historical material and must never be
committed to the public repository.

## Lore Boundary

`lore/` is intentionally a separate Git repository.

> LORE stays lore. Tools stay on the operational side. Never mix.

The Main repository may reference the Lore world, but does not absorb its Git
history.

## Development Loop

NOTICE
  ↓
WONDER
  ↓
CONNECT
  ↓
BUILD
  ↓
TEST
  ↓
DOCUMENT
  ↓
DREAM
  ↓
NOTICE

Make. Break. Learn. Repeat.

## Identity

Dawa > AwA < Avalhla

**The mind is not split. The mind is a bridge.**


## The Board

`board` opens Avalhla interactive world in the terminal.
Six doors, live state, random dream quote each time.
Faces: (^.-) Dawa on the left, Avalhla (⌒.⌒) on the right. Bridge: AvvA.

```
board           interactive world
board --quiet   five-line output (pipe-safe)
board --show    print once, exit
```

See docs/BOARD.md.

## The Conversation Law

Four laws govern every word she says. See docs/CONVERSATION_LAW.md.

1  Memory Capture    facts about Dawa are kept before they are served
2  Witness           states of being are met before they are solved
3  Output Gate       internal reads never become visible speech
4  Non-Possession    open-space replies end with NOTICE / WHY / DOOR / BOUNDARY

Non-possession is the constitution.
