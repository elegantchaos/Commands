// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 24/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Icons
import SwiftUI

/// Button that renders and performs a command for a concrete command centre.
@MainActor
public struct CommandButton<C: CommandWithUI, CC: CommandCentre, Content: View>: View where C.Centre == CC {
  /// Command to render and perform.
  public let command: C

  /// Centre used to evaluate and perform the command.
  public let commander: CC

  /// Optional SwiftUI button role.
  public let role: ButtonRole?

  /// Optional custom content for the button label.
  private let content: ((C) -> Content)?

  /// Current requested label visibility.
  @Environment(\.labelsVisibility) private var labelsVisibility

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
    if commander.availability(command) != .hidden {
      Button(role: role, action: { commander.performWithoutWaiting(command) }) {
        label
      }
      .disabled(commander.shouldDisable(command))
      .commandShortcut(command)
      .help(command.help(centre: commander) ?? "")
    }
  }

  /// Visible button label.
  @ViewBuilder private var label: some View {
    if let content {
      content(command)
    } else {
      defaultLabel
    }
  }

  /// Default command label.
  @ViewBuilder private var defaultLabel: some View {
    #if os(tvOS)
      if labelsVisibility == .hidden {
        Image(icon: command.icon(centre: commander))
          .accessibilityLabel(command.name(centre: commander))
      } else {
        Label(command.name(centre: commander), icon: command.icon(centre: commander))
      }
    #else
      Label(command.name(centre: commander), icon: command.icon(centre: commander))
    #endif
  }
}

public extension CommandButton where Content == EmptyView {
  /// Creates a command button with the default command label.
  init(command: C, commander: CC, role: ButtonRole? = nil) {
    self.command = command
    self.commander = commander
    self.role = role
    content = nil
  }
}
