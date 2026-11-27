// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/11/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import SwiftUI

/// Demonstrates commands that share the window's `UndoManager` with a text field.
///
/// Undoing steps back through typing and commands in the order they happened, using the
/// buttons here or the system's Undo command.
struct UndoManagerExampleView: View {
  /// Centre that performs the commands and registers their inverses.
  @State private var commander = UndoManagerExampleCommander()

  /// Text whose edits share the undo stack with the commands.
  @State private var notes = ""

  /// The window's undo manager, passed to each command when it is created.
  @Environment(\.undoManager) private var undoManager

  /// Shows the count, the commands, a text field and undo and redo buttons for the shared stack.
  var body: some View {
    VStack(spacing: 12) {
      Text("Done: \(commander.service.count)")
      HStack {
        commander.button(IncrementCountCommand(undoManager: undoManager))
        commander.button(DecrementCountCommand(undoManager: undoManager))
      }
      TextField("Notes", text: $notes)
        .textFieldStyle(.roundedBorder)
        .frame(maxWidth: 300)
      UndoManagerButtons(undoManager: undoManager)
    }
    .padding()
  }
}

#Preview {
  UndoManagerExampleView()
}
