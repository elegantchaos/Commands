// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Testing

@testable import CommandsUI

/// Tests for the confirmation state shared between command buttons and a `CommandsHost`.
@MainActor
struct CommandPresenterTests {
  /// Confirmation used by every request.
  private let confirmation = CommandConfirmation(
    title: "Delete?", cancel: "Cancel", message: "This cannot be undone.", confirm: "Delete")

  /// Requesting a confirmation shows it without performing the action.
  @Test
  func requestingConfirmationDoesNotPerformTheAction() {
    let presenter = CommandPresenter()
    var performed = 0

    presenter.confirm(confirmation) { performed += 1 }

    #expect(presenter.pendingConfirmation?.confirmation.title == "Delete?")
    #expect(performed == 0)
  }

  /// Accepting performs the action once and clears the request.
  @Test
  func acceptingPerformsTheActionOnceAndClearsTheRequest() throws {
    let presenter = CommandPresenter()
    var performed = 0
    presenter.confirm(confirmation) { performed += 1 }
    let request = try #require(presenter.pendingConfirmation)

    presenter.accept(request)
    presenter.accept(request)

    #expect(performed == 1)
    #expect(presenter.pendingConfirmation == nil)
  }

  /// Cancelling clears the request without performing the action.
  @Test
  func cancellingClearsTheRequestWithoutPerformingTheAction() throws {
    let presenter = CommandPresenter()
    var performed = 0
    presenter.confirm(confirmation) { performed += 1 }
    let request = try #require(presenter.pendingConfirmation)

    presenter.cancel(request)
    presenter.accept(request)

    #expect(performed == 0)
    #expect(presenter.pendingConfirmation == nil)
  }

  /// A request made while another is shown is refused, so accepting the shown one performs only
  /// its own action.
  @Test
  func aRequestWhileOneIsShownIsRefused() throws {
    let presenter = CommandPresenter()
    var performed: [String] = []
    presenter.confirm(confirmation) { performed.append("first") }
    let shown = try #require(presenter.pendingConfirmation)

    presenter.confirm(confirmation) { performed.append("second") }
    #expect(presenter.pendingConfirmation?.id == shown.id)

    presenter.accept(shown)
    #expect(performed == ["first"])
    #expect(presenter.pendingConfirmation == nil)
  }

  /// Accepting or cancelling a request that is no longer shown leaves the current one alone.
  @Test
  func actingOnAnEarlierRequestDoesNotAffectTheCurrentOne() throws {
    let presenter = CommandPresenter()
    var performed: [String] = []
    presenter.confirm(confirmation) { performed.append("first") }
    let first = try #require(presenter.pendingConfirmation)
    presenter.cancel(first)
    presenter.confirm(confirmation) { performed.append("second") }
    let second = try #require(presenter.pendingConfirmation)

    presenter.accept(first)
    presenter.cancel(first)

    #expect(performed.isEmpty)
    #expect(presenter.pendingConfirmation?.id == second.id)
  }
}
