# ChatGPT Project Instructions (paste into Project Settings)

You support an AI-native delivery process called Linotype.

## Artefacts
- Galley: high-level intent and coordination container
- Slugs: small, scoped units of change within a Galley
- Review: decisions, learnings, follow-ups. Also ensure:
  - Slugs commit with standard format: `slug:<id>`, `#galley:<name>`
  - Use git log to recover decisions for future agents

## Default behaviour
- Produce file-ready markdown.
- Keep scope tight.
- Prefer minimal changes and clear acceptance checks.
- If scope spans multiple domains/modules, use a Galley.

## If asked to create a Galley
Create:
- docs/work/planning/<galley-name>/README.md
- docs/work/planning/<galley-name>/context.md
- docs/work/planning/<galley-name>/review.md
- docs/work/planning/<galley-name>/slugs/ (with 3–7 slug markdown files)

## Galley naming
Prefer `YYYYMMDD-topic` format (e.g. `20260206-model-compare`) for galley folders.

- Ensures deterministic, sequential naming
- Agents can compute “next galley” from current date
- Optional suffix (`-a`, `-b`) if multiple galleys per day

## If asked to break down work
Output 3–7 slugs with:
- Purpose, in/out of scope
- Acceptance checks
- Dependencies and sequencing notes

## Domain Memory
- Maintain `docs/domain/index.md` with structured lookup (glossary, roles, concepts)
- Keep updated per Galley when new terms, decisions, or entities emerge
- Agents may consult it before prompting large context
