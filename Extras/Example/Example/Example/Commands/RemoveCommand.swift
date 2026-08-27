// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import Icons
import SwiftUI

/// Removes a completed item when one exists.
struct RemoveCommand<Centre: ItemServiceProvider>: CommandWithUI {
  /// Stable identifier for this command.
  let id = "example.command.remove"

  /// Keyboard shortcut for removing a completed item.
  var shortcut: CommandShortcut? {
    CommandShortcut("r", modifiers: [.command, .shift])
  }

  func icon(centre: Centre) -> Icons.Icon {
    Icon("minus")
  }

  func availability(centre: Centre) -> CommandAvailability {
    centre.itemService.completedItems > 0 ? .enabled : .disabled
  }

  func perform(centre: Centre) async throws {
    centre.itemService.removeCompletedItem()
  }

  func reversal(centre: Centre) -> (any CommandReversal)? {
    CommandReversalAdapterWithUI(
      command: AddCommand(),
      centre: centre,
      historyActionName: name(centre: centre)
    )
  }
}
