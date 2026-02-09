# Galleys

A Galley is a temporary grouping of slugs that together realise one product change. The galley folder moves through stages; slugs live inside it.

## What is a Galley?

- **Intent + decomposition**: README (brief), optional context/research; slugs do the work
- **Coordination point**: for parallel work and handoff (e.g. via queue)
- **Owned by PDA**; executed by Module Architect/Executor(s)

A Galley is not a unit of work (slugs are), not a replacement for module autonomy, and not required for every change—use one when multiple modules or slugs need to coordinate.

## When to use a Galley

Use when: multiple modules need to coordinate on one product change; you want to preserve “why” across slugs; you’re planning parallel work with sequencing. Skip for small single-slug changes or pure exploration (directional slug).

## Galley structure and naming

A Galley is a folder under `docs/work/{planning,queue,doing,review,done}/`. Naming: `yyyymmdd-<name>` or `yyyymmdd-<group>-<name>` (kebab-case). Example: `20260209-auth-passkeys`.

```
docs/work/planning/20260209-auth-passkeys/
├── README.md       (brief)
├── context.md      (optional)
├── review.md       (filled at review; learnings, decisions)
└── slugs/          (or per-repo layout)
    ├── auth-backend.md
    └── ui-login.md
```

## What goes in a Galley README

The README is the Galley brief. It answers:

### User outcome
What will users be able to do that they can't today?

### Impacted modules
Which modules will change? List each with one line of impact.

### Execution slugs
Explicit list of slugs (names and descriptions):
- slug-name: Description (primary module)

### Constraints
What must be true? What can't change?

### Non-goals
What are we explicitly NOT doing?

### Sequencing
Do any slugs depend on others? What's the order?

### Integration criteria
How do we know this Galley is complete?
- All slugs in done
- Integration tested
- Top-level docs updated
- PDA sign-off

Slugs live inside the galley folder (e.g. `slugs/*.md`), so the galley is implicit. For traceability, slug files can note the galley name in a header if needed.

## Galley lifecycle

Stages: `planning` | `queue` | `doing` | `review` | `done`. Move with CLI: `cli/linotype galley move <galley-name> <stage>`.

1. **Planning** — PDA creates galley (e.g. `cli/linotype galley new <name>`), README, slugs. No implementation yet.
2. **Queue** (optional) — Move to `queue/` when ready for handoff. Only move from queue to doing to **claim** (first successful move wins).
3. **Doing** — Move to `doing/` when work starts. One active Executor per galley; execute slugs, run checks, commit per slug.
4. **Review** — When all slugs are done, move to `review/`. Update galley README if needed; fill `review.md` (learnings, decisions).
5. **Done** — Move to `done/` when integration is verified and PDA (or reviewer) signs off.

Do not leave a finished galley in `doing/`.

## Queue and parallel workflow

- **Claiming**: Only move galleys from `queue` to `doing`. First successful move claims the galley. If move fails (no longer in queue), pick another galley.
- **Branch**: One branch per galley, e.g. `slug/<galley-id>-<galley-name>`.
- **Worktrees**: In parallel mode, one git worktree per active galley; each worktree checks out its galley branch.
- **Conflict avoidance**: One active galley per worktree; no two Executors on the same galley. If conflicts occur, stop and record in galley `review.md`.

## PDA and Module Owner (summary)

**PDA**: Define outcome, impacted modules, slugs, constraints, non-goals, sequencing. Validate integration when all slugs are done; update top-level docs; capture learnings.

**Module Owner / Executor**: Execute slugs, update module docs, provide proof, respect galley scope. Flag scope changes to PDA; record decisions in slug/review artefacts.

## Example: User authentication redesign

Galley `20260209-auth-passkeys`. README: user outcome (passkey login), impacted modules (auth, ui, api), slugs (e.g. auth-backend, ui-login, api-endpoints), constraints (backward compatibility, iOS/Android), non-goals (deprecate passwords later), sequencing (backend first; UI after API), integration criteria (all slugs done, E2E pass, app-context updated). See [examples/galley-example.md](examples/galley-example.md) for full README and slug samples.

## Galley vs directional slug

**Directional slug**: explore options, make a decision (single module); output is a decision. **Galley**: coordinate multiple modules; output is integrated product change. Example: directional = “Passkeys or WebAuthn?”; galley = “Implement passkey support across auth, ui, api.”

## Agents

Agents follow `docs/ai/_agent-rules.md` and repo `AGENTS.md`. Orchestrator shapes galleys/slugs and moves lifecycle; Executor runs slugs and commits. One active Executor per galley. Agents don’t invent galleys, change intent, or span multiple slugs at once. Slugs update module specs and decisions; galley captures learnings and updates app-context when user-facing behaviour changes.
