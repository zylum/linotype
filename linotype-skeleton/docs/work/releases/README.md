# Releases

Releases are referencers, not containers.

A release bundles multiple galleys into one ordered execution plan and review packet.

Structure:

docs/work/releases/<release-id>/
  galleys.txt      # one galley name per line, comments with '#'
  run-sheet.md     # optional: release-level sequencing, notes, gates
  status.md        # optional: progress ledger, links to commits, blockers

Running:
  cli/linoloop <release-id>
  cli/linoloop <release-id> --mode serial-isolated

Notes:
- Galleys stay in their normal work locations (planning/queue/doing/review/done).
- The release folder should not duplicate galley detail.
- In `--mode auto`, releases default to `serial-isolated`.
- `status.md` is append-updated by LinoLoop with timeline events during release runs.
