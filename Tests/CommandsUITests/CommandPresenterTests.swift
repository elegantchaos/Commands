// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Testing

@testable import CommandsUI

/// Tests for the confirmation state shared between command buttons and a `CommandsHost`.
@MainActor
struct CommandPresenterTests {
  private let confirmation = CommandConfirmation(
    title: "Delete?", cancel: "Cancel", message: "This cannot be undone.", confirm: "Delete")

  @Test
  func requestingConfirmationDoesNotPerformTheAction() {
    let presenter = CommandPresenter()
    var performed = 0

    presenter.confirm(confirmation) { performed += 1 }

    #expect(presenter.pendingConfirmation?.confirmation.title == "Delete?")
    #expect(performed == 0)
  }

  @Test
  func acceptingPerformsTheActionOnceAndClearsTheRequest() {
    let presenter = CommandPresenter()
    var performed = 0
    presenter.confirm(confirmation) { performed += 1 }

    presenter.accept()
    presenter.accept()

    #expect(performed == 1)
    #expect(presenter.pendingConfirmation == nil)
  }

  @Test
  func cancellingClearsTheRequestWithoutPerformingTheAction() {
    let presenter = CommandPresenter()
    var performed = 0
    presenter.confirm(confirmation) { performed += 1 }

    presenter.cancel()
    presenter.accept()

    #expect(performed == 0)
    #expect(presenter.pendingConfirmation == nil)
  }

  @Test
  func aNewRequestReplacesAPendingOne() {
    let presenter = CommandPresenter()
    var performed: [String] = []
    presenter.confirm(confirmation) { performed.append("first") }
    presenter.confirm(confirmation) { performed.append("second") }

    presenter.accept()

    #expect(performed == ["second"])
  }
}
