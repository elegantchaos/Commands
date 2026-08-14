// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CommandsUI
import SwiftUI

/// Adds commands to the app toolbar on macOS and iOS.
struct ExampleToolbar: ToolbarContent {
  /// Shared command centre that supplies toolbar items.
  let commander: ExampleCommander

  var body: some ToolbarContent {
    commander.toolbarItem(AddCompletedItemCommand(), placement: .primaryAction)
    commander.toolbarItem(RemoveCompletedItemCommand(), placement: .secondaryAction)
    commander.confirmableToolbarItem(ClearCompletedItemsCommand(), placement: .secondaryAction)
    commander.toolbarItem(ReviewCompletedItemsCommand(), placement: .secondaryAction)
  }
}
