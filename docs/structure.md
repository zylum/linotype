# Linotype Structure

This document explains the folder structure and key artefacts.

## Core artefacts

### docs/domain/ or docs/context/
Product/domain snapshot (e.g. `docs/domain/index.md` or `docs/context/app-context.md`). Agents use it for lookup; keep it minimal. Optional: capability registry and module specs under `docs/capabilities/` or equivalent.

### docs/work/
Galley workflow stages: `planning/`, optional `queue/`, `doing/`, `review/`, `done/`. Each stage contains galley folders (e.g. `yyyymmdd-<name>/`). Inside a galley: `README.md`, optional `context.md`, `review.md`, and slugs (e.g. `slugs/*.md`). Move galleys with `cli/linotype galley move <galley-name> <stage>`.

### docs/learning/ (v5)
Learning layer for capturing signals, reflections, and context across the product lifecycle:
- `inbox/` — raw reflections dropped by humans/systems (any format)
- `signals/` — normalised signals with status tracking
- `proposals/` — clustered suggestions (advisory)
- `snapshots/` — compiled context for ChatGPT/agents
- `_templates/` — templates for consistent structure

File naming: `YYYY-MM-DD__app__area__type__slug.md`

CLI: `cli/linotype signal add`, `cli/linotype bundle snapshot`

### docs/ai/
Agent contract: `_agent-rules.md` (authoritative; focus, optimise, roles, scope). Repo root `AGENTS.md` adapts Linotype to the repo (min reading order, commands, conventions).

## Optional artefacts

### docs/overview.md
High-level navigation guide. Keep minimal; expand only when it adds clarity.

### docs/architecture.md
Thin, stable architectural overview. Avoid implementation detail.

### docs/glossary.md
Shared terms and definitions.

### docs/shared-standards.md
Conventions that apply across modules.

## Workflow automation

### cli/linotype (or cli/linotype.sh)
Galley-centric commands: `galley new`, `galley move <name> <stage>`, `galley list`, `galley auto`; optionally `slug new`. Stages: planning, (queue), doing, review, done. Use from repo root.

### Bootstrap
Skeleton provides `cli/linotype-bootstrap.sh`, `docs/ai/_agent-rules.md`, and root `AGENTS.md` template. Copy or run bootstrap to create work dirs, templates, and agent rules.

## Principles

1. **Reality-driven** - Docs reflect what exists, not what's planned
2. **Minimal by default** - Start thin, expand only when needed
3. **Coherence over time** - Structure preserves understanding as product evolves
4. **Delegable work** - Slugs have clear boundaries and can be handed off
5. **Coordinated change** - Galleys group related slugs without forcing hierarchy
