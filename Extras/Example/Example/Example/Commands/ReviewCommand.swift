// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import Icons
import SwiftUI

/// Demonstrates a command that is hidden until a separate command enables it.
struct ReviewCommand<Centre: ItemServiceProvider>: CommandWithUI {
  /// Stable identifier for this command.
  let id = "example.command.review"

  /// Keyboard shortcut for reviewing completed items.
  var shortcut: CommandShortcut? {
    CommandShortcut("v", modifiers: [.command, .shift])
  }

  func icon(centre: Centre) -> Icons.Icon {
    Icon("checkmark.seal")
  }

  func availability(centre: Centre) -> CommandAvailability {
    guard centre.itemService.showsAdvancedCommands else { return .hidden }
    return centre.itemService.completedItems > 0 ? .enabled : .disabled
  }

  func perform(centre: Centre) async throws {
    centre.itemService.reviewCompletedItems()
  }
}
