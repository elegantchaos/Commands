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

  @Test
  func defaultConfirmationUsesLocalizedStrings() {
    let confirmation = StockConfirmationCommand().defaultConfirmation(centre: ConfirmationTestCentre())

    #expect(confirmation.cancel != "confirmation.default.cancel")
    #expect(confirmation.confirm != "confirmation.default.confirm")
    #expect(confirmation.message != "confirmation.default.message")
    #expect(!confirmation.cancel.isEmpty && !confirmation.confirm.isEmpty)
  }

  @Test
  func aCommandOptsIntoConfirmationByDeclaringIt() {
    let centre = ConfirmationTestCentre()

    #expect(StockConfirmationCommand().confirmation(centre: centre) != nil)
  }
}
