// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import SwiftUI

/// Displays ordinary command buttons with a concise explanation of each one.
struct ExampleCommandsPanel: View {
  /// Shared command centre that supplies the buttons.
  let commander: ExampleCommander

  var body: some View {
    GroupBox {
      VStack(alignment: .leading) {
        Text("example.panel.commands.hint")
          .font(.footnote)
          .foregroundStyle(.secondary)

        ExampleCommandRow(
          command: AddCompletedItemCommand(),
          commander: commander,
          hint: "example.command.add.help",
          style: .prominent
        )
        ExampleCommandRow(
          command: RemoveCompletedItemCommand(),
          commander: commander,
          hint: "example.command.remove.help"
        )
        ExampleCommandRow(
          command: ClearCompletedItemsCommand(),
          commander: commander,
          hint: "example.command.clear.help",
          role: .destructive,
          requiresConfirmation: true
        )
        ExampleImporterCommandRow(commander: commander)
        ExampleCommandRow(
          command: ToggleAdvancedCommandsCommand(),
          commander: commander,
          hint: "example.command.toggleAdvanced.help"
        )
        ExampleCommandRow(
          command: ReviewCompletedItemsCommand(),
          commander: commander,
          hint: "example.command.review.help"
        )
      }
    } label: {
      Label("example.section.buttons", systemImage: "command")
    }
  }
}

/// Button styling options for ordinary example command rows.
private enum ExampleCommandButtonStyle {
  /// Uses the platform's regular bordered style.
  case regular

  /// Uses the platform's prominent bordered style.
  case prominent
}

/// Renders one command button and its explanatory hint when it is not hidden.
private struct ExampleCommandRow<Command: CommandWithUI>: View
where Command.Centre == ExampleCommander {
  /// Command represented by the row.
  let command: Command

  /// Command centre that resolves metadata and availability.
  let commander: ExampleCommander

  /// Explanation displayed below the command button.
  let hint: LocalizedStringKey

  /// Optional semantic role for the command button.
  let role: ButtonRole?

  /// Whether the row should use the confirmation-aware command control.
  let requiresConfirmation: Bool

  /// Requested presentation emphasis for the button.
  let style: ExampleCommandButtonStyle

  /// Creates a row with the regular button style and no confirmation requirement.
  init(
    command: Command,
    commander: ExampleCommander,
    hint: LocalizedStringKey,
    role: ButtonRole? = nil,
    requiresConfirmation: Bool = false,
    style: ExampleCommandButtonStyle = .regular
  ) {
    self.command = command
    self.commander = commander
    self.hint = hint
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

        Text(hint)
          .font(.footnote)
          .foregroundStyle(.secondary)
          .padding(.bottom)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

/// Renders the importer command with its icon and explanatory hint.
private struct ExampleImporterCommandRow: View {
  /// Shared command centre that presents and executes imports.
  let commander: ExampleCommander

  var body: some View {
    VStack(alignment: .leading) {
      commander.importer(ImportExampleFilesCommand())
        .buttonStyle(.bordered)

      Text("example.command.import.help")
        .font(.footnote)
        .foregroundStyle(.secondary)
        .padding(.bottom)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}
