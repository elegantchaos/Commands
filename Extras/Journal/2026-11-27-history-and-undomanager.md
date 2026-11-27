# 2026-11-27 — History rename and UndoManager undo

## Summary

Added a second undo mechanism built on Foundation's `UndoManager` (`CommandCentreWithUndo`, `CommandWithUndo`), based on experiments in the UndoTests project. To keep the names apart, the existing mechanism is now "History": `UndoService` became `HistoryService`, `UndoServiceError` became `HistoryServiceError`, `UndoableCommandCentre` became `CommandCentreWithHistory` with a `historyService` property, the buttons became `HistoryUndoButton` and `HistoryRedoButton`, and the centre helpers became `historyUndoButton()` and `historyRedoButton()`. Tests, READMEs, the concurrency design document and the example app use the new names.

## Why

SwiftUI uses the environment's `UndoManager` for text-field undo, so commands that register with the same manager share one undo stack and the standard Edit menu with text editing. The UndoManager version is generic throughout: the registered closure holds the concrete command types, so it needs no type-erased reversal adapters. It requires undoable commands to perform synchronously, because `UndoManager` cannot await an undo action. This removes the re-entrancy machinery that History needs for async reversals.

## Fixes made during the rename

- The bulk rename had also changed `CommandWithUndo`'s centre constraint to `CommandCentreWithHistory`. It now requires `CommandCentreWithUndo`.
- The test target had not been updated and did not compile; it now uses the new names, and the suite is `HistoryServiceTests`.

## UndoManager fixes

- `CommandWithUI`'s `nameForUndo` override is now public, so UI commands in apps name their undo action with their display name instead of their `id`. A scratch client package outside the test target confirmed this; the test target's `@testable` imports may hide a regression.
- Registered undo and redo actions now check the undo command's availability and call `recordStartedCommand` and `recordFinishedCommand`, as a forward command performed through the centre does. `UndoManager` cannot receive an error, so an unavailable undo command is reported through `recordFailedCommand` and dropped from the stack.
- `recordUndoRedoResult` now requires `C.Centre == Self`. Without it, the default implementation did not satisfy the requirement, so no centre could conform.
- `CommandWithUndo`'s default `perform` lost a `where` clause that repeated the protocol's own constraints.
- Added `CommandCentreWithUndoTests` and `CommandWithUndoUITests`.

## Generic history

History no longer needs type-erased reversal proxies. Commands opt in by adopting `CommandWithHistory`, whose `reversal(centre:)` returns a concrete command or `nil`; commands with nothing to reverse adopt only `Command`, as before. `HistoryService` stores `HistoryEntry` values that capture the command and centre with their concrete types, and `recordUndo(_:centre:)` takes a command. `CommandCentreWithHistory` opens a finished command as `any CommandWithHistory` to record its reversal. `CommandReversal`, `CommandReversalAdapter`, `CommandReversalAdapterWithUI`, `CommandReversalWithUI` and `Command.reversal(centre:)` are gone. The history buttons read UI metadata from the entry's command when it adopts `CommandWithUI`, and `WrappedCommand` adopts `CommandWithHistory` when the command it wraps does. The example commands adopt it conditionally, when their centre keeps history.

The two mechanisms still differ in when the inverse is created: History asks for the reversal after the command succeeds, while `CommandWithUndo` creates its undo command before performing. The method names differ (`reversal` and `undoCommand`) to keep that visible.

The concurrency design document's wording changed from reversals to history entries; its invariants are unchanged.

Associated-type inference cannot resolve a command that names itself, or a partner that names it back, as its undo command. Such commands must declare `Centre` and `ResultType` explicitly, as the tests do.

## Validation

`swift build --build-tests` and `swift test` pass (both test runs, 21 and 19 tests). The example app builds for macOS with `xcodebuild`. Builds ran outside the agent sandbox because SwiftPM could not write to its dependency checkouts inside it.
