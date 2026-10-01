# 2026-10-01 — Failed command hook naming

Renamed `CommandCentre.recordCommandFailure` to `recordFailedCommand` to match
`recordStartedCommand` and `recordFinishedCommand`. Updated the default hook,
fire-and-forget dispatch, and the test centre on `feature/bookish-integration`.
The existing failure-reporting test verifies dispatch to the renamed override.

Validation: `agt format` and `agt validate --fast` passed, covering the Commands
build and both CommandsTests and CommandsUITests. `git diff --check` passed.
Full platform validation was not run for this naming change.

Bookish must rename its `BookishEngine` override when adopting this revision.
