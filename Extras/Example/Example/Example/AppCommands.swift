// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CommandsUI
import SwiftUI

/// Adds example commands to the platform command menus.
struct AppCommands: Commands {
  /// Shared command centre used to resolve command state.
  let commander: Commander

  var body: some Commands {
    CommandGroup(after: .newItem) {
      commander.importer(ImportCommand())
    }

    CommandMenu("example.menu.title") {
      commander.button(AddCommand())
      commander.button(RemoveCommand())
      commander.confirmableButton(ClearCommand(), role: .destructive)

      Divider()

      commander.button(ToggleAdvancedCommand())
      commander.button(ReviewCommand())
    }
  }
}
