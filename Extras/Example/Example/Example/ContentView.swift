// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import SwiftUI

/// Demonstrates commands across buttons, toolbars, contextual menus, and app menus.
struct ContentView: View {
  /// Shared command centre for every control in the example.
  let commander: ExampleCommander

  /// Controls the importer launched from the contextual menu.
  @State private var isShowingContextImporter = false

  /// Holds importer state while the contextual importer is presented.
  @State private var contextImportCommand = ImportExampleFilesCommand<ExampleCommander>()

  var body: some View {
    NavigationStack {
      ExamplePlayground(commander: commander)
        .navigationTitle("example.navigation.title")
        .toolbar { ExampleToolbar(commander: commander) }
    }
    .contextMenu {
      ExampleContextMenu(
        commander: commander,
        isShowingImporter: $isShowingContextImporter
      )
    }
    .modifier(
      ImporterCommandModifier(
        isShowing: $isShowingContextImporter,
        command: $contextImportCommand,
        centre: commander
      )
    )
  }
}

#Preview {
  ContentView(commander: ExampleCommander())
}
