// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CommandsUI
import SwiftUI

/// Adds the same commands to the root view's contextual menu.
struct ExampleContextMenu: View {
  /// Shared command centre that supplies contextual buttons.
  let commander: ExampleCommander

  /// Controls presentation of the contextual importer sheet.
  @Binding var isShowingImporter: Bool

  var body: some View {
    commander.button(AddCompletedItemCommand())
    commander.button(RemoveCompletedItemCommand())
    commander.importerButton(ImportExampleFilesCommand(), isShowingImportSheet: $isShowingImporter)

    Divider()

    commander.button(ToggleAdvancedCommandsCommand())
    commander.button(ReviewCompletedItemsCommand())
  }
}
