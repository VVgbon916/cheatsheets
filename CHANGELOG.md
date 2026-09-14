# Changelog — VVgBazz & Avalhla

## V0.3 — Unreleased

### Removed
- Radio project entirely: `MASTER_RADIO_GUIDE.md`, `master_radio_builder.py`.
- `AVALHLA_AI_TRAINING_PROMPTS.md` — its entire 4-stage benchmark suite was
  built around the Master Radio schema/code; nothing left once that's gone.
  (Say the word if you want a fresh benchmark suite for a different project.)
- `VVgbazz_COMPLETEGUIDE.md` — was purely a list of dead
  `file:///home/VVgbon/.gemini/antigravity/brain/...` links (temp paths from
  a different AI tool's session) with no unique content.
- `EVERYDAY_ROUTINE.md` — was empty.
- `.directory` (KDE Dolphin metadata, was accidentally tracked).
- The old bashrc-function versions of `ai()`/`review()`/`research()`
  described in `AI_usefull.md`, `COMPLET_AI_GUIDE.md`, and
  `VVgBazz_Local_AI_CLI_Guide.md` — superseded by the real standalone
  scripts (`ai-with-memory`, `ai-learn`, `ai-remember`, `ai-progress`) that
  already exist and are more capable (persistent JSON logs, greeting/recall,
  HTTP-API fallback).

### Fixed (real bugs, not just style)
- `distrobox-export --app cava` fails ("cannot find any desktop files")
  because cava has no `.desktop` entry. This exact broken command appeared
  in `COMPLET_AI_GUIDE.md`, `DEPENDENCIES_APPS_NewUser_Guide.md`, and twice
  in `VVgBazz_Gaming_Handbook.md`. Fixed everywhere to
  `distrobox-export --bin /usr/bin/cava`.
- `java-17-openjdk-devel` / `java-21-openjdk-devel` do not resolve on
  Fedora 44 (confirmed via `dnf install` — `No match for argument`), yet
  were referenced in `COMPLET_SYS_GUIDE.md`, `COMPLET_AI_GUIDE.md`,
  `DEPENDENCIES_APPS_NewUser_Guide.md`, and `VVgBazz_Local_AI_CLI_Guide.md`.
  Replaced everywhere with the method already verified working in
  `DEVELOPER_LAB_SETUP.md`: `java-25-openjdk-devel` from dnf + Java 21 via
  the Temurin tarball to `/opt/java-21`.
- Dead `file:///home/VVgbon/.gemini/antigravity/brain/<uuid>/...` links
  (another AI tool's temp session paths) stripped from
  `COMPLET_AI_GUIDE.md`, `GITHUB_REPO_COLLAB_INTEGRATION.md`, and
  `VVgBazz_Gaming_Handbook.md`; replaced with relative repo links.
- `GITHUB_REPO_COLLAB_INTEGRATION.md` hardcoded a third, slightly different
  copy of the user profile inline via a heredoc — now references the one
  canonical `persona/user-profile.txt.example` instead.
- `avalhla_tools_check.sh` checked for the broken `java-17-openjdk-devel`
  package and referenced "Master Radio requirements" — both corrected.

### Changed
- Repo restructured into `/persona`, `/system`, `/ai`, `/dev`, `/gaming`,
  `/scripts` instead of a flat file list.
- Three overlapping AI guides (`COMPLET_AI_GUIDE.md`,
  `VVgBazz_Local_AI_CLI_Guide.md`, `AI_usefull.md`) merged into one
  `/ai/AI_GUIDE.md`.
- Three slightly different copies of the Avalhla Modelfile/persona
  consolidated into one `/persona/avalhla.Modelfile`.
- `COMPLET_SYS_GUIDE.md` → `/system/SYSTEM_GUIDE.md`, with its hardware
  table de-duplicated against `VVgBazz_System_Profile.md` → renamed
  `/system/SYSTEM_PROFILE.md` (kept as the detailed point-in-time audit).
- Four separate near-identical "create coding-lab and install dev tools"
  sections (in `COMPLET_SYS_GUIDE.md`, `COMPLET_AI_GUIDE.md`,
  `DEPENDENCIES_APPS_NewUser_Guide.md`, `VVgBazz_Local_AI_CLI_Guide.md`)
  consolidated into one `/dev/DEV_LAB_SETUP.md`.

### Added
- `.gitignore` — excludes `persona/user-profile.txt` (real hardware/identity
  data) and `~/.ai-memory/conversations/` / `~/.ai-memory/knowledge-base/`
  so personal data never gets committed to this public repo.
- This changelog.

## V0.2
- Prior flat-file layout (Bazzite DX NVIDIA 44 baseline, PipeWire 4-sink
  matrix, Distrobox `coding-lab`, Ollama `qwen2.5-coder`, radio builder
  project included).

## V0.1
- Initial cheatsheets dump.
