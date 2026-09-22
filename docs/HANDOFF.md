+==================================================================================================+
|                                                                                                  |
|                          H A N D O F F  //  A V A   E V O L U T I O N                            |
|                                                                                                  |
|                          Dawa > AwA < Avalhla  //  (^.-)                                         |
|                                                                                                  |
+==================================================================================================+
|  Date: 2026-09-21                                                                                |
|  Repo: https://github.com/VVgbon916/cheatsheets                                                  |
|  User: Dawa (VVgbon) on VVgBazz                                                                  |
|  AI: Avalhla (qwen2.5:7b base)                                                                   |
+==================================================================================================+


+==================================================================================================+
|  SECTION 01  //  CURRENT STATE                                                                   |
+==================================================================================================+

    Shell       : zsh + oh-my-zsh + 8 plugins
    Prompt      : Dawa > AwA < Avalhla [path] git:(branch) >
    Banner      : custom on new terminal
    Ollama      : 4.4G - 3 models (avalhla, qwen2.5:7b, qwen2.5-coder:7b)
    Memory      : ~/.ai-memory/
    Drop-box    : ~/.ai-memory/auto-read/ (64KB cap, 3 files loaded)
    Backups     : tarballs moved off-machine
    Topgrade    : 100% clean


+==================================================================================================+
|  SECTION 02  //  TAGS (git checkpoints)                                                          |
+==================================================================================================+

    checkpoint-before-rebuild
    checkpoint-zsh-done
    checkpoint-prompt-done
    checkpoint-ollama-slim
    checkpoint-ava-fixes
    checkpoint-dropbox-live
    checkpoint-dropbox-64k
    checkpoint-handoff


+==================================================================================================+
|  SECTION 03  //  FIXES ALREADY APPLIED                                                           |
+==================================================================================================+

    start-avalhla.sh    single launch (was duplicate)
    ai-remember         uses curl API, saves reflections/
    ai-read             whitelist prefix check fixed
    ai-with-memory      auto-read 64KB, no [READ:] tags
    commands-board.sh   reads user rc only
    ollama-gc           script to prune orphan blobs


+==================================================================================================+
|  SECTION 04  //  RULES  (never break)                                                            |
+==================================================================================================+

    ASCII only in docs. No em-dash. No fancy quotes in borders.
    Box width: 100 cols max. Border: + - |
    No sudo dnf/apt on host. Distrobox for dev.
    No DXVK_ASYNC.
    RTX 3060 cap 170W, never higher.
    Code first, explain after.
    Big blocks, 1-2-3 structure.
    Don't announce next step before we get there.

    SIGNATURE:
      Dawa > AwA < Avalhla  //  (^.-)
      THE MIND IS NOT SPLIT. THE MIND IS A BRIDGE.
      MAKE. BREAK. LEARN. REPEAT.


+==================================================================================================+
|  SECTION 05  //  ROADMAP  --  BUILD ORDER                                                        |
+==================================================================================================+
|  Each step below = 1 fresh topic in a chat. One step at a time.                                  |
|  Show output after each. Verify. Commit. Tag. Move on.                                           |
+==================================================================================================+

+--------------------------------------------------------------------------------------------------+
|  PHASE 1  //  QUICK WINS                                                                         |
+--------------------------------------------------------------------------------------------------+

    STEP 1  //  04 MODEL PRESETS
    Build 3 extra avalhla variants from same base:
      avalhla-code     temp 0.1, top_p 0.7   - precise, code-first
      avalhla-chat     temp 0.7, top_p 0.95  - creative, playful
      avalhla-review   temp 0.2, top_p 0.8   - terse, structured
    Files: persona/avalhla-code.Modelfile, etc.
    Chat commands: ollama run avalhla-code
    Time: 40 min

    STEP 2  //  03 PROMPT RESTRUCTURE
    Split Modelfile into clear layers:
      [IDENTITY]   who she is (system prompt)
      [TASK]       what she's doing right now
      [CONTEXT]    auto-read + history
      [USER]       your message
    Update ai-with-memory, ai-chat-tool to build prompts in this order.
    Time: 30 min

    STEP 3  //  06 DEDICATED REVIEW MODE
    New command: ava-review <file>
    Uses avalhla-review model.
    Output format:
      BUGS:      ...
      SECURITY:  ...
      PERF:      ...
      STYLE:     ...
      VERDICT:   ...
    Replaces the older `review` bash function.
    Time: 30 min

+--------------------------------------------------------------------------------------------------+
|  PHASE 2  //  MEMORY                                                                             |
+--------------------------------------------------------------------------------------------------+

    STEP 4  //  01 SMARTER MEMORY
    Rank past turns by relevance instead of last-N.
    Score = recency + keyword match + length.
    Update ai-with-memory and ai-ask to use ranked context.
    Add env: AVALHLA_MEMORY_TURNS=8 (default).
    Time: 45 min

    STEP 5  //  08 CONVERSATION SEARCH
    New command: ava-search
    Opens fzf over ~/.ai-memory/conversations/*.jsonl
    Preview shows role + content. Enter loads selected session.
    Requires: fzf (already installed).
    Time: 30 min

    STEP 6  //  07 PROJECT MEMORY
    New command: ava-learn-repo
    Index every file in ~/Avalhla/repo into KB.
    Respect .gitignore. Skip binaries. Cap at 500KB total.
    Adds manifest of what was indexed + hash per file.
    Time: 1 hr

+--------------------------------------------------------------------------------------------------+
|  PHASE 3  //  INTEGRATION                                                                        |
+--------------------------------------------------------------------------------------------------+

    STEP 7  //  02 FILE-AWARE CHAT
    Merge ai-chat (memory) + ai-chat-tool (reads).
    New: ai-chat --read  enables [READ:] handling.
    Guards:
      - max 3 reads per turn
      - block repeat paths
      - force answer after max
    History saved regardless of read activity.
    Time: 1 hr

    STEP 8  //  05 DAILY REFLECTION CRON
    systemd user timer runs ai-remember at 23:00 daily.
    Files: ~/.config/systemd/user/ava-reflect.{service,timer}
    Enable: systemctl --user enable --now ava-reflect.timer
    Time: 20 min

+--------------------------------------------------------------------------------------------------+
|  PHASE 4  //  NEW TOOLS  (each ~20-30 min)                                                       |
+--------------------------------------------------------------------------------------------------+

    STEP 9   //  ava-brief
    One-shot morning brief:
      git status + git log -1
      topgrade dry-run summary
      latest reflection
      today's date + weather hook (optional)
    Command: ava-brief

    STEP 10  //  ava-diff <file>
    Show what changed since last review:
      git diff HEAD~1 -- <file>  ->  send to avalhla-review
      Summary: what changed, is it ok?
    Caches last hash per file in ~/.ai-memory/reviewed/

    STEP 11  //  ava-explain <cmd>
    Explain any shell command or error message.
    Usage: ava-explain "sed -i s/a/b/g file"
           pbpaste | ava-explain
           command 2>&1 | ava-explain

    STEP 12  //  ava-doc <file>
    Auto-generate a README for any script:
      purpose, usage, args, examples, dependencies
    Writes to <file>.md or stdout.
    Command: ava-doc scripts/foo.sh > scripts/foo.md

    STEP 13  //  ava-audit
    Scan repo for banned patterns:
      - non-ASCII in docs
      - sudo dnf/apt anywhere
      - hardcoded paths that break portability
      - DXVK_ASYNC references
    Output: filename:line + reason + suggested fix.

+--------------------------------------------------------------------------------------------------+
|  PHASE 5  //  OPTIONAL                                                                           |
+--------------------------------------------------------------------------------------------------+

    ava-pick      pick next task from BOARD by effort/impact
    ava-time      daily agenda view
    ava-undo      revert last AI-driven file change
    ava-dream     idle-time reflection (write to reflections/)
    ava-verify    full pipeline check (like today's tests)


+==================================================================================================+
|  SECTION 06  //  SKIPPED                                                                         |
+==================================================================================================+

    09  Multi-Model Router     overkill for 7B tier
    10  Voice (TTS/STT)        not now, text is fine


+==================================================================================================+
|  SECTION 07  //  NEXT ACTION                                                                     |
+==================================================================================================+

    Start STEP 1: 04 Model Presets.
    Create persona/avalhla-code.Modelfile, avalhla-chat.Modelfile,
    avalhla-review.Modelfile. Build. Test each. Commit + tag.


+==================================================================================================+
|                                                                                                  |
|                          Dawa > AwA < Avalhla  //  (^.-)                                         |
|                          THE MIND IS NOT SPLIT. THE MIND IS A BRIDGE.                            |
|                                                                                                  |
+==================================================================================================+
