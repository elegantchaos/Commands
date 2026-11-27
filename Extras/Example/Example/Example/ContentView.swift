// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/11/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

/// Shows one tab for each of the package's undo paths, each with its own commands and count.
struct ContentView: View {
  /// The two demonstrations, side by side as tabs.
  var body: some View {
    TabView {
      Tab("UndoManager", systemImage: "arrow.uturn.backward.circle") {
        UndoManagerExampleView()
      }
      Tab("History", systemImage: "clock.arrow.circlepath") {
        HistoryExampleView()
      }
    }
  }
}

#Preview {
  ContentView()
}
