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
  let commander: Commander

  /// The system Undo and Redo experiment selected for this run.
  let systemUndoPrototype: SystemUndoPrototype

  /// Controls the importer launched from the contextual menu.
  @State private var isShowingContextImporter = false

  /// Holds importer state while the contextual importer is presented.
  @State private var contextImportCommand = ImportCommand<Commander>()

  var body: some View {
    NavigationStack {
      Playground(commander: commander)
        .navigationTitle("example.navigation.title")
        .toolbar { AppToolbar(commander: commander) }
    }
    .contextMenu {
      AppContextMenu(
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
    .undoManagerProxyPrototype(
      undoService: commander.undoService,
      isEnabled: systemUndoPrototype == .undoManager
    )
  }
}

#Preview {
  ContentView(commander: Commander(), systemUndoPrototype: .router)
}
