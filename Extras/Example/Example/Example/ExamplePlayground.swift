// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

/// Renders three panels that explain and exercise the example's command state.
struct ExamplePlayground: View {
  /// Shared command centre that supplies every command surface.
  let commander: ExampleCommander

  var body: some View {
    ScrollView {
      VStack {
        HStack(alignment: .top) {
          ExampleCommandsPanel(commander: commander)

          VStack {
            ExampleStatePanel(service: commander.service)
            Spacer()
            ExampleUndoPanel(commander: commander)
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
