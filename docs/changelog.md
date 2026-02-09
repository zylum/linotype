# Changelog

Summary of versions. Full history: [CHANGELOG.md](https://github.com/zylum/linotype/blob/main/CHANGELOG.md) in the repo root.

## v4 (current)

- **Focus & optimise** — Repos set `focus` (loose / standard / strict) and optional `optimise` (speed / cost / quality) in `docs/ai/_agent-rules.md`.
- **Parallel workflow** — Optional queue stage; one branch per galley; worktrees; one Executor per galley; conflict handling in `review.md`.
- **Agent contract** — `_agent-rules.md` (authoritative) and repo-root `AGENTS.md` (adapter). Orchestrator vs Executor roles.
- **Galley lifecycle** — planning → queue → doing → review → done; CLI `galley move`.

See [v4](v4.html) for details.

## v3

- Explicit slug types: Directional vs Build.
- Roles: PDA, Module Architect, Builder, Reviewer.
- Proof required before review; workflow script (start / check / review / done).
- Bootstrap script, app-context, capabilities structure, starter slugs.

See [v3](v3.html) for details.

## Earlier

- v2: Review stage, proof in build notes, script-driven transitions.
- v1: Initial structure (docs, capabilities, slugs, templates).
