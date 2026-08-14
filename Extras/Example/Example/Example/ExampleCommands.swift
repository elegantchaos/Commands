// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CommandsUI
import SwiftUI

/// Adds example commands to the platform command menus.
struct ExampleCommands: Commands {
  /// Shared command centre used to resolve command state.
  let commander: ExampleCommander

  var body: some Commands {
    CommandGroup(after: .newItem) {
      commander.importer(ImportExampleFilesCommand())
    }

    CommandMenu("example.menu.title") {
      commander.button(AddCompletedItemCommand())
      commander.button(RemoveCompletedItemCommand())
      commander.confirmableButton(ClearCompletedItemsCommand(), role: .destructive)

      Divider()

      commander.button(ToggleAdvancedCommandsCommand())
      commander.button(ReviewCompletedItemsCommand())
    }
  }
}
