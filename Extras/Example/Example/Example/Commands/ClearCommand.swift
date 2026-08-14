// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import Icons
import SwiftUI

/// Clears completed items after explicit confirmation.
struct ClearCommand<Centre: ItemServiceProvider>: CommandWithUI {
  /// Stable identifier for this command.
  let id = "example.command.clear"

  /// Keyboard shortcut for clearing completed items.
  var shortcut: CommandShortcut? {
    CommandShortcut("x", modifiers: [.command, .shift])
  }

  func icon(centre: Centre) -> Icons.Icon {
    Icon("trash")
  }

  func availability(centre: Centre) -> CommandAvailability {
    centre.itemService.completedItems > 0 ? .enabled : .disabled
  }

  func confirmation(centre: Centre) -> CommandConfirmation? {
    CommandConfirmation(
      titleKey: "example.clear.confirmation.title",
      cancelKey: "example.clear.confirmation.cancel",
      messageKey: "example.clear.confirmation.message",
      confirmKey: "example.clear.confirmation.confirm"
    )
  }

  func perform(centre: Centre) async throws {
    centre.itemService.removeAllCompletedItems()
  }
}
