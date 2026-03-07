# Run Sheet (single source of truth for execution)

Galley: <galley-name>
Scope: <domains or paths>
Base: <branch or main>

## Execution mode
- Default autonomy: continuous
- Stop only when:
  - blocked by ambiguity that changes behaviour
  - checks fail and cannot be fixed safely
  - a decision marked as gated is reached

## Order of work (slugs)

Add `domain:` so slugs can be grouped for parallel subagent execution (see `exec brief --by-domain`).

1. <slug-id> - <purpose> (domain: <module>, autonomy: continuous | checkpoint | gated)
   - Touch: <key files>
   - Acceptance checks: <commands or checks>
   - Stop conditions (if any): <one line>

2. <slug-id> - <purpose> (domain: <module>, ...)

## Domain updates

- [ ] <module>.md (or: N/A - no behaviour change)

## Constraints
- Allowed paths: <list>
- No opportunistic refactors outside scope
- Commit format:
  - slug: `slug:<slug> done - <summary> #galley:<galley>`
  - galley: `galley:<galley> ready for review - <summary>`
