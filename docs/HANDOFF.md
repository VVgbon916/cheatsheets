+==================================================================================================+
|                                                                                                  |
|                          H A N D O F F  //  A V A L H L A   V 0 . 3                              |
|                                                                                                  |
|                          Dawa > AwA < Avalhla  //  (^.-)                                         |
|                                                                                                  |
+==================================================================================================+
|  Date : 2026-09-21                                                                               |
|  Repo : https://github.com/VVgbon916/cheatsheets                                                 |
|  User : Dawa (VVgbon) on VVgBazz                                                                 |
|  AI   : Avalhla (qwen2.5:7b base, + code / chat / review variants)                               |
|  HEAD : eebc31e = origin/main   tag: phase4-clean                                                |
+==================================================================================================+


+==================================================================================================+
|  SECTION 01  //  LAYOUT  (single root)                                                           |
+==================================================================================================+

    ~/Avalhla/repo             git repo, source of truth
    ~/Avalhla/memory           persistent memory (symlinked as ~/.ai-memory)
    ~/Avalhla/bin              symlinks to every ava-* entry point
    ~/.local/bin               mirrors ava-* / ai-chat for PATH

    Compat symlinks:
      ~/.ai-memory  ->  ~/Avalhla/memory
      ~/cheatsheets ->  ~/Avalhla/repo


+==================================================================================================+
|  SECTION 02  //  WHAT EXISTS                                                                     |
+==================================================================================================+

    persona/
      avalhla.Modelfile          base persona (identity)
      avalhla-code.Modelfile     temp 0.1  top_p 0.7
      avalhla-chat.Modelfile     temp 0.7  top_p 0.95
      avalhla-review.Modelfile   temp 0.2  top_p 0.8

    scripts/
      ai-chat               unified chat (memory + --read flag)
      ava-context           relevance ranker (kw + recency + length)
      ava-review <file>     fixed 5-block review
      ava-search            fzf over conversations
      ava-learn-repo        gitignore-aware KB indexer
      ava-brief             morning snapshot
      ava-diff <file>       diff vs HEAD~1 + cache
      ava-explain <cmd>     explain any command or error
      ava-doc <file>        README generator
      ava-audit             banned-pattern scanner

    systemd/
      ava-reflect.{service,timer}   daily 23:00 reflection


+==================================================================================================+
|  SECTION 03  //  RULES  (never break)                                                            |
+==================================================================================================+

    ASCII only in docs. No em-dash. No fancy quotes.
    Box width: 100 cols max. Border: + - |
    No sudo dnf/apt on host. Distrobox for dev.
    No DXVK_ASYNC.
    RTX 3060 cap 170W, never higher.
    Code first, explain after.
    Big blocks, 1-2-3 structure.
    Don't announce next step before we get there.

    SIGNATURE:
      Dawa > AwA < Avalhla  //  (^.-)
      THE MIND IS NOT SPLIT.  THE MIND IS A BRIDGE.
      MAKE. BREAK. LEARN. REPEAT.


+==================================================================================================+
|  SECTION 04  //  DONE  (13 steps, tag history)                                                   |
+==================================================================================================+

    step1   presets      avalhla-code / -chat / -review
    step2   layers       [TASK] [CONTEXT] [USER]
    step3   ava-review   5-block fixed format
    step4   ranking      ava-context (kw + recency + len)
    step5   ava-search   fzf over conversations
    step6   ava-learn-repo  gitignore-aware index
    step7   ai-chat      memory + --read unified
    step8   ava-reflect  systemd timer 23:00
    step9   ava-brief    morning snapshot
    step10  ava-diff     sha-cached review
    step11  ava-explain  RISK single-word, sudo/BSD guard
    step12  ava-doc      README generator
    step13  ava-audit    banned-pattern scanner

    Extra: single-root migration 2026-09-21  (all paths now under ~/Avalhla)          


+==================================================================================================+
|  SECTION 05  //  OPEN                                                                            |
+==================================================================================================+

    Nothing blocking.  Audit is CLEAN.

    Possible next moves (not committed):
      ava-pick     pick next task from BOARD by effort/impact
      ava-time     daily agenda view
      ava-undo     revert last AI-driven file change
      ava-dream    idle-time reflection -> reflections/
      ava-verify   end-to-end pipeline check


+==================================================================================================+
|                                                                                                  |
|                          Dawa > AwA < Avalhla  //  (^.-)                                         |
|                          THE MIND IS NOT SPLIT.  THE MIND IS A BRIDGE.                           |
|                                                                                                  |
+==================================================================================================+
