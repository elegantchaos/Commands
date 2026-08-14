// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import SwiftUI

/// Displays ordinary command buttons with a concise explanation of each one.
struct CommandsPanel: View {
  /// Shared command centre that supplies the buttons.
  let commander: Commander

  var body: some View {
    GroupBox {
      VStack(alignment: .leading) {
        Text("example.panel.commands.hint")
          .font(.footnote)
          .foregroundStyle(.secondary)

        CommandRow(
          command: AddCommand(),
          commander: commander,
          style: .prominent
        )
        CommandRow(
          command: RemoveCommand(),
          commander: commander
        )
        CommandRow(
          command: ClearCommand(),
          commander: commander,
          role: .destructive,
          requiresConfirmation: true
        )
        ImporterCommandRow(commander: commander)
        CommandRow(
          command: ToggleAdvancedCommand(),
          commander: commander
        )
        CommandRow(
          command: ReviewCommand(),
          commander: commander
        )
      }
    } label: {
      Label("example.section.buttons", systemImage: "command")
    }
  }
}

/// Button styling options for ordinary example command rows.
private enum CommandButtonStyle {
  /// Uses the platform's regular bordered style.
  case regular

  /// Uses the platform's prominent bordered style.
  case prominent
}

/// Renders one command button and its explanatory hint when it is not hidden.
private struct CommandRow<Command: CommandWithUI>: View
where Command.Centre == Commander {
  /// Command represented by the row.
  let command: Command

  /// Command centre that resolves metadata and availability.
  let commander: Commander

  /// Optional semantic role for the command button.
  let role: ButtonRole?

  /// Whether the row should use the confirmation-aware command control.
  let requiresConfirmation: Bool

  /// Requested presentation emphasis for the button.
  let style: CommandButtonStyle

  /// Creates a row with the regular button style and no confirmation requirement.
  init(
    command: Command,
    commander: Commander,
    role: ButtonRole? = nil,
    requiresConfirmation: Bool = false,
    style: CommandButtonStyle = .regular
  ) {
    self.command = command
    self.commander = commander
    self.role = role
    self.requiresConfirmation = requiresConfirmation
    self.style = style
  }

  var body: some View {
    if commander.availability(command) != .hidden {
      VStack(alignment: .leading) {
        if requiresConfirmation {
          switch style {
          case .regular:
            commander.confirmableButton(command, role: role)
              .buttonStyle(.bordered)
          case .prominent:
            commander.confirmableButton(command, role: role)
              .buttonStyle(.borderedProminent)
          }
        } else {
          switch style {
          case .regular:
            commander.button(command, role: role)
              .buttonStyle(.bordered)
          case .prominent:
            commander.button(command, role: role)
              .buttonStyle(.borderedProminent)
          }
        }

        if let help = command.help(centre: commander) {
          Text(help)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.bottom)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

/// Renders the importer command with its icon and explanatory hint.
private struct ImporterCommandRow: View {
  /// Shared command centre that presents and executes imports.
  let commander: Commander

  var body: some View {
    let command = ImportCommand<Commander>()

    VStack(alignment: .leading) {
      commander.importer(command)
        .buttonStyle(.bordered)

      if let help = command.help(centre: commander) {
        Text(help)
          .font(.footnote)
          .foregroundStyle(.secondary)
          .padding(.bottom)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}
