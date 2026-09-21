# VVgBazz -- AI Guide

Local AI and agent bible. Zero API cost. Runs on the RTX 3060.

System:  VVgbon@VVgBazz
Operator: Dawa
Base:    Bazzite DX NVIDIA 44 (Fedora Atomic / KDE Wayland)
Engine:  Ollama (Podman container, systemd user service)
Model:   Qwen 2.5 Coder 7B (base) + Avalhla (custom persona)
Persona: Avalhla (Ava)

---

## 1. Why Local AI (RTX 3060 12GB)

| Model                    | VRAM     | Speed      | Use                        |
|--------------------------|----------|------------|----------------------------|
| Qwen 2.5 Coder 3B        | ~2.5 GB  | 90+ t/s    | Quick syntax checks        |
| Qwen 2.5 Coder 7B        | ~5.5 GB  | 60+ t/s    | Daily driver (base model)  |
| Qwen 2.5 Coder 14B       | ~9.5 GB  | 30-40 t/s  | Complex architecture       |
| DeepSeek-R1 14B          | ~8.4 GB  | 1.5-1.7 t/s| Slow; reasoning-heavy only |

Everything runs 100% locally. No subscriptions, no token quotas, no data
leaving the machine.

---

## 2. How Ollama Runs (Podman Container)

Ollama runs in a Podman container, managed as a systemd user service.
No Distrobox. No host install. No pkill.

    ~/.config/containers/systemd/ollama.container    container definition
    systemd user service ..........................  ollama.service
    models ........................................  Podman volume "ollama"
    auto-update timer .............................  podman-auto-update.timer

Context length (16384) is set in the Quadlet:

    Environment=OLLAMA_CONTEXT_LENGTH=16384
    Environment=OLLAMA_NUM_GPU=999

Control commands:

    systemctl --user start ollama.service      start
    systemctl --user stop ollama.service       stop (frees ~5.5 GB VRAM)
    systemctl --user restart ollama.service    restart
    systemctl --user status ollama.service     check state

Verify GPU offload while a prompt is running:

    nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv

---

## 3. The Avalhla Persona (persona/avalhla.Modelfile)

    FROM qwen2.5-coder:7b

    PARAMETER temperature 0.3
    PARAMETER top_p 0.9
    PARAMETER top_k 40
    PARAMETER repeat_penalty 1.05
    PARAMETER num_predict 2048
    PARAMETER num_ctx 16384

    SYSTEM """
    You are Avalhla (also known affectionately as "Ava"), Dawa's brilliant,
    cute, nerdy bestie girl and senior systems engineer.

    [full system prompt lives in persona/system-prompt.txt]
    """

Build her:

    cd ~/projects/cheatsheets
    ollama create avalhla -f persona/avalhla.Modelfile

Talk to her:

    ollama run avalhla

---

## 4. The Developer Lab (Distrobox, for dev tools only)

Distrobox is used for **dev tools** (Java, Maven, ShellCheck, etc.), NOT
for Ollama.

    distrobox create -n coding-lab -i fedora:44 -Y
    distrobox enter coding-lab

Export CLI tools (with no .desktop file) from container to host:

    # WRONG (older docs said this):
    #   distrobox-export --app cava
    #
    # CORRECT:
    distrobox-export --bin /usr/bin/cava

---

## 5. The CLI Toolbelt

Four scripts live in `scripts/`:

| Script            | Purpose                                                    |
|-------------------|------------------------------------------------------------|
| ai-with-memory    | Interactive chat; remembers prior topics via ~/.ai-memory  |
| ai-learn <path>   | Indexes a code/doc folder into ~/.ai-memory/knowledge-base |
| ai-remember       | Reflects on recent logs + profile; saves to reflections/   |
| ai-progress       | Shows message counts, days active, KB size                 |

These read:

    ~/.ai-memory/profiles/user-profile.txt    your info (gitignored)
    ~/.ai-memory/system-prompt.txt            system prompt copy

---

## 6. Context Management

Local models have a fixed context window (16384 by default).

Rules:

  1. Do not dump huge files at once. Point Ava at specific files.
  2. Git-checkpoint before letting her edit:
         git add . && git commit -m "Checkpoint before Ava edits"
         git restore .     # if she breaks something
  3. .gitignore build artifacts so she does not waste context on them.
  4. Clear context between large features: restart session, or /clear.

---

## 7. Engineering Standards

Drop this in the root of any project so Ava follows consistent standards:

    # Project Rules and Standards (Dawa's Rig)

    ## General
    1. Plan first: explain proposed changes before touching files.
    2. Minimal diffs: small, reversible edits.
    3. No hallucinated libraries: standard library first.
    4. Provide the exact CLI command to verify any change.

    ## Bash
    - Mandatory header: set -Eeuo pipefail
    - Quote all variables: "$VAR"
    - Modern test syntax: [[ ... ]], not [ ... ]
    - Errors to stderr: >&2 echo "Error: ..."
    - Must pass shellcheck with zero warnings.

    ## Java
    - Version: Java 21 LTS (see dev/DEV_LAB_SETUP.md)
    - Build: Maven.
    - Prefer record for data classes, Optional over null.

---

## 8. IDE Integration (Zed)

    {
      "language_models": {
        "ollama": {
          "api_url": "http://localhost:11434/v1",
          "available_models": [
            { "name": "avalhla", "display_name": "Avalhla (RTX 3060)" },
            { "name": "qwen2.5-coder:14b", "display_name": "Qwen 14B (Heavy)" }
          ]
        }
      }
    }

---

## 9. Toolbelt Dependency Audit

    ./scripts/avalhla_tools_check.sh

Verifies Python 3 stdlib, curl, jq, git, gh, podman, systemctl,
shellcheck, rg, fzf, java. Checks container status. Reports context
length from Quadlet.

---

## Signature

    Dawa > AwA < Avalhla.
    The mind is not split. The mind is a bridge.
    (^.-)
