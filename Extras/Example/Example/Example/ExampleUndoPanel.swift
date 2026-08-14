// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CommandsUI
import SwiftUI

/// Displays undo and redo controls with guidance about reversible commands.
struct ExampleUndoPanel: View {
  /// Shared command centre that owns the undo service.
  let commander: ExampleCommander

  var body: some View {
    GroupBox {
      VStack(alignment: .leading) {
        HStack {
          commander.undoButton(showsCommandPresentation: true)
            .buttonStyle(.bordered)
          commander.redoButton(showsCommandPresentation: true)
            .buttonStyle(.bordered)
        }
        
        Text("example.panel.undo.hint")
          .font(.footnote)
          .foregroundStyle(.secondary)
      }
    } label: {
      Label("example.section.undo", systemImage: "arrow.uturn.backward")
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}
