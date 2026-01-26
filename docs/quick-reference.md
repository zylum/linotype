# Quick Reference

## Bootstrap a new project

```bash
curl -fsSL https://raw.githubusercontent.com/zylum/linotype/main/linotype-bootstrap.sh | bash
./linotype.sh init
```

## Workflow commands

Initialize structure:
```bash
./linotype.sh init
```

Start a slug (planning → doing):
```bash
./linotype.sh start SLUG-002.first-vertical-slice
```

Check if ready for review:
```bash
./linotype.sh check SLUG-002.first-vertical-slice
```

Move to review (doing → review):
```bash
./linotype.sh review SLUG-002.first-vertical-slice
```

Complete a slug (review → done):
```bash
./linotype.sh done SLUG-002.first-vertical-slice
```

## File locations

Slug plans: `docs/work/planning/SLUG-XXX.name.md`
Active work: `docs/work/doing/SLUG-XXX.name.md`
Build notes: `docs/work/doing/SLUG-XXX.name.build-notes.md`
Under review: `docs/work/review/`
Completed: `docs/work/done/`

## Key artefacts

Product snapshot: `docs/context/app-context.md`
Capability registry: `docs/capabilities/registry.yml`
Module specs: `docs/capabilities/modules/{module}/spec.md`
Small fixes log: `docs/work/doing/small-fixes.md`

## Proof requirements

Before moving to review, build notes must include at least one:
- URL: (preview link)
- Screenshot: (path to image)
- Commit / diff: (git reference)
- Test output: (test results)

## Starter slugs

After bootstrap, complete exactly one:
- `SLUG-001.bootstrap-linotype.md` (new product)
- `SLUG-001.index-linotype.md` (existing product)

Then do:
- `SLUG-002.first-vertical-slice.md`
