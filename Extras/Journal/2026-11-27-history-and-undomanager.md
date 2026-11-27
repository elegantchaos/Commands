# 2026-11-27 — History rename and UndoManager undo

## Summary

Added a second undo mechanism built on Foundation's `UndoManager` (`CommandCentreWithUndo`, `CommandWithUndo`), based on experiments in the UndoTests project. To keep the names apart, the existing mechanism is now "History": `UndoService` became `HistoryService`, `UndoServiceError` became `HistoryServiceError`, `UndoableCommandCentre` became `CommandCentreWithHistory` with a `historyService` property, the buttons became `HistoryUndoButton` and `HistoryRedoButton`, and the centre helpers became `historyUndoButton()` and `historyRedoButton()`. Tests, READMEs, the concurrency design document and the example app use the new names.

## Why

SwiftUI uses the environment's `UndoManager` for text-field undo, so commands that register with the same manager share one undo stack and the standard Edit menu with text editing. The UndoManager version is generic throughout: the registered closure holds the concrete command types, so it needs no type-erased reversal adapters. It requires undoable commands to perform synchronously, because `UndoManager` cannot await an undo action. This removes the re-entrancy machinery that History needs for async reversals.

## Fixes made during the rename

- The bulk rename had also changed `CommandWithUndo`'s centre constraint to `CommandCentreWithHistory`. It now requires `CommandCentreWithUndo`.
- The test target had not been updated and did not compile; it now uses the new names, and the suite is `HistoryServiceTests`.

## Known issues

- `CommandWithUI`'s `nameForUndo` override is internal, so conformances outside `CommandsUI` fall back to `id` for the undo action name.
- Undo and redo registered with `UndoManager` call `performSynchronously` directly, bypassing the centre's availability check and lifecycle hooks.
- `CommandCentreWithUndo` logs with `print` instead of `commandChannel`.
- The UndoManager mechanism has no tests yet.

## Validation

`swift build --build-tests` and `swift test` pass (both test runs, 21 and 19 tests). The example app builds for macOS with `xcodebuild`. Builds ran outside the agent sandbox because SwiftPM could not write to its dependency checkouts inside it.
