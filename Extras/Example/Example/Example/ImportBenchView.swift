// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/11/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CommandsUI
import SwiftUI

/// Shows importer commands: one in a button, one that confirms the chosen files, and one in a
/// context menu, where the importer sheet is attached to the view that owns the menu.
struct ImportBenchView: View {
  /// The command centre.
  let centre: ExampleCentre

  /// Whether the context menu's importer sheet is showing.
  @State private var isShowingContextImporter = false

  /// The command the context menu's importer performs.
  @State private var contextCommand = ImportFilesCommand<ExampleCentre>(
    title: "Import from Menu", confirms: true)

  /// The importer controls, and the names of the files last imported.
  var body: some View {
    VStack(spacing: 16) {
      centre.importer(ImportFilesCommand(title: "Import Files", confirms: false))
      centre.importer(ImportFilesCommand(title: "Import and Confirm", confirms: true))
      Text("Right-click or long-press here for a menu that imports")
        .padding()
        .border(.secondary)
        .contextMenu {
          centre.importerButton(contextCommand, isShowingImportSheet: $isShowingContextImporter)
        }
        .modifier(
          ImporterCommandModifier(
            isShowing: $isShowingContextImporter, command: $contextCommand, centre: centre))
      List(centre.items.importedFiles, id: \.self) { name in
        Text(name)
      }
      .frame(minHeight: 120)
    }
    .padding()
    .navigationTitle("Import")
  }
}

#Preview {
  ImportBenchView(centre: ExampleCentre())
}
