# Commands

`Commands` is the core, UI-independent command framework in this package. It
models application actions, their availability and execution, with optional
undo and redo.

For package-level guidance, see the [root README](../../README.md). For UI
metadata and controls, see [CommandsUI](../CommandsUI/README.md).

## Core model

- `Command` defines an asynchronous application action. Commands depend on the
  smallest `CommandCentre` protocol that provides their required services.
- `CommandCentre` evaluates availability, performs commands, and offers
  lifecycle hooks for centres that track running commands.
- `CommandAvailability` lets callers distinguish enabled, disabled, hidden, and
  running states.

## Define a command

```swift
import Commands

@MainActor
protocol SessionCommands: CommandCentre {
  func signOut()
}

@MainActor
struct SignOutCommand<C: SessionCommands>: Command {
  let id = "session.sign-out"

  func perform(centre: C) async throws {
    centre.signOut()
  }
}
```

Call `try await centre.perform(command)` when the caller needs the result or
error. `performWithoutWaiting(_:)` starts an unstructured task and reports any
error to the centre through `recordFailedCommand(_:error:)`. The default
implementation logs it; a centre with a user-facing error surface, such as a
status bar, overrides it to show the error there.

## Undo support

Commands supports two ways to undo and redo commands. Both are opt-in: a command adopts an extra protocol to become undoable, and a command that changes nothing reversible adopts only `Command`. In both, the inverse of a command is another command.

- **UndoManager** registers each command's inverse with a Foundation `UndoManager`. Use it when command undo should share the system undo stack and Edit menu with everything else in the window, such as text editing. Undoable commands must perform synchronously, because `UndoManager` cannot wait for an undo action.
- **History** records inverses in the package's own observable `HistoryService`. Use it when undoable commands need to be asynchronous, or when the app presents and drives its own undo and redo controls.

Each command protocol requires its centre to adopt the matching centre protocol, so the compiler ensures an undoable command is only performed by a centre that can record its inverse.

### UndoManager

A synchronous command adopts `CommandWithUndo`. It implements `performSynchronously(centre:)` and `undoCommand(centre:)`, and carries the `UndoManager` it was invoked with, such as SwiftUI's `@Environment(\.undoManager)`, in a `weak var`: the undo manager keeps its registered commands alive, so a strong reference would keep both alive. Its centre, a class, adopts `CommandCentreWithUndo` and is the target of its registered actions, which the undo manager does not keep alive.

```swift
@MainActor
final class EditorCommands: CommandCentreWithUndo {
  var value = 0
}

@MainActor
struct IncrementCommand: CommandWithUndo {
  let id = "editor.increment"
  weak var undoManager: UndoManager?

  func performSynchronously(centre: EditorCommands) {
    centre.value += 1
  }

  func undoCommand(centre: EditorCommands) -> DecrementCommand {
    DecrementCommand(undoManager: undoManager)
  }
}
```

Performing the command through the centre registers its inverse, named with `undoActionName(centre:)`, which is the command's localized name for a `CommandWithUI` and its `id` otherwise. The undo command is created before the command performs, so it can capture the state it restores. When the `UndoManager` runs an undo or redo, the centre checks the command's availability and calls its lifecycle hooks, as it does for any command. `UndoManager` cannot receive an error, so an unavailable undo command is reported through `recordFailedCommand(_:error:)` and skipped, and the action leaves the undo stack. Results of undone and redone commands go to `recordUndoRedoResult(_:result:)`.

Each command is a single undo step. When no undo group is open, as when a command button performs a command after its click has been handled, the command's registration and its work go in a group of their own, so nothing that happens in the next event joins the same step.

On macOS, a SwiftUI `TextField` edits through a field editor with its own undo manager. While the field is being edited, its typing is on a separate stack, and Undo reverses all of it before reaching any command, whatever order they happened in. A `TextEditor` uses the window's undo manager, so its typing and commands undo in the order they happened. The example app shows both.

### History

A command adopts `CommandWithHistory` and returns the command that reverses it, or `nil` when a particular invocation cannot be reversed.

```swift
extension SignOutCommand: CommandWithHistory where C: CommandCentreWithHistory {
  func reversal(centre: C) -> RestoreSessionCommand<C>? {
    RestoreSessionCommand()
  }
}
```

Its centre adopts `CommandCentreWithHistory` and owns a `HistoryService`, which records the reversal of each successful command:

```swift
@MainActor
final class SessionCentre: SessionCommands, CommandCentreWithHistory {
  let historyService = HistoryService()
  func signOut() { /* ... */ }
}
```

The centre asks for the reversal after the command succeeds, so the reversal can capture state the command produced. `HistoryService` uses cursor-based semantics: undo creates the operation for redo, redo restores the operation for undo, and a new forward command discards the redo branch. While an undo or redo is in progress, forward commands are disabled, and history operations wait for running forward commands to finish. Recording a step directly with `recordUndo(_:of:centre:)` throws while an undo or redo is in progress. History entries hold their centre weakly, so a centre's history does not keep it alive. See the [concurrency design](../../Extras/Documentation/Concurrency.md) for the execution and re-entrancy invariants. `CommandsUI` provides buttons that perform the next undo and redo.

### Commands that reverse each other

When a command and its inverse name each other, or a command is its own inverse, Swift cannot infer their associated types. Declare `Centre` and `Output` explicitly on one of them:

```swift
struct DecrementCommand: CommandWithUndo {
  typealias Centre = EditorCommands
  typealias Output = Void
  // ...
}
```

## Dependency

`Commands` depends on [Logger](https://github.com/elegantchaos/Logger) for
execution diagnostics.
