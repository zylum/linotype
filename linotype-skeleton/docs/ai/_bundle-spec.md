# Bundle spec

## linotype bundle ai <galley>
Output: dist/bundles/<galley>-ai/<flattened-files>

Includes (flattened):
- docs/architecture.md
- docs/overview.md
- docs/glossary.md
- docs/work/planning/<galley>/README.md    -> <galley>-README.md
- docs/work/planning/<galley>/context.md   -> <galley>-context.md

## linotype bundle review [--since ...]
Output:
- dist/bundles/review/<period>/
  - <galley>-review-learnings.md (extracted sections only)

Extract only:
- ## Learnings
- ## Reflection
- ## Surprises
- ## Follow-ups
