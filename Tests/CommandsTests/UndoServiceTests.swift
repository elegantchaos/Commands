// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Testing

/// Command centre used to observe inverse command execution.
@MainActor
private final class UndoTestCentre: UndoableCommandCentre {
  /// Command identifiers performed through an inverse.
  var performedCommandIDs: [String] = []

  /// Undo history maintained by the command centre.
  let undoService = UndoService()
}

/// Command used to verify inverse proxy and undo-stack behavior.
@MainActor
private struct UndoCommand: Command {
  /// Identifier used to verify history execution order.
  let id: String

  /// Availability reported through an inverse proxy.
  let reportedAvailability: CommandAvailability

  /// Identifier of the command that reverses this command.
  let inverseID: String?

  /// Creates a command with the supplied identifier, availability, and inverse.
  init(
    id: String,
    reportedAvailability: CommandAvailability = .enabled,
    inverseID: String? = nil
  ) {
    self.id = id
    self.reportedAvailability = reportedAvailability
    self.inverseID = inverseID
  }

  /// Returns the configured availability.
  func availability(centre: UndoTestCentre) -> CommandAvailability {
    reportedAvailability
  }

  /// Records that an inverse performed this command.
  func perform(centre: UndoTestCentre) async throws {
    centre.performedCommandIDs.append(id)
  }

  /// Returns the command that reverses this history action.
  func inverse(centre: UndoTestCentre) -> CommandInverse? {
    guard let inverseID else {
      return nil
    }
    return CommandInverseProxy(
      command: UndoCommand(id: inverseID, inverseID: id),
      centre: centre
    )
  }
}

/// Command that supplies an undo action through `CommandInverseProxy`.
@MainActor
private struct UndoableTestCommand: Command {
  /// Stable identifier for the forward operation.
  let id = "test.undoable.forward"

  /// Performs no work beyond registering its inverse.
  func perform(centre: UndoTestCentre) async throws {
  }

  /// Returns the command that reverses the forward operation.
  func inverse(centre: UndoTestCentre) -> CommandInverse? {
    CommandInverseProxy(command: UndoCommand(id: "test.undoable.inverse"), centre: centre)
  }
}

/// Error thrown by a deliberately failing inverse command.
private enum UndoFailure: Error, Equatable {
  /// The expected failure used to verify retry behavior.
  case expected
}

/// Command that fails while executing an inverse.
@MainActor
private struct FailingUndoCommand: Command {
  /// Stable identifier for the failing inverse.
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
  /// Stable identifier for the suspended inverse.
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

/// Inverse that attempts to execute a command in another undo service's execution context.
@MainActor
private struct CrossServiceInverse: CommandInverse {
  /// Stable identifier for the test inverse.
  let id = "cross-service"

  /// Centre whose active history operation must reject this inverse's execution context.
  let centre: UndoTestCentre

  /// Returns an enabled availability state for the test inverse.
  var availability: () -> CommandAvailability {
    { .enabled }
  }

  /// Attempts to execute a command using the execution context supplied by another service.
  var action: (CommandExecutionContext) async throws -> CommandInverse? {
    { context in
      _ = try await centre.perform(
        UndoCommand(id: "cross-service.command"), during: context)
      return nil
    }
  }
}

/// Tests undo and redo registration, execution, and inverse-command adaptation.
@MainActor
struct UndoServiceTests {
  /// Verifies that undo actions can be reversed by matching redo actions.
  @Test func undoAndRedoTraverseHistoryInOrder() async throws {
    let centre = UndoTestCentre()
    centre.undoService.recordUndo(
      CommandInverseProxy(
        command: UndoCommand(id: "undo.first", inverseID: "redo.first"),
        centre: centre
      ))
    centre.undoService.recordUndo(
      CommandInverseProxy(
        command: UndoCommand(id: "undo.second", inverseID: "redo.second"),
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
      CommandInverseProxy(
        command: UndoCommand(id: "undo.original", inverseID: "redo.original"),
        centre: centre
      ))

    try await centre.undoService.performUndo()
    #expect(centre.undoService.hasRedo)

    centre.undoService.recordUndo(
      CommandInverseProxy(command: UndoCommand(id: "undo.replacement"), centre: centre))

    #expect(centre.undoService.stackDescription == "undo.replacement")
    #expect(centre.undoService.hasUndo)
    #expect(centre.undoService.hasRedo == false)
    #expect(centre.undoService.nextUndo?.id == "undo.replacement")
  }

  /// Verifies that undoable centres record successful forward command inverses.
  @Test func undoableCentreRecordsForwardCommandInverses() async throws {
    let centre = UndoTestCentre()
    let command = UndoableTestCommand()

    try await centre.perform(command)
    #expect(centre.undoService.stackDescription == "test.undoable.inverse")
  }

  /// Verifies that inverse proxies preserve availability and execution behavior.
  @Test func commandInverseProxyForwardsAvailabilityAndExecution() async throws {
    let centre = UndoTestCentre()
    let unavailableProxy = CommandInverseProxy(
      command: UndoCommand(id: "test.proxy", reportedAvailability: .disabled), centre: centre)

    #expect(unavailableProxy.id == "test.proxy")
    #expect(unavailableProxy.availability() == .disabled)

    let executableProxy = CommandInverseProxy(
      command: UndoCommand(id: "test.proxy"), centre: centre)

    centre.undoService.recordUndo(executableProxy)
    try await centre.undoService.performUndo()
    #expect(centre.performedCommandIDs == ["test.proxy"])
  }

  /// Verifies that failed inverses remain available for a later retry.
  @Test func failedUndoPreservesTheInverse() async {
    let centre = UndoTestCentre()
    centre.undoService.recordUndo(
      CommandInverseProxy(command: FailingUndoCommand(), centre: centre))

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
      CommandInverseProxy(command: SuspendedUndoCommand(gate: gate), centre: centre))

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
      CommandInverseProxy(command: UndoCommand(id: "undo.pending"), centre: centre))

    let forwardCommand = Task {
      try await centre.perform(SuspendedForwardCommand(gate: gate))
    }
    await gate.waitUntilStarted()

    #expect(centre.undoService.forwardCommandCount == 1)
    await #expect(throws: UndoServiceError.forwardCommandInProgress) {
      try await centre.undoService.performUndo()
    }
    #expect(centre.undoService.hasUndo)

    gate.release()
    try await forwardCommand.value
    #expect(centre.undoService.forwardCommandCount == 0)

    try await centre.undoService.performUndo()
    #expect(centre.performedCommandIDs == ["undo.pending"])
  }

  /// Verifies that one undo service cannot authorize work in another service's history operation.
  @Test func executionContextIsRestrictedToItsOwningService() async throws {
    let activeCentre = UndoTestCentre()
    let activeGate = UndoGate()
    activeCentre.undoService.recordUndo(
      CommandInverseProxy(command: SuspendedUndoCommand(gate: activeGate), centre: activeCentre))

    let activeUndo = Task {
      try await activeCentre.undoService.performUndo()
    }
    await activeGate.waitUntilStarted()

    let otherCentre = UndoTestCentre()
    otherCentre.undoService.recordUndo(CrossServiceInverse(centre: activeCentre))

    await #expect(throws: CommandError.commandUnavailable) {
      try await otherCentre.undoService.performUndo()
    }
    #expect(activeCentre.performedCommandIDs.isEmpty)

    activeGate.release()
    try await activeUndo.value
  }
}
