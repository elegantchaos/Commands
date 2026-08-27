// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

/// Renders three panels that explain and exercise the example's command state.
struct Playground: View {

  /// Shared command centre that supplies every command surface.
  let commander: Commander

  var body: some View {
    ScrollView {
      VStack {
        HStack(alignment: .top) {
          CommandsPanel(commander: commander)

          VStack {
            SystemUndoPrototypePanel(prototype: SystemUndoPrototype.selected)
            StatePanel(
              itemService: commander.itemService,
              importService: commander.importService
            )
            EditPanel()
            Spacer()
            UndoPanel(commander: commander)
          }
        }

        Text("example.playground.footer")
          .font(.footnote)
          .foregroundStyle(.secondary)
          .padding()
      }
      .padding()
    }
  }
}

struct EditPanel: View {
  /// Editable text used to compare native-editor ownership across prototypes.
  @State private var text = "Some text"

  var body: some View {
    GroupBox {
      VStack(alignment: .leading) {
        TextField("example.undo.text.placeholder", text: $text)
      }
    } label: {
      Label("example.undo.text.title", systemImage: "text.cursor")
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}
