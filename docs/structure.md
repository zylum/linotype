# Linotype Structure

This document explains the folder structure and key artefacts.

## Core artefacts

### docs/context/app-context.md
High-level product snapshot. Answers:
- What is this product?
- Who uses it?
- What are the key journeys?
- What domains/modules exist?
- What constraints apply?

Keep this thin and readable in under 5 minutes.

### docs/capabilities/registry.yml
Central registry of capabilities. Maps what the product can do to which modules own them.

### docs/capabilities/modules/
One folder per module. Each contains:
- `spec.md` - Purpose, boundaries, data ownership, key flows
- `features.md` - Feature status table
- `decisions.md` - Log of boundary/contract changes

### docs/work/
Slug workflow stages:
- `planning/` - Slugs waiting to start
- `doing/` - Active work
- `review/` - Awaiting validation
- `done/` - Completed slugs

Each slug has:
- `SLUG-XXX.name.md` - The plan
- `SLUG-XXX.name.build-notes.md` - Implementation notes (created when started)

### docs/templates/
Templates for creating new slugs and build notes.

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

### linotype.sh
Script for moving slugs through stages:
- `init` - Create folder structure
- `start <slug>` - Move from planning to doing, create build notes
- `check <slug>` - Verify slug is ready for review
- `review <slug>` - Move to review (requires proof)
- `done <slug>` - Complete the slug

## Bootstrap files

### linotype-bootstrap.sh
Downloads and sets up Linotype structure in a new project. Creates:
- All core documentation files
- Starter slugs (SLUG-001 and SLUG-002)
- Templates
- Workflow script
- Optional Kiro/Cursor integration files

## Principles

1. **Reality-driven** - Docs reflect what exists, not what's planned
2. **Minimal by default** - Start thin, expand only when needed
3. **Coherence over time** - Structure preserves understanding as product evolves
4. **Delegable work** - Slugs have clear boundaries and can be handed off
