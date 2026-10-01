# 2026-09-01 — Fire-and-forget failure reporting

## Summary

`performWithoutWaiting(_:)` discards its error: it starts an unstructured task,
and callers may drop the task handle. It only logged failures, so an
application with a user-facing error surface (Bookish's status bar) could not
show them.

## Completed work

- Added a `CommandCentre` hook, `recordCommandFailure(_:error:)`, which
  `performWithoutWaiting(_:)` calls when the command throws.
- The default implementation logs, so centres with no error surface behave as
  before.
- Added a regression test that a thrown fire-and-forget command reaches the
  hook.

## Later changes

- 2026-10-01: reconciled with the undo-aware `perform` and
  `recordFinishedCommand(_:outcome:)` when this work moved onto `main`. The
  hook stays separate from the completion outcome: the outcome records how a
  command ended for undo history, and the failure hook decides what the user
  sees.
- 2026-10-01: renamed to `recordFailedCommand(_:error:)`; see
  [Failed command hook naming](2026-10-01-failed-command-hook.md).

## Notes

Bookish adopted the hook first, to route failures to its status bar. Its
override has to track the name: the protocol supplies a default, so a stale
override compiles but is never called.
