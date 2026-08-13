# Commands

`Commands` is the core, UI-independent command framework in this package. It
models application actions, their availability, execution, and optional
reversals for undo and redo.

For package-level guidance, see the [root README](../../README.md). For UI
metadata and controls, see [CommandsUI](../CommandsUI/README.md).

## Core model

- `Command` defines an asynchronous application action. Commands depend on the
  smallest `CommandCentre` protocol that provides their required services.
- `CommandCentre` evaluates availability, performs commands, and offers
  lifecycle hooks for centres that track running commands.
- `CommandAvailability` lets callers distinguish enabled, disabled, hidden, and
  running states.
- `CommandReversal` is the type-erased operation used by `UndoService` to move
  between undo and redo. `CommandReversalAdapter` adapts a concrete command and
  its centre into a reversal.
- `UndoableCommandCentre` integrates `UndoService` with normal command
  execution.

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
error. `performWithoutWaiting(_:)` starts an unstructured task and logs any
error.

## Add undo and redo

Commands that change reversible state return a reversal. The adapter is the
normal bridge when the reversal is another command.

```swift
func reversal(centre: C) -> (any CommandReversal)? {
  CommandReversalAdapter(command: RestoreSessionCommand(), centre: centre)
}
```

An undoable centre records successful reversals automatically:

```swift
@MainActor
final class EditorCommands: UndoableCommandCentre {
  let undoService = UndoService()
}
```

`UndoService` uses cursor-based semantics: undo creates the operation for redo,
redo restores the operation for undo, and a new forward command discards the
redo branch. See the [concurrency design](../../Extras/Documentation/Concurrency.md)
for the execution and re-entrancy invariants.

## Dependency

`Commands` depends on [Logger](https://github.com/elegantchaos/Logger) for
execution diagnostics.
