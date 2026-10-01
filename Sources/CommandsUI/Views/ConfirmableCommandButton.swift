// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/09/2025.
//  Copyright © 2025 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import SwiftUI

/// Button wrapper that confirms with the user before invoking a command.
///
/// Inside a `CommandsHost`, the button asks the host to show the confirmation, which works in
/// menus. Without a host it falls back to an alert attached to the button itself, which does not
/// survive inside a menu.
@MainActor
struct ConfirmableCommandButton<C: CommandWithUI, CC: CommandCentre>: View where C.Centre == CC {
  /// Tracks whether the fallback alert is currently visible.
  @State var isPresented = false

  /// The presenter of the enclosing window's host.
  @Environment(\.commandPresenter) private var environmentPresenter

  /// The presenter of the focused window's host, for menu-bar commands.
  @FocusedValue(\.commandPresenter) private var focusedPresenter

  /// Command to present and eventually execute.
  let command: C

  /// Command centre that performs the command after confirmation.
  let commander: CC

  /// Role of the button
  let role: ButtonRole?

  /// Create the button.
  init(command: C, commander: CC, role: ButtonRole? = nil) {
    self.command = command
    self.commander = commander
    self.role = role
  }

  /// Renders the labelled button and its fallback alert.
  var body: some View {
    let availability = commander.availability(command)

    if availability != .hidden {
      Button(role: role, action: handleShowAlert) {
        CommandLabel(command: command, centre: commander)
      }
      .commandPresentation(
        availability: availability,
        help: command.help(centre: commander),
        shortcut: command.shortcut
      )
      .alert(confirmation.title, isPresented: $isPresented) {
        Button(confirmation.cancel, role: .cancel) {}
        Button(confirmation.confirm, role: .destructive) { handlePerformCommand() }
      } message: {
        Text(confirmation.message)
      }
    }
  }

  /// The dialog to show, defaulting to a generic one for commands that declare none.
  private var confirmation: CommandConfirmation {
    command.confirmation(centre: commander)
      ?? .init(
        title: command.name(centre: commander),
        cancel: String(localized: "confirmation.default.cancel"),
        message: String(localized: "confirmation.default.message"),
        confirm: String(localized: "confirmation.default.confirm")
      )
  }

  /// Asks the host to confirm, or shows the fallback alert when there is no host.
  func handleShowAlert() {
    if let presenter = environmentPresenter ?? focusedPresenter {
      presenter.confirm(confirmation) { [command, commander] in
        commander.performWithoutWaiting(command)
      }
      return
    }

    commandChannel.debug("no CommandsHost for \(command.id): confirming with a local alert")
    withAnimation {
      isPresented = true
    }
  }

  /// Executes the command confirmed in the fallback alert.
  func handlePerformCommand() {
    commander.performWithoutWaiting(command)
    withAnimation {
      isPresented = false
    }
  }
}
