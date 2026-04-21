// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 21/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Foundation
import Icons
import Testing
@testable import CommandsUI

/// Test command centre used to exercise `CommandsUI` helper behavior without rendering views.
@MainActor
private final class UITestCentre: CommandCentre {
  /// Command identifiers currently considered to be running.
  var runningCommandIDs: Set<String> = []

  /// Returns whether the supplied command is marked as running.
  func isRunning<C: Command>(_ command: C) -> Bool where C.Centre == UITestCentre {
    runningCommandIDs.contains(command.id)
  }
}

/// Minimal UI command used to exercise default `CommandWithUI` behavior.
@MainActor
private struct DefaultUICommand: CommandWithUI {
  /// Stable identifier used for localization lookups.
  let id = "confirmation.default.cancel"

  /// Returns a fixed icon for metadata assertions.
  func icon(centre: UITestCentre) -> Icon {
    Icon("square.and.pencil")
  }

  /// Performs no work.
  func perform(centre: UITestCentre) async throws {
  }
}

/// Configurable UI command used to verify `shouldDisable` mapping.
@MainActor
private struct AvailabilityUICommand: CommandWithUI {
  /// Stable identifier used by assertions.
  let id = "test.ui.availability"

  /// Availability reported to the command centre.
  let reportedAvailability: CommandAvailability

  /// Returns the configured availability.
  func availability(centre: UITestCentre) -> CommandAvailability {
    reportedAvailability
  }

  /// Returns a fixed icon for metadata assertions.
  func icon(centre: UITestCentre) -> Icon {
    Icon("square.and.pencil")
  }

  /// Performs no work.
  func perform(centre: UITestCentre) async throws {
  }
}

/// UI command with non-default metadata used to verify `WrappedCommand` forwarding.
@MainActor
private struct MetadataCommand: CommandWithUI {
  /// Stable identifier used by assertions.
  let id = "test.ui.metadata"

  /// Availability reported to the command centre.
  let reportedAvailability: CommandAvailability

  /// Result returned from `perform(centre:)`.
  let result: String

  /// Returns the configured availability.
  func availability(centre: UITestCentre) -> CommandAvailability {
    reportedAvailability
  }

  /// Returns a fixed icon for metadata assertions.
  func icon(centre: UITestCentre) -> Icon {
    Icon("network")
  }

  /// Returns a centre-aware display name.
  func name(centre: UITestCentre) -> String {
    "Metadata Command"
  }

  /// Returns a centre-aware help string.
  func help(centre: UITestCentre) -> String? {
    "Helpful metadata"
  }

  /// Returns an explicit confirmation model.
  func confirmation(centre: UITestCentre) -> CommandConfirmation? {
    .init(
      title: "Confirm Metadata",
      cancel: "Cancel",
      message: "Proceed with metadata command?",
      confirm: "Proceed"
    )
  }

  /// Returns no shortcut so forwarding stays explicit.
  var shortcut: CommandShortcut? { nil }

  /// Uses Foundation's bundle to make forwarding assertions deterministic.
  var bundle: Bundle { Bundle(for: MetadataBundleToken.self) }

  /// Returns the configured result.
  func perform(centre: UITestCentre) async throws -> String {
    result
  }
}

/// Wrapped command variant that overrides one metadata hook while inheriting the rest.
@MainActor
private final class OverridingWrappedCommand: WrappedCommand<MetadataCommand> {
  /// Returns a replacement display name to prove override behavior.
  override func name(centre: UITestCentre) -> String {
    "Wrapped Metadata Command"
  }
}

/// Bundle token used to provide a deterministic non-main bundle for forwarding tests.
private final class MetadataBundleToken {
}

/// Tests for non-view `CommandsUI` helpers and models.
@MainActor
struct CommandsUITests {
  /// Ensures the public trigger ordering remains stable for UI resolution logic.
  @Test func commandTriggerOrderingRemainsStable() {
    #expect(CommandTrigger.allCases == [.primary, .secondary, .tertiary])
    #expect(CommandTrigger.primary.rawValue == "primary")
    #expect(CommandTrigger.secondary.rawValue == "secondary")
    #expect(CommandTrigger.tertiary.rawValue == "tertiary")
  }

  /// Verifies that the `CommandWithUI` defaults remain stable for commands that only supply an icon.
  @Test func commandWithUIDefaultsRemainStable() {
    let centre = UITestCentre()
    let command = DefaultUICommand()

    #expect(command.name(centre: centre) == "confirmation.default.cancel")
    #expect(command.help(centre: centre) == "confirmation.default.cancel.help")
    #expect(command.confirmation(centre: centre) == nil)
    #expect(command.shortcut == nil)
    #expect(command.bundle == .main)
    #expect(command.icon(centre: centre).systemImage == "square.and.pencil")
  }

  /// Verifies that `shouldDisable` only disables commands that are unavailable or already running.
  @Test(arguments: [
    (CommandAvailability.enabled, false),
    (CommandAvailability.disabled, true),
    (CommandAvailability.hidden, false),
    (CommandAvailability.running, true),
    (CommandAvailability.runningSilently, true),
  ])
  func shouldDisableMatchesAvailability(
    availabilityAndExpectation: (availability: CommandAvailability, expected: Bool)
  ) {
    let centre = UITestCentre()
    let command = AvailabilityUICommand(reportedAvailability: availabilityAndExpectation.availability)

    #expect(centre.shouldDisable(command) == availabilityAndExpectation.expected)
  }

  /// Verifies that a running command is disabled even if its base availability is enabled.
  @Test func shouldDisableUsesRunningStateFromCentre() {
    let centre = UITestCentre()
    let command = AvailabilityUICommand(reportedAvailability: .enabled)
    centre.runningCommandIDs.insert(command.id)

    #expect(centre.availability(command) == .running)
    #expect(centre.shouldDisable(command) == true)
  }

  /// Verifies that `WrappedCommand` forwards all metadata, availability, and execution by default.
  @Test func wrappedCommandForwardsWrappedBehavior() async throws {
    let centre = UITestCentre()
    let wrapped = WrappedCommand(MetadataCommand(reportedAvailability: .disabled, result: "forwarded"))

    #expect(wrapped.id == "test.ui.metadata")
    #expect(wrapped.icon(centre: centre).systemImage == "network")
    #expect(wrapped.name(centre: centre) == "Metadata Command")
    #expect(wrapped.help(centre: centre) == "Helpful metadata")
    #expect(wrapped.confirmation(centre: centre)?.title == "Confirm Metadata")
    #expect(wrapped.bundle == Bundle(for: MetadataBundleToken.self))
    #expect(wrapped.shortcut == nil)
    #expect(wrapped.availability(centre: centre) == .disabled)

    let result = try await wrapped.perform(centre: centre)
    #expect(result == "forwarded")
  }

  /// Verifies that `WrappedCommand` subclasses can override selected metadata while inheriting the rest.
  @Test func wrappedCommandAllowsSelectiveOverrides() {
    let centre = UITestCentre()
    let wrapped = OverridingWrappedCommand(MetadataCommand(reportedAvailability: .enabled, result: "ignored"))

    #expect(wrapped.name(centre: centre) == "Wrapped Metadata Command")
    #expect(wrapped.help(centre: centre) == "Helpful metadata")
    #expect(wrapped.icon(centre: centre).systemImage == "network")
    #expect(wrapped.confirmation(centre: centre)?.confirm == "Proceed")
  }
}
