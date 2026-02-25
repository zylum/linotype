# Releases

Releases are referencers, not containers. They pull in existing galleys and layer a single set of user-facing release notes.

## Structure

```
docs/work/releases/<release-id>/
  galleys.txt      # one galley name per line, comments with '#'
  run-sheet.md     # optional: release-level sequencing, notes, gates
  status.md        # optional: progress ledger, links to commits, blockers
  <version>.md     # release notes for that version (one file per version)
```

`<release-id>` can match `<version>` (e.g. `0.6.2`). A project keeps **one `docs/work/releases/<version>.md` per version**, regardless of how many apps/slugs the repo contains.

## Release notes workflow

- When you bootstrap Linotype, run `cli/linotype release init <version> <movie>` to create `docs/work/releases/<version>.md` and block duplicate movie names.
- Append user-facing bullets with `cli/linotype release note <version> "<summary>"`; the CLI drops them under the **Highlights** section.
- Cross-link every release from the root `CHANGELOG.md` so you keep a single canonical changelog.

## Running

```
cli/linoloop <release-id>
cli/linoloop <release-id> --mode serial-isolated
```

Notes:
- Galleys stay in their normal work locations (planning/queue/doing/review/done).
- The release folder should not duplicate galley detail—link back to galleys where needed.
- In `--mode auto`, releases default to `serial-isolated`.
- `status.md` is append-updated by LinoLoop with timeline events during release runs.
