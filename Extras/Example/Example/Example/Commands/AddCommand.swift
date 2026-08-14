// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import Icons
import SwiftUI

/// Adds a completed item until the example reaches its configured limit.
struct AddCommand<Centre: ItemServiceProvider>: CommandWithUI {
  /// Stable identifier for this command.
  let id = "example.command.add"

  /// Keyboard shortcut for adding a completed item.
  var shortcut: CommandShortcut? {
    CommandShortcut("a", modifiers: [.command, .shift])
  }

  func icon(centre: Centre) -> Icons.Icon {
    Icon("plus")
  }

  func availability(centre: Centre) -> CommandAvailability {
    centre.itemService.completedItems < centre.itemService.maximumCompletedItems
      ? .enabled : .disabled
  }

  func perform(centre: Centre) async throws {
    centre.itemService.addCompletedItem()
  }

  func reversal(centre: Centre) -> (any CommandReversal)? {
    CommandReversalAdapterWithUI(command: RemoveCommand(), centre: centre)
  }
}
