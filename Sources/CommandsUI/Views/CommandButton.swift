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

  /// Optional custom content for the button label.
  private let content: ((C) -> Content)?

  /// Creates a command button with custom label content.
  public init(
    command: C,
    commander: CC,
    role: ButtonRole? = nil,
    @ViewBuilder content: @escaping (C) -> Content
  ) {
    self.command = command
    self.commander = commander
    self.role = role
    self.content = content
  }

  /// Renders the command button, or no view when the command is hidden.
  public var body: some View {
    let availability = commander.availability(command)
    if availability != .hidden {
      Button(role: role, action: { commander.performWithoutWaiting(command, from: .button) }) {
        label
      }
      .commandPresentation(
        availability: availability,
        help: command.help(centre: commander),
        shortcut: command.shortcut
      )
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
  public init(command: C, commander: CC, role: ButtonRole? = nil) {
    self.command = command
    self.commander = commander
    self.role = role
    content = nil
  }
}
