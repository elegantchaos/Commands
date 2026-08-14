// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CommandsUI
import SwiftUI

/// Adds commands to the app toolbar on macOS and iOS.
struct AppToolbar: ToolbarContent {
  /// Shared command centre that supplies toolbar items.
  let commander: Commander

  var body: some ToolbarContent {
    commander.toolbarItem(AddCommand(), placement: .primaryAction)
    commander.toolbarItem(RemoveCommand(), placement: .primaryAction)
    commander.confirmableToolbarItem(ClearCommand(), placement: .primaryAction)
    commander.toolbarItem(ReviewCommand(), placement: .primaryAction)
  }
}
