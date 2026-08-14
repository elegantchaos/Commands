// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CommandsUI
import SwiftUI

/// Adds the same commands to the root view's contextual menu.
struct AppContextMenu: View {
  /// Shared command centre that supplies contextual buttons.
  let commander: Commander

  /// Controls presentation of the contextual importer sheet.
  @Binding var isShowingImporter: Bool

  var body: some View {
    commander.button(AddCommand())
    commander.button(RemoveCommand())
    commander.importerButton(ImportCommand(), isShowingImportSheet: $isShowingImporter)

    Divider()

    commander.button(ToggleAdvancedCommand())
    commander.button(ReviewCommand())
  }
}
