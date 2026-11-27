// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import SwiftUI

/// Demonstrates undo and redo through a command centre's own `HistoryService`.
struct HistoryExampleView: View {
  /// Centre that performs the commands and owns their history.
  let centre: ExampleCentre

  /// Shows the count, a command that changes it, and the history's undo and redo buttons.
  var body: some View {
    VStack(spacing: 12) {
      Text("Done: \(centre.service.count)")
      centre.button(ExampleCommand())
      HStack {
        centre.historyUndoButton(showsCommandPresentation: true)
        centre.historyRedoButton(showsCommandPresentation: true)
      }
      Text("Stack: \(centre.historyService.debugDescription)")
        .foregroundStyle(.secondary)
    }
    .padding()
    .navigationTitle("History")
  }
}

#Preview {
  HistoryExampleView(centre: ExampleCentre())
}
