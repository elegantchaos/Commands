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
  @State private var commander = HistoryExampleCommander()

  /// Shows the count, a command that changes it, and the history's undo and redo buttons.
  var body: some View {
    VStack(spacing: 12) {
      Text("Done: \(commander.service.count)")
      commander.button(ExampleCommand())
      HStack {
        commander.historyUndoButton(showsCommandPresentation: true)
        commander.historyRedoButton(showsCommandPresentation: true)
      }
      Text("Stack: \(commander.historyService.debugDescription)")
        .foregroundStyle(.secondary)
    }
    .padding()
  }
}

#Preview {
  HistoryExampleView()
}
