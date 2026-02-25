# AGENTS (repository adapter for Linotype)

This repository uses Linotype.

- Authoritative operating contract: `docs/ai/_agent-rules.md`
- This file adapts Linotype to this specific repo (commands, checks, conventions).
- If this file conflicts with `_agent-rules.md`, `_agent-rules.md` wins.

## Minimum reading order
1. `docs/ai/_agent-rules.md`
2. `docs/domain/index.md` (lookup only)
3. Active galley README, slugs, and `run-sheet.md` (if present)

## Execution handoff (UI-free)
Preferred: `cli/linotype exec brief <galley>`

Compatibility alias: `cli/linotype exec opencode <galley>`

This generates an executor brief from the galley `run-sheet.md` and slugs, then launches the executor tool (or prints the brief to stdout if no launcher is configured).

## Tool mapping (examples only)
- Orchestrator: editor or planning tool of choice
- Executor: any execution tool that follows `_agent-rules.md`

## Cursor / Copilot rules
- Agents working here must keep `docs/ai/_agent-rules.md` in mind; it is the authoritative operating handbook for Claude/Cursor/Kiro.
- **Domain memory:** Before using large context or external tools, look up terms in `docs/domain/index.md`. Use it to cut token bloat and stay grounded.
- The `.cursor/.rules.md` file reiterates the same constraint and explicitly adds: when you need to create or move a galley or slug, run `cli/linotype` so the tooling stays in sync.
- No `.github/copilot-instructions.md` file exists at the moment; if one appears later, treat it as additional guidance (but confirm it is safe before acting on it).

## Execution expectations
- When you pick up a galley, plan to finish it end-to-end (all slugs, docs, move to the requested stage) before checking back. Only pause for gated decisions or true blockers.
- Update the galley run sheet’s **Domain updates** section as you go—note which `docs/domain/<module>.md` files changed or explicitly record “no doc update (reason)”.

## Release notes & movie naming
- Each major release must claim an unused iconic movie codename (v0.6 = “Casablanca”).
- Track user-facing changes in `docs/work/releases/<version>.md`. Use `cli/linotype release init` / `release note` to scaffold/update the file so every repo keeps a single changelog.
