// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Foundation
import Icons
import Testing

@testable import CommandsUI

/// Centre for commands that only need to describe themselves.
@MainActor
private final class ConfirmationTestCentre: CommandCentre {}

/// Command that declares a stock confirmation.
@MainActor
private struct StockConfirmationCommand: CommandWithUI {
  let id = "test.stock-confirmation"

  func name(centre: ConfirmationTestCentre) -> String { "Delete Everything" }
  func icon(centre: ConfirmationTestCentre) -> Icon { Icon("trash") }
  func help(centre: ConfirmationTestCentre) -> String? { nil }
  func perform(centre: ConfirmationTestCentre) async throws {}

  func confirmation(centre: ConfirmationTestCentre) -> CommandConfirmation? {
    defaultConfirmation(centre: centre)
  }
}

/// Tests for how a button's confirmation settings decide what pressing it does.
@MainActor
struct CommandConfirmationModeTests {
  private typealias Mode = CommandConfirmationMode

  private func outcome(
    requested: Mode? = nil, environment: Mode = .local, declares: Bool = true, hasHost: Bool = true
  ) -> CommandConfirmationOutcome {
    Mode.outcome(
      requested: requested, environment: environment, declaresConfirmation: declares,
      hasHost: hasHost)
  }

  @Test
  func aCommandWithoutAConfirmationJustRuns() {
    #expect(outcome(declares: false) == .perform)
    #expect(outcome(requested: .hosted, declares: false) == .perform)
  }

  @Test
  func localIsTheDefault() {
    #expect(outcome() == .confirmLocally)
  }

  @Test
  func hostedUsesTheHostWhenThereIsOne() {
    #expect(outcome(environment: .hosted) == .confirmWithHost)
  }

  @Test
  func hostedFallsBackToLocalWithoutAHost() {
    #expect(outcome(environment: .hosted, hasHost: false) == .confirmLocally)
  }

  @Test
  func neverSuppressesConfirmation() {
    #expect(outcome(requested: .never) == .perform)
    #expect(outcome(environment: .never) == .perform)
  }

  @Test
  func theCallSiteOverridesTheEnvironment() {
    #expect(outcome(requested: .local, environment: .hosted) == .confirmLocally)
    #expect(outcome(requested: .hosted, environment: .local) == .confirmWithHost)
    #expect(outcome(requested: .local, environment: .never) == .confirmLocally)
    #expect(outcome(requested: .never, environment: .hosted) == .perform)
  }

  @Test
  func defaultConfirmationIsTitledWithTheCommandName() {
    let confirmation = StockConfirmationCommand().defaultConfirmation(centre: ConfirmationTestCentre())

    #expect(confirmation.title == "Delete Everything")
  }

  /// Swift 6.4's build system compiles string catalogs, so the stock strings resolve in a test.
  @Test
  func defaultConfirmationStringsResolve() {
    let confirmation = StockConfirmationCommand().defaultConfirmation(centre: ConfirmationTestCentre())

    #expect(confirmation.cancel == "Cancel")
    #expect(confirmation.confirm == "Confirm")
    #expect(confirmation.message == "Are you sure you want to continue?")
  }

  /// The stock strings must exist in the catalog, or a build that compiles catalogs shows the raw
  /// key. This reads the catalog source, so it also says which key is missing when a lookup fails.
  @Test
  func defaultConfirmationStringsHaveEnglishValues() throws {
    let root = URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    let catalog = root.appending(path: "Sources/CommandsUI/Resources/Localizable.xcstrings")
    let json = try JSONSerialization.jsonObject(with: Data(contentsOf: catalog)) as? [String: Any]
    let strings = try #require(json?["strings"] as? [String: [String: Any]])

    for key in [
      "confirmation.default.cancel", "confirmation.default.confirm",
      "confirmation.default.message",
    ] {
      let localizations = strings[key]?["localizations"] as? [String: [String: Any]]
      let unit = localizations?["en"]?["stringUnit"] as? [String: Any]
      let value = unit?["value"] as? String
      #expect(value?.isEmpty == false, "\(key) has no English value")
    }
  }

  @Test
  func aCommandOptsIntoConfirmationByDeclaringIt() {
    let centre = ConfirmationTestCentre()

    #expect(StockConfirmationCommand().confirmation(centre: centre) != nil)
  }
}
