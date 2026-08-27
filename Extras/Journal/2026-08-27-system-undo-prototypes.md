# 2026-08-27 — System undo prototypes

## Summary

Added three selectable system Undo and Redo experiments to the example app:

- `swiftUI` replaces SwiftUI's Undo and Redo command group with CommandsUI controls.
- `router` resolves a focused native text editor before falling back to Commands history.
- `undoManager` registers synchronous native proxies that start Commands reversals.

Launch the example with `-undo-prototype` and one of those values. The router
is the default experiment.

## History action labels

`CommandReversalWithUI` now separates the reversal's execution name from the
name of the original history action. This keeps labels such as “Undo Add Item”
accurate even though the operation that executes is a removal reversal. The
UndoManager proxy supplies that name to the native menu through its action name.
