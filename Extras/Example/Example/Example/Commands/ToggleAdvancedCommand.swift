// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CommandsUI
import Icons
import SwiftUI

/// Demonstrates command metadata that changes its icon, label, and hint text with state.
struct ToggleAdvancedCommand<Centre: ItemServiceProvider>: CommandWithUI {
  /// Stable identifier for this command.
  let id = "example.command.toggleAdvanced"

  /// Keyboard shortcut for changing advanced-command visibility.
  var shortcut: CommandShortcut? {
    CommandShortcut("e", modifiers: [.command, .shift])
  }

  /// Returns the action label appropriate for the current advanced-command visibility.
  func name(centre: Centre) -> String {
    String(
      localized: centre.itemService.showsAdvancedCommands
        ? "example.command.hideAdvanced"
        : "example.command.showAdvanced"
    )
  }

  func icon(centre: Centre) -> Icons.Icon {
    Icon(centre.itemService.showsAdvancedCommands ? "eye.slash" : "eye")
  }

  /// Returns the hint text appropriate for the current advanced-command visibility.
  func help(centre: Centre) -> String? {
    String(
      localized: centre.itemService.showsAdvancedCommands
        ? "example.command.hideAdvanced.help"
        : "example.command.showAdvanced.help"
    )
  }

  func perform(centre: Centre) async throws {
    centre.itemService.showsAdvancedCommands.toggle()
  }
}
