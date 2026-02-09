# Run Sheet (single source of truth for execution)

Galley: {{GALLEY_NAME}}
Scope: <domains or paths>
Base: <branch or main>

## Execution mode
- Default autonomy: continuous
- Stop only when:
  - blocked by ambiguity that changes behaviour
  - checks fail and cannot be fixed safely
  - a decision marked as gated is reached

## Order of work (slugs)
1. <slug-id> - <purpose> (autonomy: continuous | checkpoint | gated)
   - Touch: <key files>
   - Acceptance checks: <commands or checks>
   - Stop conditions (if any): <one line>

2. <slug-id> - <purpose> (...)

## Constraints
- Allowed paths: <list>
- No opportunistic refactors outside scope
- Commit format:
  - slug: `slug:<slug> done - <summary> #galley:{{GALLEY_NAME}}`
  - galley: `galley:{{GALLEY_NAME}} ready for review - <summary>`
