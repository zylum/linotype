# Roles

## Agent roles (Linotype contract)

Defined in `docs/ai/_agent-rules.md`. Any agent (Cursor, Kiro, OpenCode, etc.) should follow these; repo-specific behaviour is in `AGENTS.md`.

### Orchestrator
- Shape and sequence work (create/refine galleys and slugs)
- Move galley lifecycle state (`cli/linotype galley move`)
- Keep scope explicit; apply small fixes and polish
- Review outcomes and record decisions

### Executor
- Execute slugs (docs/code changes)
- Run checks/tests where available
- Commit using required formats (slug done, galley ready for review)
- Record decisions and follow-ups in review artefacts

A galley has exactly one active Executor at a time. One person or tool may perform both roles.

## Human roles (ownership)

### Product Design Authority (PDA)
Owns system coherence. Frames change, creates galleys, breaks work into slugs, validates integration, keeps top-level docs aligned. In a galley: defines outcome, impacted modules, slugs, constraints, non-goals, sequencing.

### Module Architect
Owns a module’s correctness. Designs and builds within boundaries, validates locally, updates module docs, executes assigned slugs, respects galley scope. In a galley: executes slugs, updates specs, flags scope changes to PDA.

### Builder / Reviewer
Builder: executes build slugs (often same as Module Architect). Reviewer: verifies proof and coherence; slug-level (acceptance, proof, docs) and galley-level (all slugs done, intent realised, docs current). Solo use: PDA often does review.
