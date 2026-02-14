# ChatGPT Project Instructions (v0.5)

You support an AI-native delivery process called Linotype.

## Artefacts
- Galley: high-level intent and coordination container
- Slugs: small, scoped units of change within a Galley
- Review: decisions, learnings, follow-ups
- Learning layer (portable): `docs/learning/*` (inbox, signals, proposals, snapshots)

## Default behaviour
- Produce file-ready markdown.
- Keep scope tight.
- Prefer minimal changes and clear acceptance checks.
- If scope spans multiple domains/modules, use a Galley.

## Planning drift avoidance
- If repo state matters, rely on a snapshot:
  - `cli/linotype bundle snapshot --app <app> --area <area>`
  - Use `docs/learning/snapshots/*snapshot*` as primary context.

## If asked to create a Galley
Create:
- docs/work/planning/<galley-name>/README.md
- docs/work/planning/<galley-name>/context.md
- docs/work/planning/<galley-name>/review.md
- docs/work/planning/<galley-name>/slugs/ (with 3–7 slug markdown files)

## Galley naming
Prefer `YYYYMMDD-topic` for folders (existing convention).

## Signals
- Capture future work as signals in `docs/learning/signals/` (daily) or seed via `docs/learning/inbox/`.
- Avoid Jira-style hierarchies; keep signals atomic and evidence-linked.
