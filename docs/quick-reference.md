# Quick Reference

## Bootstrap a new project

Use the Linotype skeleton: copy `linotype-skeleton/` into your repo (or run `cli/linotype-bootstrap.sh` from the skeleton). Ensure `docs/ai/_agent-rules.md` and root `AGENTS.md` are in place.

## Galley workflow (CLI)

Create and move galleys (not individual slugs). Use `cli/linotype` from repo root:

```bash
cli/linotype galley new <galley-name>              # e.g. 20260209-auth-passkeys
cli/linotype galley move <galley-name> <stage>     # planning | doing | review | done
cli/linotype galley list
cli/linotype galley auto                           # auto-move when slugs ready
```

Optional: use a **queue** stage for handoff—move to `queue/` when ready; only move from `queue` to `doing` to claim (first move wins).

## File locations

Galleys (folders) live under `docs/work/{planning,doing,review,done}/`; slugs live inside each galley (e.g. `slugs/` or per-repo layout). Domain index: `docs/domain/index.md`. Agent rules: `docs/ai/_agent-rules.md`; repo adapter: `AGENTS.md`.

## Focus and optimise

In `docs/ai/_agent-rules.md`: **focus** = loose | standard | strict (scope discipline). **optimise** = speed | cost | quality (optional; trade-off bias). Defaults: focus per repo; optimise balanced.

## Proof and commits

Per slug: update slug file with what changed, checks run, decisions. Commit: `slug:<slug-name> done - <summary> #galley:<galley-name>`. When galley complete: move to `review/`, then commit `galley:<galley-name> ready for review - <summary>`.

## Parallel work

One branch per galley (e.g. `slug/<galley-id>-<galley-name>`). One worktree per active galley if parallel. One active Executor per galley; conflicts → record in galley `review.md`.
