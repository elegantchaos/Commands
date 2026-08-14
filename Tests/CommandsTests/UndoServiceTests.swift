// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Testing

/// Command centre used to observe reversal execution.
@MainActor
private final class UndoTestCentre: UndoableCommandCentre {
  /// Command identifiers performed through a reversal.
  var performedCommandIDs: [String] = []

  /// Undo history maintained by the command centre.
  let undoService = UndoService()
}

/// Command used to verify reversal adapter and undo-stack behavior.
@MainActor
private struct UndoCommand: Command {
  /// Identifier used to verify history execution order.
  let id: String

  /// Availability reported through a reversal adapter.
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
  func availability(centre: UndoTestCentre) -> CommandAvailability {
    reportedAvailability
  }

  /// Records that a reversal performed this command.
  func perform(centre: UndoTestCentre) async throws {
    centre.performedCommandIDs.append(id)
  }

  /// Returns the command that reverses this history action.
  func reversal(centre: UndoTestCentre) -> (any CommandReversal)? {
    guard let reversalID else {
      return nil
    }
    return CommandReversalAdapter(
      command: UndoCommand(id: reversalID, reversalID: id),
      centre: centre
    )
  }
}

/// Command that supplies an undo action through `CommandReversalAdapter`.
@MainActor
private struct UndoableTestCommand: Command {
  /// Stable identifier for the forward operation.
  let id = "test.undoable.forward"

  /// Performs no work beyond registering its reversal.
  func perform(centre: UndoTestCentre) async throws {
  }

  /// Returns the command that reverses the forward operation.
  func reversal(centre: UndoTestCentre) -> (any CommandReversal)? {
    CommandReversalAdapter(command: UndoCommand(id: "test.undoable.reversal"), centre: centre)
  }
}

/// Command that supplies a reversal but fails before completing its forward operation.
@MainActor
private struct FailingUndoableTestCommand: Command {
  /// Stable identifier for the failing forward operation.
  let id = "test.undoable.failing-forward"

  /// Throws the expected test error.
  func perform(centre: UndoTestCentre) async throws {
    throw UndoFailure.expected
  }

  /// Returns a reversal that must not be recorded for the failed operation.
  func reversal(centre: UndoTestCentre) -> (any CommandReversal)? {
    CommandReversalAdapter(
      command: UndoCommand(id: "test.undoable.unexpected-reversal"),
      centre: centre
    )
  }
}

/// Error thrown by a deliberately failing reversal command.
private enum UndoFailure: Error, Equatable {
  /// The expected failure used to verify retry behavior.
  case expected
}

/// Command that fails while executing a reversal.
@MainActor
private struct FailingUndoCommand: Command {
  /// Stable identifier for the failing reversal.
  let id = "failing"

  /// Throws the expected test error.
  func perform(centre: UndoTestCentre) async throws {
    throw UndoFailure.expected
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
private struct SuspendedUndoCommand: Command {
  /// Stable identifier for the suspended reversal.
  let id = "suspended"

  /// Test-controlled suspension point.
  let gate: UndoGate

  /// Waits for the test to release the command.
  func perform(centre: UndoTestCentre) async throws {
    await gate.wait()
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
  func perform(centre: UndoTestCentre) async throws {
    await gate.wait()
  }
}

/// Reversal that attempts to execute a command in another undo service's execution context.
@MainActor
private struct CrossServiceReversal: CommandReversal {
  /// Stable identifier for the test reversal.
  let id = "cross-service"

  /// Centre whose active history operation must reject this reversal's execution context.
  let centre: UndoTestCentre

  /// Returns an enabled availability state for the test reversal.
  func availability() -> CommandAvailability {
    .enabled
  }

  /// Attempts to execute a command using the execution context supplied by another service.
  func perform(in context: CommandExecutionContext) async throws -> (any CommandReversal)? {
    _ = try await centre.perform(UndoCommand(id: "cross-service.command"), during: context)
    return nil
  }
}

/// Tests undo and redo registration, execution, and reversal adaptation.
@MainActor
struct UndoServiceTests {
  /// Verifies that undo actions can be reversed by matching redo actions.
  @Test func undoAndRedoTraverseHistoryInOrder() async throws {
    let centre = UndoTestCentre()
    centre.undoService.recordUndo(
      CommandReversalAdapter(
        command: UndoCommand(id: "undo.first", reversalID: "redo.first"),
        centre: centre
      ))
    centre.undoService.recordUndo(
      CommandReversalAdapter(
        command: UndoCommand(id: "undo.second", reversalID: "redo.second"),
        centre: centre
      ))

    #expect(centre.undoService.hasUndo)
    #expect(centre.undoService.hasRedo == false)
    #expect(centre.undoService.stackDescription == "undo.first > undo.second")
    #expect(centre.undoService.nextUndo?.id == "undo.second")

    try await centre.undoService.performUndo()
    #expect(centre.performedCommandIDs == ["undo.second"])
    #expect(centre.undoService.hasUndo)
    #expect(centre.undoService.hasRedo)
    #expect(centre.undoService.nextUndo?.id == "undo.first")
    #expect(centre.undoService.nextRedo?.id == "redo.second")

    try await centre.undoService.performUndo()
    #expect(centre.performedCommandIDs == ["undo.second", "undo.first"])
    #expect(centre.undoService.hasUndo == false)
    #expect(centre.undoService.hasRedo)
    #expect(centre.undoService.nextRedo?.id == "redo.first")

    try await centre.undoService.performRedo()
    try await centre.undoService.performRedo()
    #expect(
      centre.performedCommandIDs == ["undo.second", "undo.first", "redo.first", "redo.second"])
    #expect(centre.undoService.hasUndo)
    #expect(centre.undoService.hasRedo == false)
    #expect(centre.undoService.nextUndo?.id == "undo.second")
    #expect(centre.undoService.nextRedo == nil)
  }

  /// Verifies that recording a new command after undoing discards the redo branch.
  @Test func recordingAfterUndoDiscardsRedoHistory() async throws {
    let centre = UndoTestCentre()
    centre.undoService.recordUndo(
      CommandReversalAdapter(
        command: UndoCommand(id: "undo.original", reversalID: "redo.original"),
        centre: centre
      ))

    try await centre.undoService.performUndo()
    #expect(centre.undoService.hasRedo)

    centre.undoService.recordUndo(
      CommandReversalAdapter(command: UndoCommand(id: "undo.replacement"), centre: centre))

    #expect(centre.undoService.stackDescription == "undo.replacement")
    #expect(centre.undoService.hasUndo)
    #expect(centre.undoService.hasRedo == false)
    #expect(centre.undoService.nextUndo?.id == "undo.replacement")
  }

  /// Verifies that undoable centres record successful forward command reversals.
  @Test func undoableCentreRecordsForwardCommandReversals() async throws {
    let centre = UndoTestCentre()
    let command = UndoableTestCommand()

    try await centre.perform(command)
    #expect(centre.undoService.stackDescription == "test.undoable.reversal")
  }

  /// Verifies that failed forward commands finish tracking without registering a reversal.
  @Test func failedForwardCommandDoesNotRecordAReversal() async throws {
    let centre = UndoTestCentre()
    centre.undoService.recordUndo(
      CommandReversalAdapter(command: UndoCommand(id: "undo.existing"), centre: centre))

    await #expect(throws: UndoFailure.expected) {
      try await centre.perform(FailingUndoableTestCommand())
    }

    #expect(centre.undoService.stackDescription == "undo.existing")
    try await centre.undoService.performUndo()
    #expect(centre.performedCommandIDs == ["undo.existing"])
  }

  /// Verifies that reversal adapters preserve availability and execution behavior.
  @Test func commandReversalAdapterForwardsAvailabilityAndExecution() async throws {
    let centre = UndoTestCentre()
    let unavailableAdapter = CommandReversalAdapter(
      command: UndoCommand(id: "test.proxy", reportedAvailability: .disabled), centre: centre)

    #expect(unavailableAdapter.id == "test.proxy")
    #expect(unavailableAdapter.availability() == .disabled)

    let executableAdapter = CommandReversalAdapter(
      command: UndoCommand(id: "test.proxy"), centre: centre)

    centre.undoService.recordUndo(executableAdapter)
    try await centre.undoService.performUndo()
    #expect(centre.performedCommandIDs == ["test.proxy"])
  }

  /// Verifies that failed reversals remain available for a later retry.
  @Test func failedUndoPreservesTheReversal() async {
    let centre = UndoTestCentre()
    centre.undoService.recordUndo(
      CommandReversalAdapter(command: FailingUndoCommand(), centre: centre))

    await #expect(throws: UndoFailure.expected) {
      try await centre.undoService.performUndo()
    }

    #expect(centre.undoService.hasUndo)
    #expect(centre.undoService.stackDescription == "failing")
    #expect(centre.undoService.isUndoing == false)
  }

  /// Verifies that redo cannot start while an undo operation is suspended.
  @Test func concurrentHistoryOperationIsRejected() async throws {
    let centre = UndoTestCentre()
    let gate = UndoGate()
    centre.undoService.recordUndo(
      CommandReversalAdapter(command: SuspendedUndoCommand(gate: gate), centre: centre))

    let firstUndo = Task {
      try await centre.undoService.performUndo()
    }
    await gate.waitUntilStarted()

    await #expect(throws: UndoServiceError.historyOperationInProgress) {
      try await centre.undoService.performRedo()
    }
    #expect(centre.undoService.isUndoing)
    #expect(centre.undoService.isRedoing == false)
    #expect(centre.undoService.hasUndo)
    #expect(centre.availability(UndoableTestCommand()) == .disabled)

    await #expect(throws: CommandError.commandUnavailable) {
      try await centre.perform(UndoableTestCommand())
    }
    #expect(centre.undoService.stackDescription == "suspended")

    gate.release()
    try await firstUndo.value
    #expect(centre.undoService.isUndoing == false)
    #expect(centre.undoService.hasUndo == false)
    #expect(centre.availability(UndoableTestCommand()) == .enabled)
  }

  /// Verifies that history operations wait for previously started forward commands.
  @Test func historyOperationIsRejectedWhileForwardCommandIsRunning() async throws {
    let centre = UndoTestCentre()
    let gate = UndoGate()
    centre.undoService.recordUndo(
      CommandReversalAdapter(command: UndoCommand(id: "undo.pending"), centre: centre))

    let forwardCommand = Task {
      try await centre.perform(SuspendedForwardCommand(gate: gate))
    }
    await gate.waitUntilStarted()

    await #expect(throws: UndoServiceError.forwardCommandInProgress) {
      try await centre.undoService.performUndo()
    }
    #expect(centre.undoService.hasUndo)

    gate.release()
    try await forwardCommand.value

    try await centre.undoService.performUndo()
    #expect(centre.performedCommandIDs == ["undo.pending"])
  }

  /// Verifies that one undo service cannot use another service's active context.
  @Test func executionContextIsRestrictedToItsOwningService() async throws {
    let activeCentre = UndoTestCentre()
    let activeGate = UndoGate()
    activeCentre.undoService.recordUndo(
      CommandReversalAdapter(command: SuspendedUndoCommand(gate: activeGate), centre: activeCentre))

    let activeUndo = Task {
      try await activeCentre.undoService.performUndo()
    }
    await activeGate.waitUntilStarted()

    let otherCentre = UndoTestCentre()
    otherCentre.undoService.recordUndo(CrossServiceReversal(centre: activeCentre))

    await #expect(throws: CommandError.commandUnavailable) {
      try await otherCentre.undoService.performUndo()
    }
    #expect(activeCentre.performedCommandIDs.isEmpty)

    activeGate.release()
    try await activeUndo.value
  }
}
