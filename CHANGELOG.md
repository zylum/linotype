# Changelog

## v0.4.0 (Preview)
- Introduced Galleys: PDA-owned planning artefacts for coordinating multi-module changes
- Galleys enable parallel execution while preserving intent and traceability
- Execution slugs now reference parent Galley (optional)
- Formalized PDA responsibilities: define outcome, identify modules, list slugs, decide sequencing
- Added Galley-level integration review (separate from slug-level review)
- Updated roles to clarify PDA and Module Owner responsibilities in Galleys
- Added Galley README template and examples

## v3.0.0
- Introduced explicit slug intent: Directional vs Build
- Clarified PDA vs Module Architect responsibilities
- Standardised review gate with Proof-backed completion
- Added comprehensive bootstrap script (`linotype-bootstrap.sh`)
- Enhanced `linotype.sh` with start/check/review/done commands
- Added `docs/context/app-context.md` for product snapshot
- Added `docs/capabilities/` structure for modules and registry
- Provided starter slugs (SLUG-001 and SLUG-002)
- Added Getting Started guide and Quick Reference
- Added structure documentation and expanded FAQ
- Optional Kiro/Cursor integration files

## v2.0.0
- Added `review/` stage to slug workflow
- Added Proof section to build notes and enforced before review
- Added trusted state transitions via `linotype.sh`

## v1.0.0
- Initial Linotype structure: docs, capabilities, slugs, templates
