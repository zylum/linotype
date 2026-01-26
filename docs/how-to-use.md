# How to use Linotype

## Workflow
Slugs move through stages:
planning → doing → review → done

Use `./linotype.sh` to move slugs between stages. Do not move files manually.

## Commands

Initialize the structure:
```bash
./linotype.sh init
```

Start working on a slug (moves from planning to doing):
```bash
./linotype.sh start SLUG-002.first-vertical-slice
```

Check if a slug is ready for review:
```bash
./linotype.sh check SLUG-002.first-vertical-slice
```

Move to review (requires proof in build notes):
```bash
./linotype.sh review SLUG-002.first-vertical-slice
```

Complete a slug (moves from review to done):
```bash
./linotype.sh done SLUG-002.first-vertical-slice
```

## Small fixes
For trivial changes (single file, low risk):
- implement directly
- log in `docs/work/doing/small-fixes.md`

If you want traceability, create a slug instead.

## Proof requirement
Before a slug can move to review, build notes must include proof with at least one filled item:
- URL: (preview link)
- Screenshot: (path to image)
- Commit / diff: (git reference)
- Test output: (test results)

The script will enforce this requirement.
