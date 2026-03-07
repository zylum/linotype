# Parallel workflow: worktrees and subagents

Linotype supports two patterns for parallel execution:

1. **Worktrees** — one git branch and working tree per galley (major features)
2. **Subagents** — one executor per domain within a galley (domain-isolated parallel dev)

## When to use what

| Pattern | Use when |
|--------|----------|
| **Simple build** | Single galley, small scope, one executor. No worktree. |
| **Worktree build** | Major feature, one galley, want isolated branch. Use `cli/linoloop <galley> --mode serial-isolated`. |
| **Worktree + subagent** | Galley spans 2+ domains; slugs separable by domain. Generate per-domain briefs, spawn subagents in parallel. |

## Worktrees (LinoLoop)

LinoLoop creates a worktree per galley so each major feature has its own branch and working directory.

```bash
# Single galley in isolated worktree
cli/linoloop 20260307-auth-passkeys --mode serial-isolated

# Release (multiple galleys, serial in worktrees)
cli/linoloop 2026-03-release --mode serial-isolated
```

- Branch name: `galley/<galley-name>`
- Worktree root: `dist/linoloop/worktrees/` (or `LINOLOOP_WORKTREE_ROOT`)
- When done: merge the worktree branch into main

## Subagents (per-domain execution)

For galleys that touch multiple domains (e.g. auth + payments), run subagents in parallel—one per domain.

### 1. Add domain to slugs

In the galley run-sheet, each slug declares its domain:

```markdown
## Order of work (slugs)
1. auth-backend - Implement passkey backend (domain: auth, autonomy: continuous)
2. auth-ui - Update login form (domain: auth, autonomy: continuous)
3. payments-api - Add billing endpoints (domain: payments, autonomy: continuous)
```

### 2. Generate per-domain briefs

```bash
cli/linotype exec brief <galley-name> --by-domain
```

This emits one brief per domain. Each brief includes:

- Galley name, branch, worktree path (if using worktrees)
- Slugs for that domain only
- Allowed paths (e.g. `src/auth/`, `docs/domain/auth.md`)
- Link to `docs/domain/<module>.md`
- Acceptance checks for those slugs

### 3. Spawn subagents

For each domain brief, launch a subagent (e.g. via Cursor `mcp_task` or OpenCode):

- **Prompt**: The domain brief + "Execute these slugs. Work only in allowed paths. Update Domain updates when done."
- **Scope**: Each subagent gets only its domain's paths. Cross-domain changes stay in the parent or become a separate galley.

### 4. Parent reconciles

When all subagents complete:

- Merge or reconcile branches if using worktrees
- Update galley `review.md` with learnings
- Move galley to review/done

## Safety

- **Path scoping**: Each subagent receives explicitly allowed paths. Do not expand scope mid-execution.
- **Cross-domain changes**: If a slug needs to touch 2+ domains, either (a) run it in the parent, or (b) split into domain-specific slugs.
- **Domain updates**: Each subagent must tick the Domain updates section for the files it changed.

## Combining worktrees and subagents

For a large release with multi-domain galleys:

1. Use worktrees for each galley (one branch per galley)
2. Within a galley, use subagents for domain-parallel slugs
3. Parent orchestrates: create worktrees, spawn subagents per domain, reconcile when done
