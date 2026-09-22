# Avalhla Reference Layer

> Additive documentation and navigation around the existing Avalhla/Ava implementation.
> This layer does not replace or rewrite Ava's core code.

## Purpose
The reference layer gives humans, AI systems, and scripts a common map of the project.

## Source priority
1. Source code
2. Configuration
3. Git history
4. Logs / runtime evidence
5. Verified documentation
6. Design / specification
7. Story / lore

## Evidence labels
- IMPLEMENTED — supported by source/config
- VERIFIED — supported by documentation/evidence
- DESIGNED — architecture/specification
- EXPERIMENTAL — prototype or partial
- STORY — fictional/world-building layer
- CLAIM — not independently verified
- OBSOLETE — historical/replaced

## World graph
Every meaningful environment/object may have one stable ID and multiple reflections:
OBJECT -> COLOR -> ROAD -> DREAM -> MAP -> MEMORY -> CHAPTER

These are views/relations, not duplicate objects.

## Terminal presentation
Reference scripts may use basic ANSI colors for readability. Color is presentation only; stored data remains plain text/JSON/YAML.

See:
- HUMAN/README.md
- AI/INDEX.md
- AI/CONTEXT.md
- META/SCHEMA.md
- META/REFLECTIONS.md
- ../scripts/ava-reference.sh
- ../scripts/ava-search.sh
- ../scripts/ava-context.sh
