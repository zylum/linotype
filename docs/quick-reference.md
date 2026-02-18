# Quick Reference

## Bootstrap a new project

Use the Linotype skeleton: copy `linotype-skeleton/` into your repo (or run `cli/linotype-bootstrap.sh` from the skeleton). Ensure `docs/ai/_agent-rules.md` and root `AGENTS.md` are in place.

## Galley workflow (CLI)

Create and move galleys (not individual slugs). Use `cli/linotype` from repo root:

```bash
cli/linotype galley new <galley-name>              # e.g. 20260209-auth-passkeys
cli/linotype galley move <galley-name> <stage>     # planning | queue | doing | review | done
cli/linotype galley list
cli/linotype galley auto                           # auto-move when slugs ready
```

Optional: use a **queue** stage for handoff—move to `queue/` when ready; only move from `queue` to `doing` to claim (first move wins).

## File locations

Galleys under `docs/work/{planning,queue,doing,review,done}/`; slugs inside each galley. Domain index: `docs/domain/index.md`. Agent rules: `docs/ai/_agent-rules.md`; repo adapter: `AGENTS.md`.

## Focus and optimise

In `docs/ai/_agent-rules.md`: **focus** = loose | standard | strict (scope discipline). **optimise** = speed | cost | quality (optional; trade-off bias). Defaults: focus per repo; optimise balanced.

## Proof and commits

Per slug: update slug file with what changed, checks run, decisions. Commit: `slug:<slug-name> done - <summary> #galley:<galley-name>`. When galley complete: move to `review/`, then commit `galley:<galley-name> ready for review - <summary>`.

## Learning layer (v5)

Capture signals and context across apps:

```bash
cli/linotype signal add "description" [--app <app>] [--area <area>]
cli/linotype bundle snapshot [--app <app>] [--area <area>]
```

Files under `docs/learning/`:
- `inbox/` — raw reflections (any format)
- `signals/` — normalised signals: `YYYY-MM-DD__app__area__signals__daily.md`
- `snapshots/` — compiled context for agents

## LinoLoop (v6)

Run execution loops from generated executor briefs:

```bash
cli/linoloop <galley-name>
cli/linoloop <release-id>
cli/linoloop <release-id> --mode serial-isolated
cli/linoloop <release-id> --auto-pr
cli/linoloop <target> --dry-run
```

Release input file:
- `docs/work/releases/<release-id>/galleys.txt` (one galley per line, `#` comments allowed)

If no loop runner is installed, LinoLoop prints the executor brief so you can run manually.

For releases, status timeline is appended to `docs/work/releases/<release-id>/status.md`.

Modes:
- `auto` (default): galley -> direct, release -> serial-isolated
- `direct`: run in current working tree
- `serial-isolated`: one worktree/branch per galley (`galley/<galley-name>`)

## Parallel work and handoff

One branch per galley; one worktree per active galley. One active Executor per galley; conflicts -> record in galley `review.md`. Handoff: `cli/linotype exec brief <galley>` generates executor brief from galley run-sheet and (if configured) launches executor.
