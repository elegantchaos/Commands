# Migrating to 3.0

Commands 3.0 renames several types and members, replaces the reversal API of undo history, and adds undo through Foundation's `UndoManager`. This guide lists what an app using 2.5 needs to change. The toolchain and dependency requirements are unchanged: Swift 6.4 and Logger 3.

## Names

| 2.5 | 3.0 |
| --- | --- |
| `Command.ResultType` | `Command.Output` |
| `CommandsHost(commander:)` | `CommandsHost(centre:)` |
| `InheritedCommander` | `InheritedCentre` |
| `CommandButton(command:commander:)` | `CommandButton(command:centre:)` |
| `UndoableCommandCentre` | `CommandCentreWithHistory` |
| `undoService` | `historyService` |
| `UndoService` | `HistoryService` |
| `UndoServiceError` | `HistoryServiceError` |
| `UndoCommandButton(undoService:)` | `HistoryUndoButton(historyService:)` |
| `RedoCommandButton(undoService:)` | `HistoryRedoButton(historyService:)` |
| `undoButton()`, `redoButton()` | `historyUndoButton()`, `historyRedoButton()` |
| `confirmableButton(_:)` | `button(_:)` |
| `confirmableToolbarItem(_:)` | `toolbarItem(_:)` |

The generic parameters that name a command centre are called `Centre` throughout CommandsUI, which matters only where code spells out those types.

`confirmableButton(_:)` and `confirmableToolbarItem(_:)` already behaved like `button(_:)` and `toolbarItem(_:)`: a command asks for confirmation by returning one from `confirmation(centre:)`, whichever control shows it.

## Undo history

Commands no longer return type-erased reversals. A command that can be undone adopts `CommandWithHistory` and returns the command that reverses it:

```swift
// 2.5
func reversal(centre: C) -> (any CommandReversal)? {
  CommandReversalAdapter(command: RestoreSessionCommand(), centre: centre)
}

// 3.0
extension SignOutCommand: CommandWithHistory where C: CommandCentreWithHistory {
  func reversal(centre: C) -> RestoreSessionCommand<C>? {
    RestoreSessionCommand()
  }
}
```

- `Command.reversal(centre:)`, `CommandReversal`, `CommandReversalAdapter`, `CommandReversalWithUI` and `CommandReversalAdapterWithUI` are gone. Commands that change nothing reversible need no changes.
- When a command and its reversal name each other, declare `Centre` and `Output` explicitly on one of them; Swift cannot infer their associated types.
- `HistoryService.nextUndo` and `nextRedo` are `HistoryEntry` values. An entry's `action` is the command that made the step, which undo and redo controls show, such as "Undo Increment".
- `recordUndo(_:)` is now `recordUndo(_:of:centre:)`, taking the reversal, the action that names the step, and its centre. It throws `HistoryServiceError.historyOperationInProgress` while an undo or redo is in progress.
- `CommandCentreWithHistory` is class-only. History entries hold their centre weakly, so a centre's history no longer keeps it alive; an entry whose centre has gone is disabled.

## Execution

- A centre's `perform` now refuses a command that `isRunning` reports as running, throwing `CommandError.commandUnavailable`, as `availability(_:)` already reported.

## Undo through UndoManager

3.0 adds a second way to undo: `CommandWithUndo` and `CommandCentreWithUndo` register each synchronous command's inverse with an `UndoManager`, sharing the system undo stack and Edit menu. See the [Commands README](../../Sources/Commands/README.md#undo-support) for when to use it and how. Commands hold their undo manager in a `weak var`.
