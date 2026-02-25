# Changelog

## v0.6.3 (Casablanca)
- Added execution-phase discipline (Contract → Build → Verify) plus slug context-pack guidance to `docs/ai/_agent-rules.md` and the bootstrap skeleton
- Enforced evidence logging for every slug marked done; optional `#phase:<step>` commit suffix for clearer review trails
- Modularised `cli/linotype` into `cli/lib/linotype/` subcommands with new `release` helpers for per-version notes
- Introduced `docs/domain/index.md` scaffold and updated all guides (README, quick reference, structure, how-to) with release-note + domain requirements
- Bumped release metadata to `0.6.3` and added `docs/work/releases/0.6.3.md`

## v0.6.2 (Casablanca)
- Added single-file release notes per version (`docs/work/releases/<version>.md`) plus movie codename enforcement via `cli/linotype release ...`
- Introduced `docs/domain/index.md`, galley “Domain updates” sections, and CI lint to keep domain docs fresh
- Refactored `cli/linotype` into modular Bash files with new `release` subcommands and bats test coverage
- Restored GitHub Actions (shellcheck, bats, domain lint) so CLI and docs stay verified on every push

See `docs/work/releases/0.6.2.md` for the user-facing highlights.

## v0.6.1
- Added worktree-aware LinoLoop execution modes:
  - `--mode direct` (run in current working tree)
  - `--mode serial-isolated` (one worktree/branch per galley)
  - `--mode auto` (single galley: direct, release: serial-isolated)
- Added LinoLoop safety and control flags:
  - `--worktree-root`, `--reuse-worktree`, `--require-clean-git`, `--allow-dirty`, `--dry-run`, `--auto-pr`
- Added `cli/linotype exec brief <galley>` as canonical, tool-agnostic executor-brief command.
- Kept `cli/linotype exec opencode <galley>` as compatibility alias.
- Added release status timeline logging to `docs/work/releases/<release-id>/status.md`.
- Added `--auto-pr` placeholder behavior that records manual PR follow-up notes in release status.
- Synced root `cli/linoloop` and skeleton `linotype-skeleton/cli/linoloop` scripts.

## v0.6.0
- Added LinoLoop wrapper (`cli/linoloop`) for executing generated executor briefs.
- Added release execution support via `docs/work/releases/<release-id>/galleys.txt`.
- Added lock/log output under `dist/linoloop/`.
- Added manual fallback to print executor brief when loop runner is unavailable.

## v0.5.0
- Added portable learning layer under `docs/learning/`
  - `inbox/` for raw reflections
  - `signals/` for normalised signals with S-### IDs
  - `proposals/` for advisory clustering
  - `snapshots/` for compiled agent context
- New CLI commands: `signal add`, `signal normalise`, `bundle snapshot`
- File naming convention: `YYYY-MM-DD__app__area__type__slug.md`
- GitHub Actions templates (disabled by default) in `.github-disabled/workflows/`
- Migration helper script `cli/migrate-v04-to-v05.sh` with dry-run mode
- Updated agent rules with learning layer guidance
- Added ChatGPT project instructions template

## v0.4.0 (Preview)
- Introduced Galleys: PDA-owned planning artefacts for coordinating multi-module changes
- Galleys enable parallel execution while preserving intent and traceability
- Execution slugs now reference parent Galley (optional)
- Formalized PDA responsibilities: define outcome, identify modules, list slugs, decide sequencing
- Added Galley-level integration review (separate from slug-level review)
- Updated roles to clarify PDA and Module Owner responsibilities in Galleys
- Added Galley README template and examples

## v3.0.0
- Introduced explicit slug intent: Directional vs Build
- Clarified PDA vs Module Architect responsibilities
- Standardised review gate with Proof-backed completion
- Added comprehensive bootstrap script (`linotype-bootstrap.sh`)
- Enhanced `linotype.sh` with start/check/review/done commands
- Added `docs/context/app-context.md` for product snapshot
- Added `docs/capabilities/` structure for modules and registry
- Provided starter slugs (SLUG-001 and SLUG-002)
- Added Getting Started guide and Quick Reference
- Added structure documentation and expanded FAQ
- Optional Kiro/Cursor integration files

## v2.0.0
- Added `review/` stage to slug workflow
- Added Proof section to build notes and enforced before review
- Added trusted state transitions via `linotype.sh`

## v1.0.0
- Initial Linotype structure: docs, capabilities, slugs, templates
