// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 24/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import SwiftUI

/// Button that renders and performs a command for a concrete command centre.
@MainActor
public struct CommandButton<C: CommandWithUI, Centre: CommandCentre, Content: View>: View
where C.Centre == Centre {
  /// Command to render and perform.
  public let command: C

  /// Centre used to evaluate and perform the command.
  public let centre: Centre

  /// Optional SwiftUI button role.
  public let role: ButtonRole?

  /// Where the button presents the command's confirmation, or nil to use the environment's.
  public let confirmation: CommandConfirmationMode?

  /// Optional custom content for the button label.
  private let content: ((C) -> Content)?

  /// Confirms before performing, when the command declares a confirmation.
  private let confirmationState = CommandConfirmationState()

  /// Creates a command button with custom label content.
  public init(
    command: C,
    centre: Centre,
    role: ButtonRole? = nil,
    confirmation: CommandConfirmationMode? = nil,
    @ViewBuilder content: @escaping (C) -> Content
  ) {
    self.command = command
    self.centre = centre
    self.role = role
    self.confirmation = confirmation
    self.content = content
  }

  /// Renders the command button, or no view when the command is hidden.
  public var body: some View {
    let availability = centre.availability(command)
    if availability != .hidden {
      Button(role: role, action: handleAction) {
        label
      }
      .commandLocalConfirmation(confirmationState)
      .commandPresentation(
        availability: availability,
        help: command.help(centre: centre),
        shortcut: command.shortcut
      )
    }
  }

  /// Performs the command, confirming first when the command declares a confirmation.
  private func handleAction() {
    confirmationState.request(
      command.confirmation(centre: centre), mode: confirmation
    ) { [command, centre] in
      centre.performWithoutWaiting(command)
    }
  }

  /// Visible button label.
  @ViewBuilder private var label: some View {
    if let content {
      content(command)
    } else {
      CommandLabel(command: command, centre: centre)
    }
  }
}

extension CommandButton where Content == EmptyView {
  /// Creates a command button with the default command label.
  public init(
    command: C, centre: Centre, role: ButtonRole? = nil,
    confirmation: CommandConfirmationMode? = nil
  ) {
    self.command = command
    self.centre = centre
    self.role = role
    self.confirmation = confirmation
    content = nil
  }
}
