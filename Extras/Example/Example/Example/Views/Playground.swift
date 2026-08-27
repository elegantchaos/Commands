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

        UndoInfo()

      }
      .padding()
    }
  }
}

struct UndoInfo: View {
  @Environment(\.undoManager) var undoManager

  var body: some View {
    HStack {
      Text(undoManager.debugDescription)
      if let undoManager, undoManager.canUndo {
        Text(undoManager.undoMenuItemTitle)
      } else {
        Text("no undo")
      }

    }
  }
}

struct EditPanel: View {
  @Environment(\.undoManager) var undoManager

  @State var text = "Some text"

  var body: some View {
    print(undoManager?.undoInfo ?? "")
    return GroupBox {
      VStack(alignment: .leading) {
        TextField(">", text: $text)
      }
    } label: {
      Label("example.section.state", systemImage: "chart.bar.xaxis")
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

extension UndoManager {
  var undoInfo: String {
    if canUndo {
      return undoMenuItemTitle + undoActionName
    } else {
      return "no undo"
    }
  }
}
