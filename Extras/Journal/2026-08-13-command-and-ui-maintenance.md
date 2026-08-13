# 2026-08-13 — Command and UI maintenance

## Summary

Reviewed and modernised the Commands package, its SwiftUI command controls,
documentation, and tests.

## Completed work

- Updated code comments, formatting, public API documentation, and the README.
- Added UI-capable inverse-command metadata through `CommandInverseWithUI` and
  `CommandInverseProxyWithUI`.
- Moved `UndoCommandButton` to its own source file and made it follow the
  pending inverse's availability and optional command presentation.
- Reduced repetition in CommandsUI controls with shared label and presentation
  helpers while keeping availability evaluation dynamic during `body` updates.
- Made `UndoService.performUndo()` asynchronous and added cursor-based undo/redo
  history. A history action returns its replacement inverse, which lets the
  service move repeatedly between undo and redo states.
- Added `CommandSource.redo`, `UndoService.performRedo()`, `hasRedo`,
  `nextRedo`, and the single `UndoService.Operation?` state. `isUndoing` and
  `isRedoing` are derived convenience properties.
- Added `RedoCommandButton`, `redoButton()`, and localized Redo labels.
- Updated unit tests for the current command API and added coverage for undo/redo
  traversal, redo-branch truncation, failure preservation, and concurrent
  history-operation rejection.
- Defined the package concurrency model in `Extras/Documentation/Concurrency.md`.
  Command coordination remains main-actor isolated; CPU-heavy work belongs in
  injected concurrent services. Undoable centres now block forward commands
  while an undo or redo action is suspended, preventing re-entrant history
  corruption. `CommandCentre.isAllowed(from:)` delegates source-specific policy
  to the concrete centre, leaving undo/redo semantics in
  `UndoableCommandCentre`.

## Validation

- `rt validate --target Commands` passed.
- `rt validate --target CommandsUI` passed.
- `rt validate` passed after the command and UI changes.

## Follow-up context

The working tree contains the completed changes from this session and has not
been committed yet.
