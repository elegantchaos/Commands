// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 24/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import SwiftUI

/// Button that renders and performs a command for a concrete command centre.
@MainActor
public struct CommandButton<C: CommandWithUI, CC: CommandCentre, Content: View>: View
where C.Centre == CC {
  /// Command to render and perform.
  public let command: C

  /// Centre used to evaluate and perform the command.
  public let commander: CC

  /// Optional SwiftUI button role.
  public let role: ButtonRole?

  /// Whether the button confirms first, when the command declares a confirmation.
  public let confirming: Bool

  /// Optional custom content for the button label.
  private let content: ((C) -> Content)?

  /// The presenter of the enclosing window's host.
  @Environment(\.commandPresenter) private var environmentPresenter

  /// The presenter of the focused window's host, for menu-bar commands.
  @FocusedValue(\.commandPresenter) private var focusedPresenter

  /// Creates a command button with custom label content.
  public init(
    command: C,
    commander: CC,
    role: ButtonRole? = nil,
    confirming: Bool = true,
    @ViewBuilder content: @escaping (C) -> Content
  ) {
    self.command = command
    self.commander = commander
    self.role = role
    self.confirming = confirming
    self.content = content
  }

  /// Renders the command button, or no view when the command is hidden.
  public var body: some View {
    let availability = commander.availability(command)
    if availability != .hidden {
      Button(role: role, action: handleAction) {
        label
      }
      .commandPresentation(
        availability: availability,
        help: command.help(centre: commander),
        shortcut: command.shortcut
      )
    }
  }

  /// Performs the command, after asking the host to confirm when the command declares a confirmation.
  private func handleAction() {
    guard confirming, let confirmation = command.confirmation(centre: commander) else {
      commander.performWithoutWaiting(command)
      return
    }

    guard let presenter = environmentPresenter ?? focusedPresenter else {
      commandChannel.log(
        "\(command.id) declares a confirmation but there is no CommandsHost, so it ran unconfirmed")
      commander.performWithoutWaiting(command)
      return
    }

    presenter.confirm(confirmation) { [command, commander] in
      commander.performWithoutWaiting(command)
    }
  }

  /// Visible button label.
  @ViewBuilder private var label: some View {
    if let content {
      content(command)
    } else {
      CommandLabel(command: command, centre: commander)
    }
  }
}

extension CommandButton where Content == EmptyView {
  /// Creates a command button with the default command label.
  public init(command: C, commander: CC, role: ButtonRole? = nil, confirming: Bool = true) {
    self.command = command
    self.commander = commander
    self.role = role
    self.confirming = confirming
    content = nil
  }
}
