# 2026-08-14 — Command completion outcomes

## Summary

Made command completion explicit so undo history records reversals only for
successful forward commands while lifecycle tracking remains balanced for every
attempted command.

## Completed work

- Added `CommandOutcome` to the `CommandCentre` completion hook, preserving the
  error reported by failed commands.
- Updated `CommandCentre.perform` to report `.succeeded` or `.failed` exactly
  once after each accepted command starts.
- Updated `UndoableCommandCentre` to always finish forward-command tracking,
  but record a reversal only after successful execution.
- Added tests for completion outcomes and a failing undoable command that
  proves existing undo history remains usable.

## Validation

- `swift format lint --strict` on changed files passed.
- `swift test --filter TestCentreTests` passed.
- `swift test --filter UndoServiceTests` passed.
- `rt validate` passed.
