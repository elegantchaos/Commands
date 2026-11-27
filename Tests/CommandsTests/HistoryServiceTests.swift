// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Testing

/// Command centre used to observe reversal execution.
@MainActor
private final class HistoryTestCentre: CommandCentreWithHistory {
  /// Command identifiers performed through a reversal.
  var performedCommandIDs: [String] = []

  /// Undo history maintained by the command centre.
  let historyService = HistoryService()
}

/// Command used to verify history entries and undo-stack behavior.
@MainActor
private struct UndoCommand: CommandWithHistory {
  /// Centre type, declared because inference cannot resolve a command that is its own reversal.
  typealias Centre = HistoryTestCentre

  /// Output type, declared for the same reason as `Centre`.
  typealias Output = Void

  /// Identifier used to verify history execution order.
  let id: String

  /// Availability reported through the history entry.
  let reportedAvailability: CommandAvailability

  /// Identifier of the command that reverses this command.
  let reversalID: String?

  /// Creates a command with the supplied identifier, availability, and reversal.
  init(
    id: String,
    reportedAvailability: CommandAvailability = .enabled,
    reversalID: String? = nil
  ) {
    self.id = id
    self.reportedAvailability = reportedAvailability
    self.reversalID = reversalID
  }

  /// Returns the configured availability.
  func availability(centre: HistoryTestCentre) -> CommandAvailability {
    reportedAvailability
  }

  /// Records that history performed this command.
  func perform(centre: HistoryTestCentre) async throws {
    centre.performedCommandIDs.append(id)
  }

  /// Returns the command that reverses this history action.
  func reversal(centre: HistoryTestCentre) -> UndoCommand? {
    reversalID.map { UndoCommand(id: $0, reversalID: id) }
  }
}

/// Forward command whose reversal the centre records.
@MainActor
private struct UndoableTestCommand: CommandWithHistory {
  /// Stable identifier for the forward operation.
  let id = "test.undoable.forward"

  /// Performs no work beyond supplying its reversal.
  func perform(centre: HistoryTestCentre) async throws {
  }

  /// Returns the command that reverses the forward operation.
  func reversal(centre: HistoryTestCentre) -> UndoCommand? {
    UndoCommand(id: "test.undoable.reversal")
  }
}

/// Forward command that adopts history but has nothing to reverse this time.
@MainActor
private struct IrreversibleTestCommand: CommandWithHistory {
  /// Stable identifier for the forward operation.
  let id = "test.undoable.irreversible"

  /// Performs no work.
  func perform(centre: HistoryTestCentre) async throws {
  }

  /// Reports that this invocation cannot be reversed.
  func reversal(centre: HistoryTestCentre) -> UndoCommand? {
    nil
  }
}

/// Forward command that does not adopt history at all.
@MainActor
private struct PlainTestCommand: Command {
  /// Stable identifier for the forward operation.
  let id = "test.plain"

  /// Performs no work.
  func perform(centre: HistoryTestCentre) async throws {
  }
}

/// Command that supplies a reversal but fails before completing its forward operation.
@MainActor
private struct FailingUndoableTestCommand: CommandWithHistory {
  /// Stable identifier for the failing forward operation.
  let id = "test.undoable.failing-forward"

  /// Throws the expected test error.
  func perform(centre: HistoryTestCentre) async throws {
    throw UndoFailure.expected
  }

  /// Returns a reversal that must not be recorded for the failed operation.
  func reversal(centre: HistoryTestCentre) -> UndoCommand? {
    UndoCommand(id: "test.undoable.unexpected-reversal")
  }
}

/// Error thrown by a deliberately failing reversal command.
private enum UndoFailure: Error, Equatable {
  /// The expected failure used to verify retry behavior.
  case expected
}

/// Command that fails while executing a reversal.
@MainActor
private struct FailingUndoCommand: CommandWithHistory {
  /// Stable identifier for the failing reversal.
  let id = "failing"

  /// Throws the expected test error.
  func perform(centre: HistoryTestCentre) async throws {
    throw UndoFailure.expected
  }

  /// Has no reversal, so a successful run would leave the history.
  func reversal(centre: HistoryTestCentre) -> UndoCommand? {
    nil
  }
}

/// Coordinates a suspended undo operation without relying on timing.
@MainActor
private final class UndoGate {
  /// Whether the suspended command has started.
  private var hasStarted = false

  /// Continuation resumed when the command starts.
  private var startContinuation: CheckedContinuation<Void, Never>?

  /// Continuation resumed to let the command finish.
  private var releaseContinuation: CheckedContinuation<Void, Never>?

  /// Waits until the test releases the suspended command.
  func wait() async {
    hasStarted = true
    startContinuation?.resume()
    startContinuation = nil

    await withCheckedContinuation { continuation in
      releaseContinuation = continuation
    }
  }

  /// Suspends until the command has begun executing.
  func waitUntilStarted() async {
    guard hasStarted == false else {
      return
    }

    await withCheckedContinuation { continuation in
      startContinuation = continuation
    }
  }

  /// Lets the suspended command finish.
  func release() {
    releaseContinuation?.resume()
    releaseContinuation = nil
  }
}

/// Command that suspends until a test explicitly releases it.
@MainActor
private struct SuspendedUndoCommand: CommandWithHistory {
  /// Stable identifier for the suspended reversal.
  let id = "suspended"

  /// Test-controlled suspension point.
  let gate: UndoGate

  /// Waits for the test to release the command.
  func perform(centre: HistoryTestCentre) async throws {
    await gate.wait()
  }

  /// Has no reversal, so the entry leaves the history once performed.
  func reversal(centre: HistoryTestCentre) -> UndoCommand? {
    nil
  }
}

/// Command that suspends while it represents a forward operation.
@MainActor
private struct SuspendedForwardCommand: Command {
  /// Stable identifier for the suspended forward command.
  let id = "suspended.forward"

  /// Test-controlled suspension point.
  let gate: UndoGate

  /// Waits for the test to release the command.
  func perform(centre: HistoryTestCentre) async throws {
    await gate.wait()
  }
}

@MainActor
extension HistoryService {
  /// Records a command as a step named after itself, for tests that do not check step names.
  fileprivate func recordUndo<C: CommandWithHistory>(_ command: C, centre: C.Centre) {
    recordUndo(command, of: command, centre: centre)
  }
}

/// Tests undo and redo registration, execution, and history recording.
@MainActor
struct HistoryServiceTests {
  /// Verifies that undo actions can be reversed by matching redo actions.
  @Test func undoAndRedoTraverseHistoryInOrder() async throws {
    let centre = HistoryTestCentre()
    centre.historyService.recordUndo(
      UndoCommand(id: "undo.first", reversalID: "redo.first"), centre: centre)
    centre.historyService.recordUndo(
      UndoCommand(id: "undo.second", reversalID: "redo.second"), centre: centre)

    #expect(centre.historyService.hasUndo)
    #expect(centre.historyService.hasRedo == false)
    #expect(centre.historyService.stackDescription == "undo.first > undo.second")
    #expect(centre.historyService.nextUndo?.id == "undo.second")

    try await centre.historyService.performUndo()
    #expect(centre.performedCommandIDs == ["undo.second"])
    #expect(centre.historyService.hasUndo)
    #expect(centre.historyService.hasRedo)
    #expect(centre.historyService.nextUndo?.id == "undo.first")
    #expect(centre.historyService.nextRedo?.id == "redo.second")

    try await centre.historyService.performUndo()
    #expect(centre.performedCommandIDs == ["undo.second", "undo.first"])
    #expect(centre.historyService.hasUndo == false)
    #expect(centre.historyService.hasRedo)
    #expect(centre.historyService.nextRedo?.id == "redo.first")

    try await centre.historyService.performRedo()
    try await centre.historyService.performRedo()
    #expect(
      centre.performedCommandIDs == ["undo.second", "undo.first", "redo.first", "redo.second"])
    #expect(centre.historyService.hasUndo)
    #expect(centre.historyService.hasRedo == false)
    #expect(centre.historyService.nextUndo?.id == "undo.second")
    #expect(centre.historyService.nextRedo == nil)
  }

  /// Verifies that recording a new command after undoing discards the redo branch.
  @Test func recordingAfterUndoDiscardsRedoHistory() async throws {
    let centre = HistoryTestCentre()
    centre.historyService.recordUndo(
      UndoCommand(id: "undo.original", reversalID: "redo.original"), centre: centre)

    try await centre.historyService.performUndo()
    #expect(centre.historyService.hasRedo)

    centre.historyService.recordUndo(UndoCommand(id: "undo.replacement"), centre: centre)

    #expect(centre.historyService.stackDescription == "undo.replacement")
    #expect(centre.historyService.hasUndo)
    #expect(centre.historyService.hasRedo == false)
    #expect(centre.historyService.nextUndo?.id == "undo.replacement")
  }

  /// Verifies that centres with history record the reversals of successful forward commands.
  @Test func historyCentreRecordsForwardCommandReversals() async throws {
    let centre = HistoryTestCentre()
    let command = UndoableTestCommand()

    try await centre.perform(command)
    #expect(centre.historyService.stackDescription == "test.undoable.reversal")
  }

  /// Verifies that failed forward commands finish tracking without registering a reversal.
  @Test func failedForwardCommandDoesNotRecordAReversal() async throws {
    let centre = HistoryTestCentre()
    centre.historyService.recordUndo(UndoCommand(id: "undo.existing"), centre: centre)

    await #expect(throws: UndoFailure.expected) {
      try await centre.perform(FailingUndoableTestCommand())
    }

    #expect(centre.historyService.stackDescription == "undo.existing")
    try await centre.historyService.performUndo()
    #expect(centre.performedCommandIDs == ["undo.existing"])
  }

  /// Verifies that history entries report their command's identity and availability and perform it.
  @Test func historyEntryForwardsAvailabilityAndExecution() async throws {
    let centre = HistoryTestCentre()
    centre.historyService.recordUndo(
      UndoCommand(id: "test.disabled", reportedAvailability: .disabled), centre: centre)

    #expect(centre.historyService.nextUndo?.id == "test.disabled")
    #expect(centre.historyService.nextUndo?.availability() == .disabled)

    centre.historyService.recordUndo(UndoCommand(id: "test.entry"), centre: centre)
    try await centre.historyService.performUndo()
    #expect(centre.performedCommandIDs == ["test.entry"])
  }

  /// Verifies that a history command returning no reversal leaves the history unchanged.
  @Test func irreversibleInvocationIsNotRecorded() async throws {
    let centre = HistoryTestCentre()

    try await centre.perform(IrreversibleTestCommand())
    #expect(centre.historyService.hasUndo == false)
  }

  /// Verifies that commands which do not adopt history leave it unchanged.
  @Test func plainCommandIsNotRecorded() async throws {
    let centre = HistoryTestCentre()

    try await centre.perform(PlainTestCommand())
    #expect(centre.historyService.hasUndo == false)
  }

  /// Verifies that failed reversals remain available for a later retry.
  @Test func failedUndoPreservesTheReversal() async {
    let centre = HistoryTestCentre()
    centre.historyService.recordUndo(FailingUndoCommand(), centre: centre)

    await #expect(throws: UndoFailure.expected) {
      try await centre.historyService.performUndo()
    }

    #expect(centre.historyService.hasUndo)
    #expect(centre.historyService.stackDescription == "failing")
    #expect(centre.historyService.isUndoing == false)
  }

  /// Verifies that redo cannot start while an undo operation is suspended.
  @Test func concurrentHistoryOperationIsRejected() async throws {
    let centre = HistoryTestCentre()
    let gate = UndoGate()
    centre.historyService.recordUndo(SuspendedUndoCommand(gate: gate), centre: centre)

    let firstUndo = Task {
      try await centre.historyService.performUndo()
    }
    await gate.waitUntilStarted()

    await #expect(throws: HistoryServiceError.historyOperationInProgress) {
      try await centre.historyService.performRedo()
    }
    #expect(centre.historyService.isUndoing)
    #expect(centre.historyService.isRedoing == false)
    #expect(centre.historyService.hasUndo)
    #expect(centre.availability(UndoableTestCommand()) == .disabled)

    await #expect(throws: CommandError.commandUnavailable) {
      try await centre.perform(UndoableTestCommand())
    }
    #expect(centre.historyService.stackDescription == "suspended")

    gate.release()
    try await firstUndo.value
    #expect(centre.historyService.isUndoing == false)
    #expect(centre.historyService.hasUndo == false)
    #expect(centre.availability(UndoableTestCommand()) == .enabled)
  }

  /// Verifies that history operations wait for previously started forward commands.
  @Test func historyOperationIsRejectedWhileForwardCommandIsRunning() async throws {
    let centre = HistoryTestCentre()
    let gate = UndoGate()
    centre.historyService.recordUndo(UndoCommand(id: "undo.pending"), centre: centre)

    let forwardCommand = Task {
      try await centre.perform(SuspendedForwardCommand(gate: gate))
    }
    await gate.waitUntilStarted()

    await #expect(throws: HistoryServiceError.forwardCommandInProgress) {
      try await centre.historyService.performUndo()
    }
    #expect(centre.historyService.hasUndo)

    gate.release()
    try await forwardCommand.value

    try await centre.historyService.performUndo()
    #expect(centre.performedCommandIDs == ["undo.pending"])
  }

  /// Verifies that one history service cannot use another service's active context.
  @Test func executionContextIsRestrictedToItsOwningService() async throws {
    let activeCentre = HistoryTestCentre()
    let activeGate = UndoGate()
    activeCentre.historyService.recordUndo(
      SuspendedUndoCommand(gate: activeGate), centre: activeCentre)

    let activeUndo = Task {
      try await activeCentre.historyService.performUndo()
    }
    await activeGate.waitUntilStarted()

    let otherCentre = HistoryTestCentre()
    otherCentre.historyService.recordUndo(
      UndoCommand(id: "cross-service.command"), centre: activeCentre)

    await #expect(throws: CommandError.commandUnavailable) {
      try await otherCentre.historyService.performUndo()
    }
    #expect(activeCentre.performedCommandIDs.isEmpty)

    activeGate.release()
    try await activeUndo.value
  }
}
