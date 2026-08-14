# 2026-08-13 — Command and UI maintenance

## Summary

Reviewed and modernised the Commands package, its SwiftUI command controls,
documentation, and tests.

## Completed work

- Updated code comments, formatting, public API documentation, and the README.
- Added UI-capable command-reversal metadata through `CommandReversalWithUI` and
  `CommandReversalAdapterWithUI`.
- Moved `UndoCommandButton` to its own source file and made it follow the
  pending inverse's availability and optional command presentation.
- Reduced repetition in CommandsUI controls with shared label and presentation
  helpers while keeping availability evaluation dynamic during `body` updates.
- Made `UndoService.performUndo()` asynchronous and added cursor-based undo/redo
  history. A history action returns its replacement reversal, which lets the
  service move repeatedly between undo and redo states.
- Added `UndoService.performRedo()`, `hasRedo`, `nextRedo`, `isUndoing`, and
  `isRedoing`.
- Added `RedoCommandButton`, `redoButton()`, and localized Redo labels.
- Updated unit tests for the current command API and added coverage for undo/redo
  traversal, redo-branch truncation, failure preservation, and concurrent
  history-operation rejection.
- Defined the package concurrency model in `Extras/Documentation/Concurrency.md`.
  Command coordination remains main-actor isolated; CPU-heavy work belongs in
  injected concurrent services. Undoable centres now block forward commands
  while an undo or redo action is suspended, preventing re-entrant history
  corruption. `CommandCentre` uses a generic `CommandExecutionContext`, leaving
  undo/redo semantics in `UndoableCommandCentre`. The undo service tracks active
  forward commands and supplies the context for its active undo or redo action.
- Simplified the command API by removing invocation-source parameters. History
  coordination now lives entirely within `UndoService` and
  `UndoableCommandCentre`.

## Validation

- `rt validate --target Commands` passed.
- `rt validate --target CommandsUI` passed.
- `rt validate` passed after the command and UI changes.

## Follow-up context

The working tree contains the completed changes from this session and has not
been committed yet.
