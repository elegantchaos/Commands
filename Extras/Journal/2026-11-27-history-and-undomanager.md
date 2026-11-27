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

## Tabbed example

The example app now has two tabs, each with its own centre and count. The UndoManager tab performs `IncrementCountCommand` and `DecrementCountCommand` through `CommandCentreWithUndo`, beside a text field that shares the window's undo manager; `UndoManagerButtons` drives that manager and redraws on its change notifications, since `UndoManager` is not observable. The History tab is the earlier demo. The command names in the string catalog are now Increment and Decrement.

The test plan had no test targets, so the UI tests never ran from the command line; it now includes `ExampleUITests`. New UI tests perform, undo and redo a command on each tab, and pass on the iOS 27.2 simulator. On macOS, `xcodebuild` could not run them: enabling UI automation timed out, as it needs approval on the machine. The text field's shared undo stack is not covered by a test.

With `showsCommandPresentation`, the History undo button named the pending reversal, so after Increment it read "Undo Decrement" while the UndoManager tab read "Undo Increment". Each `HistoryEntry` now holds an `action`: the forward command that names its step, kept as the step moves between undo and redo. `recordUndo` takes it explicitly (`recordUndo(_:of:centre:)`), and the buttons present it, so both tabs read "Undo Increment" and "Redo Increment". Both undo APIs now explain why they take the step's name separately from the command they perform. The example UI tests check the exact titles on both tabs.

## Undo ordering with text editing

On macOS, typing and commands sometimes undid in the wrong order. There were two causes.

- Command buttons perform commands asynchronously, after the click has been handled. The window's event-grouping `UndoManager` left the group for the command's registration open until the next event ended, so the next keystroke joined the command's undo step. `performAndRegisterUndo` now gives a command its own group when no group is open, pausing event grouping meanwhile, because beginning a group at the top level otherwise opens the automatic event group around it first. A unit test with an event-grouping `UndoManager` covers it.
- SwiftUI's `TextField` on macOS edits through `_SystemTextFieldFieldEditor`, whose undo manager is not the window's. Its typing undoes before anything on the window's stack. `TextEditor` uses the window's undo manager. A temporary on-screen probe of the environment, window and first-responder undo managers showed this.

The UndoManager tab now has both a text field and a text editor. Its macOS UI tests type, run Increment, type again and undo three times: the editor undoes in order, and the field's test records the difference with `XCTExpectFailure`, so it will report if the field starts sharing the window's stack. UI automation is now enabled on the development Mac, and all four example UI tests pass on macOS and the iOS 27.2 simulator.

The example app no longer has a string catalog: it is not localized, and its commands return their names directly and have no help text. `AGENTS.md` records this as an override of the localization guidance for the example app only, and drops the project rule about localizing command metadata, which the `swift:language` skill covers.

Incremental macOS test builds failed code signing on the empty `ExampleTests` bundle embedded in the app. The target had no sources, so it is removed from the project and the scheme; incremental test builds now sign cleanly. The text-input UI tests also wait for the input to take keyboard focus before typing, after one run typed before the text editor had focus.

Associated-type inference cannot resolve a command that names itself, or a partner that names it back, as its undo command. Such commands must declare `Centre` and `ResultType` explicitly, as the tests do.

## Validation

`swift build --build-tests` and `swift test` pass (both test runs, 21 and 19 tests). The example app builds for macOS with `xcodebuild`. Builds ran outside the agent sandbox because SwiftPM could not write to its dependency checkouts inside it.

## Breaking renames

Since this is a breaking release, some names changed to read more consistently:

- `Command.ResultType` is now `Command.Output`. `CommandResult` was considered, but it repeats the protocol's name at use sites (`C.CommandResult`) and sits awkwardly beside `CommandOutcome`; `Output` follows `Publisher.Output`.
- CommandsUI called a command centre a "commander": `CommandButton(commander:)`, `CommandsHost(commander:)` with its `Commander` parameter, and `InheritedCommander`. These are now `centre:`, `Centre` and `InheritedCentre`, and generic parameters named `CC` are now `Centre`. The example's centres are `HistoryExampleCentre` and `UndoManagerExampleCentre`.
- `CommandWithUndo.nameForUndo(centre:)` is now `undoActionName(centre:)`, matching `UndoManager.undoActionName`, and `performAndRegisterUndo(command:undo:undoManager:name:)` takes `inverse:` and `actionName:`.

`ImporterCommand`, `CommandExecutionContext` and the separate `UndoCommand`/`ReversalCommand` names were left as they are.

## Unused strings

Removed three keys from the CommandsUI string catalog that nothing referenced, by literal or generated symbol: `about.stack` and `tag.delete.message`, left over from the app this code came from, and `action.help`.

## Merging main

Main had moved on with stable command-control identity (controls keep their outermost view and leave hiding to the presentation), new toolbar item types, Logger 3, and an example app reworked into a bench of pages. Merging it:

- The command buttons and history buttons take main's always-present layout, with this branch's names: `centre` rather than `commander`, `Centre` rather than `CC`, and the History types. The new toolbar types use the same names.
- The bench's single centre is `ExampleCentre`, on the History API. Its undo page is replaced by an UndoManager page and a History page, built from the two views that were tabs on this branch; the tab view is gone.
- The bench's macOS-only UI tests sit beside this branch's undo tests. The undo-page tests also run on iOS, where `showPage` goes back to the page list first, because the compact split view opens on the selected page.

The undo-page UI tests pass on the iOS 27.2 simulator. On macOS, the UndoManager page's text editor sequence and the History page's undo and redo were checked by hand in a VM; the bench's own macOS UI tests were not run.
