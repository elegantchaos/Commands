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

  /// Sources used to perform inverse commands.
  var commandSources: [CommandSource] = []

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
  func perform(centre: UndoTestCentre, from source: CommandSource) async throws {
    centre.performedCommandIDs.append(id)
    centre.commandSources.append(source)
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
  func perform(centre: UndoTestCentre, from source: CommandSource) async throws {
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
  func perform(centre: UndoTestCentre, from source: CommandSource) async throws {
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
  func perform(centre: UndoTestCentre, from source: CommandSource) async throws {
    await gate.wait()
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
    #expect(centre.commandSources == [.undo])
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
    #expect(centre.commandSources == [.undo, .undo, .redo, .redo])
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

  /// Verifies that undoable centres record successful forward commands but not undo commands.
  @Test func undoableCentreRecordsOnlyForwardCommandInverses() async throws {
    let centre = UndoTestCentre()
    let command = UndoableTestCommand()

    try await centre.perform(command, from: .button)
    #expect(centre.undoService.stackDescription == "test.undoable.inverse")

    try await centre.perform(command, from: .undo)
    #expect(centre.undoService.stackDescription == "test.undoable.inverse")
  }

  /// Verifies that inverse proxies preserve availability and invocation sources.
  @Test func commandInverseProxyForwardsAvailabilityAndSource() async throws {
    let centre = UndoTestCentre()
    let unavailableProxy = CommandInverseProxy(
      command: UndoCommand(id: "test.proxy", reportedAvailability: .disabled), centre: centre)

    #expect(unavailableProxy.id == "test.proxy")
    #expect(unavailableProxy.availability() == .disabled)

    let executableProxy = CommandInverseProxy(
      command: UndoCommand(id: "test.proxy"), centre: centre)

    let replacement = try await executableProxy.action(.intent)
    #expect(replacement == nil)
    #expect(centre.performedCommandIDs == ["test.proxy"])
    #expect(centre.commandSources == [.intent])
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
    #expect(centre.undoService.operation == .undo)
    #expect(centre.undoService.hasUndo)

    gate.release()
    try await firstUndo.value
    #expect(centre.undoService.isUndoing == false)
    #expect(centre.undoService.operation == nil)
    #expect(centre.undoService.hasUndo == false)
  }
}
