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
