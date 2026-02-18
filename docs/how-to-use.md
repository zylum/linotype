# How to use Linotype

## Workflow

Galleys (folders containing slugs) move through stages: planning → (queue) → doing → review → done. Use the CLI to create and move galleys; do not move folders manually.

## Commands

From repo root, use `cli/linotype` (or `./cli/linotype.sh`):

Create a galley:
```bash
cli/linotype galley new <galley-name>
```

Move a galley:
```bash
cli/linotype galley move <galley-name> planning|queue|doing|review|done
```

List galleys by stage:
```bash
cli/linotype galley list
```

Auto-move galleys when slugs are ready (e.g. all slugs done → review):
```bash
cli/linotype galley auto
```

Add slugs under the galley (e.g. `cli/linotype slug new <galley-name> <slug-name>` if your CLI supports it), then move the galley to `doing` when work starts, and to `review` when all slugs are complete.

## LinoLoop execution wrapper (v6.1)

LinoLoop wraps `cli/linotype exec opencode <galley>` and optionally runs a loop runner such as `ralph`.

Run one galley:

```bash
cli/linoloop <galley-name>
```

Run one galley in isolated worktree:

```bash
cli/linoloop <galley-name> --mode serial-isolated
```

Run a release (ordered galleys):

```bash
cli/linoloop <release-id>
```

In `--mode auto`, release runs default to `serial-isolated`.

Useful options:

```bash
cli/linoloop <target> --worktree-root ../.linotype-worktrees --reuse-worktree
cli/linoloop <target> --dry-run
cli/linoloop <release-id> --auto-pr
```

Release format:
- `docs/work/releases/<release-id>/galleys.txt`
- one galley name per line
- blank lines and `#` comments allowed

If no configured runner exists, LinoLoop prints the executor brief and exits for manual execution.

For release targets, LinoLoop appends timeline entries to:
- `docs/work/releases/<release-id>/status.md`

`--auto-pr` in v0.6.1 is a placeholder that records manual PR follow-up notes in that status file.

## Executor brief command

Canonical (tool-agnostic):

```bash
cli/linotype exec brief <galley-name>
```

Compatibility alias:

```bash
cli/linotype exec opencode <galley-name>
```

## Small fixes

For trivial changes (single file, low risk): implement directly and log in `docs/work/doing/small-fixes.md` (or equivalent). For traceability, create a slug inside a galley instead.

## Proof and commits

Per slug: record what changed, checks run, and decisions in the slug file. Commit: `slug:<slug-name> done - <summary> #galley:<galley-name>`. When the galley is complete: move to `review/`, then commit `galley:<galley-name> ready for review - <summary>`.

## Agent rules and repo adapter

Agents must follow `docs/ai/_agent-rules.md` (focus, optimise, roles, scope). Repo-specific behaviour (commands, conventions) is in root `AGENTS.md`; it adapts Linotype to this repository. See [v4](v4.md) and [quick-reference](quick-reference.md).
