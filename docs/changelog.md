# Changelog

Summary of versions. Full history: [CHANGELOG.md](https://github.com/zylum/linotype/blob/main/CHANGELOG.md) in the repo root.

## v6.1 (current)

- **Worktree-aware LinoLoop** - Added `--mode` options with isolated execution support (`serial-isolated`) and `auto` defaults.
- **Safety controls** - Added `--require-clean-git` (default), `--allow-dirty`, `--reuse-worktree`, and `--dry-run`.
- **Tool-agnostic brief command** - `cli/linotype exec brief <galley>` is now canonical; `exec opencode` remains an alias.

See [v6](v6.html) for v6 baseline details.

## v6

- **LinoLoop wrapper** - New `cli/linoloop` command runs executor briefs in a loop runner (default `ralph`) with lock/log support.
- **Release execution** - `cli/linoloop <release-id>` reads ordered galleys from `docs/work/releases/<release-id>/galleys.txt`.
- **Manual fallback** - If no loop runner is installed, LinoLoop prints the executor brief for manual paste into OpenCode.

See [v6](v6.html) for details.

## v5

- **Learning layer** - Added `docs/learning/` (inbox, signals, proposals, snapshots).
- **Signals and snapshots** - Added lightweight helpers: `signal add`, `signal normalise`, `bundle snapshot`.

See [v5](v5.html) for details.

## v4

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
