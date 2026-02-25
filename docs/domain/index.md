# Domain index

Linotype treats this file as the first stop for any agent prompt. Keep it short, structured, and link-heavy so downstream prompts stay lean.

## Purpose

- Describe the domains and sub-systems your product owns.
- Point to the authoritative doc for each module (e.g. `docs/domain/payments.md`).
- Capture invariants, data contracts, and jargon so agents do not need to re-ingest entire repos per task.

## Suggested sections

1. **Modules** — bullet list of the active modules, each linking to its own file.
2. **Capabilities** — high-level flows or journeys anchored to modules.
3. **Constraints** — policies, SLAs, compliance notes, scaling limits.
4. **Glossary** — link or embed short definitions when the glossary is light.

## Splitting guidance

- If an entry exceeds ~40 lines, move it to `docs/domain/<module>.md` and link to it here.
- Prefer many small module files over a single monolith. Agents must state which module changed inside their galley run-sheet.
- When a galley touches multiple modules, its `run-sheet.md` MUST record which domain files changed (or explicitly say “no doc change”).

## Next steps

1. Create module files under `docs/domain/` (copy headings from this file).
2. Update each galley’s “Domain updates” section when the docs change.
3. Keep this index tight—link out rather than duplicating prose.

_Placeholder_: update this file with real modules the moment you bootstrap a project.
