// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/11/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Foundation
import Testing

/// Command centre that records lifecycle hooks and undo results for UndoManager tests.
@MainActor
private final class UndoTestCentre: CommandCentreWithUndo {
  /// Value changed by the test commands.
  var value = 0

  /// Whether the decrement command reports itself as enabled.
  var isDecrementEnabled = true

  /// Identifiers of commands whose start was recorded.
  var startedCommandIDs: [String] = []

  /// Identifiers of commands whose successful completion was recorded.
  var finishedCommandIDs: [String] = []

  /// Identifiers of commands whose failure was reported.
  var failedCommandIDs: [String] = []

  /// Results returned by commands performed through undo or redo.
  var undoRedoResults: [Int] = []

  /// The centre itself owns the registered undo actions.
  var undoTarget: AnyObject { self }

  /// Records that a command started.
  func recordStartedCommand<C: Command>(_ command: C) where C.Centre == UndoTestCentre {
    startedCommandIDs.append(command.id)
  }

  /// Records that a command finished successfully.
  func recordFinishedCommand<C: Command>(_ command: C, outcome: CommandOutcome)
  where C.Centre == UndoTestCentre {
    if case .succeeded = outcome {
      finishedCommandIDs.append(command.id)
    }
  }

  /// Records that a command failed without a caller to receive the error.
  func recordFailedCommand<C: Command>(_ command: C, error: any Error)
  where C.Centre == UndoTestCentre {
    failedCommandIDs.append(command.id)
  }

  /// Records the result of a command performed through undo or redo.
  func recordUndoRedoResult<C: CommandWithUndo>(_ command: C, result: C.Output)
  where C.Centre == UndoTestCentre {
    if let result = result as? Int {
      undoRedoResults.append(result)
    }
  }
}

/// Increments the centre's value and returns the new value.
@MainActor
private struct IncrementCommand: CommandWithUndo {
  /// Stable identifier, also used as the default undo action name.
  let id = "test.undo.increment"

  /// Undo manager that receives the inverse command.
  let undoManager: UndoManager?

  /// Increments the value.
  func performSynchronously(centre: UndoTestCentre) -> Int {
    centre.value += 1
    return centre.value
  }

  /// Returns the command that reverses the increment.
  func undoCommand(centre: UndoTestCentre) -> DecrementCommand {
    DecrementCommand(undoManager: undoManager)
  }
}

/// Decrements the centre's value and returns the new value.
@MainActor
private struct DecrementCommand: CommandWithUndo {
  /// Centre type, declared because inference cannot resolve a pair of mutually inverse commands.
  typealias Centre = UndoTestCentre

  /// Output type, declared for the same reason as `Centre`.
  typealias Output = Int

  /// Stable identifier for lifecycle assertions.
  let id = "test.undo.decrement"

  /// Undo manager that receives the inverse command.
  let undoManager: UndoManager?

  /// Reports the availability configured on the centre.
  func availability(centre: UndoTestCentre) -> CommandAvailability {
    centre.isDecrementEnabled ? .enabled : .disabled
  }

  /// Decrements the value.
  func performSynchronously(centre: UndoTestCentre) -> Int {
    centre.value -= 1
    return centre.value
  }

  /// Returns the command that reverses the decrement.
  func undoCommand(centre: UndoTestCentre) -> IncrementCommand {
    IncrementCommand(undoManager: undoManager)
  }
}

/// Tests undo and redo of commands registered with a Foundation `UndoManager`.
@MainActor
struct CommandCentreWithUndoTests {
  /// Centre under test.
  private let centre = UndoTestCentre()

  /// Undo manager with explicit grouping, so each test controls its undo groups.
  private let undoManager: UndoManager

  /// Creates an undo manager that groups only where a test asks it to.
  init() {
    undoManager = UndoManager()
    undoManager.groupsByEvent = false
  }

  /// Performs an increment inside its own undo group.
  private func performIncrement() async throws {
    undoManager.beginUndoGrouping()
    _ = try await centre.perform(IncrementCommand(undoManager: undoManager))
    undoManager.endUndoGrouping()
  }

  /// Verifies that performing a command registers an undo action named after it.
  @Test func performRegistersNamedUndo() async throws {
    try await performIncrement()

    #expect(centre.value == 1)
    #expect(undoManager.canUndo)
    #expect(undoManager.undoActionName == "test.undo.increment")
  }

  /// Verifies that undo reverses a command and redo reapplies it, reporting each result.
  @Test func undoAndRedoReverseAndReapply() async throws {
    try await performIncrement()

    undoManager.undo()
    #expect(centre.value == 0)
    #expect(undoManager.canRedo)
    #expect(undoManager.redoActionName == "test.undo.increment")

    undoManager.redo()
    #expect(centre.value == 1)
    #expect(undoManager.canUndo)
    #expect(centre.undoRedoResults == [0, 1])
  }

  /// Verifies that undo and redo report the same lifecycle hooks as a forward command.
  @Test func undoAndRedoRecordLifecycle() async throws {
    try await performIncrement()

    undoManager.undo()
    undoManager.redo()

    let expected = ["test.undo.increment", "test.undo.decrement", "test.undo.increment"]
    #expect(centre.startedCommandIDs == expected)
    #expect(centre.finishedCommandIDs == expected)
  }

  /// Verifies that an unavailable undo command is reported and not performed.
  @Test func unavailableUndoIsReportedAndSkipped() async throws {
    try await performIncrement()
    centre.isDecrementEnabled = false

    undoManager.undo()

    #expect(centre.value == 1)
    #expect(centre.failedCommandIDs == ["test.undo.decrement"])
    #expect(centre.startedCommandIDs == ["test.undo.increment"])
    #expect(centre.undoRedoResults.isEmpty)
  }

  /// Verifies that a command performed outside an event leaves its undo action in a closed group of its own.
  ///
  /// Command buttons perform commands asynchronously, outside the event that triggered them. An
  /// event-grouping undo manager would otherwise keep the registration's group open until the next
  /// event ends, merging the command with whatever that event does, such as typing.
  @Test func registrationOutsideAnEventClosesItsGroup() async throws {
    let eventUndoManager = UndoManager()
    #expect(eventUndoManager.groupsByEvent)

    _ = try await centre.perform(IncrementCommand(undoManager: eventUndoManager))

    #expect(eventUndoManager.groupingLevel == 0)
    #expect(eventUndoManager.canUndo)
    #expect(eventUndoManager.undoActionName == "test.undo.increment")

    eventUndoManager.undo()
    #expect(centre.value == 0)
  }
}
