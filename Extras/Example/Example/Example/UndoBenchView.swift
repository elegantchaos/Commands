// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import SwiftUI

/// Demonstrates command execution and undo in a SwiftUI view.
struct UndoBenchView: View {
  /// The command centre.
  let commander: ExampleCommander

  /// The counter, the command, and the undo and redo buttons with the undo stack.
  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundStyle(.tint)
      Text("Done: \(commander.service.count)")
      commander.button(ExampleCommand())
      commander.undoButton(showsCommandPresentation: true)
      commander.redoButton(showsCommandPresentation: true)
      Text("Stack: \(commander.undoService.debugDescription)")
    }
    .padding()
    .navigationTitle("Undo and Redo")
  }
}

#Preview {
  UndoBenchView(commander: ExampleCommander())
}
