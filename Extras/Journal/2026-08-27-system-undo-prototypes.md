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

## Deferred command and UndoManager observations

The discussion of long-running commands identified a useful possible evolution
of the command lifecycle, but no implementation work is planned yet.

- A command could synchronously validate and either throw or return a common
  processing result: an immediate result or a deferred operation.
- The command centre would own a deferred operation's task, cancellation,
  progress reporting, and eventual success or failure. A successful deferred
  operation could then record its reversal in `UndoService` as “Undo Remove
  Duplicates”, for example.
- An immediate command may fail synchronously before it commits. Once it
  returns successfully, it must have completed atomically and have a valid
  reversal. This gives a native `UndoManager` proxy a reliable action title and
  ordering point.

The same constraints make the UndoManager-proxy experiment a poor general
solution. A deferred command cannot safely add an eventual native undo action
after unrelated native text editing without misrepresenting chronological
order. Registering a native action before completion can also discard native
redo state, which cannot be reconstructed if the command fails or is cancelled.
The router experiment remains the preferred direction: it leaves native text
editing history untouched and routes the single system Undo and Redo UI to the
active `UndoService` only when Commands owns the context.

## Router menu revalidation

The router now invalidates its SwiftUI command presentation when native text
editing focus or `UndoManager` state changes. It observes the platform text
editing, window-focus, and UndoManager checkpoint notifications, then resolves
the active owner's current action name for each menu title. This allows a
focused text editor to display “Undo Typing” rather than a fixed localization
key, while Commands history continues to supply its own named action when it
owns the route.
