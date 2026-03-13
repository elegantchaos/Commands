// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 21/01/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Foundation
import Testing

/// Concrete command centre used to observe lifecycle hooks in tests.
@MainActor
private final class TestCentre: CommandCentre {
  /// Whether the simple command was executed.
  var testRan = false

  /// Whether the protocol-backed command was executed.
  var didTheThing = false

  /// Ordered list of command IDs passed to `recordStartedCommand`.
  var startedCommandIDs: [String] = []

  /// Ordered list of command IDs passed to `recordFinishedCommand`.
  var finishedCommandIDs: [String] = []

  /// Command IDs that should currently report as running.
  var runningCommandIDs: Set<String> = []

  /// Records when a command starts.
  func recordStartedCommand<C: Command>(_ command: C) where C.Centre == TestCentre {
    startedCommandIDs.append(command.id)
  }

  /// Records when a command finishes.
  func recordFinishedCommand<C: Command>(_ command: C) where C.Centre == TestCentre {
    finishedCommandIDs.append(command.id)
  }

  /// Returns whether a command should report as running.
  func isRunning<C: Command>(_ command: C) -> Bool where C.Centre == TestCentre {
    runningCommandIDs.contains(command.id)
  }
}

/// Simple command with configurable availability and result handling.
@MainActor
private struct TestCommand: Command {
  /// Stable identifier used by assertions.
  let id: String

  /// Availability to report to the command centre.
  let reportedAvailability: CommandAvailability

  /// Value returned when the command succeeds.
  let result: String

  /// Creates a test command with predictable behaviour.
  init(
    id: String = "test.command",
    reportingAvailabilityAs reportedAvailability: CommandAvailability = .enabled,
    result: String = "performed"
  ) {
    self.id = id
    self.reportedAvailability = reportedAvailability
    self.result = result
  }

  /// Returns the configured availability.
  func availability(centre: TestCentre) -> CommandAvailability {
    reportedAvailability
  }

  /// Marks the centre as executed and returns the configured result.
  func perform(centre: TestCentre) async throws -> String {
    centre.testRan = true
    return result
  }
}

/// Command that relies on the protocol default availability implementation.
@MainActor
private struct DefaultAvailabilityCommand: Command {
  /// Stable identifier used by assertions.
  let id = "test.default-availability"

  /// Performs no work and returns a constant value.
  func perform(centre: TestCentre) async throws -> String {
    "default"
  }
}

/// Error used by failing command tests.
private enum TestFailure: Error, Equatable {
  case expected
}

/// Command that always throws after recording that it ran.
@MainActor
private struct FailingCommand: Command {
  /// Stable identifier used by assertions.
  let id = "test.failing"

  /// Marks the centre as executed, then throws.
  func perform(centre: TestCentre) async throws -> String {
    centre.testRan = true
    throw TestFailure.expected
  }
}

/// Waits for asynchronous detached command execution to complete.
@MainActor
private func waitUntil(
  timeoutIterations: Int = 50,
  _ condition: @MainActor () -> Bool
) async {
  for _ in 0..<timeoutIterations where condition() == false {
    await Task.yield()
  }
}

/// Verifies that a command returns its result and records lifecycle hooks.
@Test func testSimpleCommand() async throws {
  let centre = TestCentre()
  let command = TestCommand()
  #expect(centre.availability(command) == .enabled)
  #expect(centre.testRan == false)
  #expect(centre.startedCommandIDs.isEmpty)
  #expect(centre.finishedCommandIDs.isEmpty)

  let result = try await centre.perform(command)

  #expect(result == "performed")
  #expect(centre.testRan == true)
  #expect(centre.startedCommandIDs == [command.id])
  #expect(centre.finishedCommandIDs == [command.id])
}

/// Verifies that unavailable commands throw before lifecycle hooks fire.
@Test func testHiddenCommand() async throws {
  let centre = TestCentre()
  let command = TestCommand(reportingAvailabilityAs: .hidden)

  #expect(centre.availability(command) == .hidden)

  await #expect(throws: CommandError.commandUnavaiable) {
    try await centre.perform(command)
  }

  #expect(centre.testRan == false)
  #expect(centre.startedCommandIDs.isEmpty)
  #expect(centre.finishedCommandIDs.isEmpty)
}

/// Verifies that thrown command errors still trigger `recordFinishedCommand`.
@Test func testFailingCommandRecordsFinish() async throws {
  let centre = TestCentre()
  let command = FailingCommand()

  await #expect(throws: TestFailure.expected) {
    try await centre.perform(command)
  }

  #expect(centre.testRan == true)
  #expect(centre.startedCommandIDs == [command.id])
  #expect(centre.finishedCommandIDs == [command.id])
}

/// Verifies that the default command availability is `.enabled`.
@Test func testDefaultAvailabilityImplementation() async throws {
  let centre = TestCentre()
  let command = DefaultAvailabilityCommand()

  #expect(command.availability(centre: centre) == .enabled)
  #expect(centre.availability(command) == .enabled)
}

/// Verifies that non-hidden running commands are surfaced as `.running`.
@Test(arguments: [CommandAvailability.enabled, .disabled, .running, .runningSilently])
func testAvailabilityMapsRunningStates(_ baseAvailability: CommandAvailability) async throws {
  let centre = TestCentre()
  let command = TestCommand(id: "test.running.\(baseAvailability)", reportingAvailabilityAs: baseAvailability)
  centre.runningCommandIDs.insert(command.id)

  #expect(centre.availability(command) == .running)
}

/// Verifies that hidden running commands are surfaced as `.runningSilently`.
@Test func testAvailabilityMapsHiddenRunningState() async throws {
  let centre = TestCentre()
  let command = TestCommand(id: "test.hidden-running", reportingAvailabilityAs: .hidden)
  centre.runningCommandIDs.insert(command.id)

  #expect(centre.availability(command) == .runningSilently)
}

/// Verifies that fire-and-forget execution still runs the command and lifecycle hooks.
@Test func testPerformWithoutWaitingRunsCommand() async throws {
  let centre = TestCentre()
  let command = TestCommand(id: "test.background")

  centre.performWithoutWaiting(command)
  await waitUntil {
    centre.finishedCommandIDs.contains(command.id)
  }

  #expect(centre.testRan == true)
  #expect(centre.startedCommandIDs == [command.id])
  #expect(centre.finishedCommandIDs == [command.id])
}

/// Verifies that a protocol-constrained command can execute against a conforming centre.
@Test func testProtocolCommand() async throws {
  let centre = TestCentre()

  #expect(centre.didTheThing == false)
  try await centre.perform(ProtocolCommand())
  #expect(centre.didTheThing == true)
}

/// Conforms the test centre to the support protocol used by `ProtocolCommand`.
extension TestCentre: TestProtocol {
  /// Records that the protocol-backed command performed its work.
  func doTheThing() {
    didTheThing = true
  }
}
