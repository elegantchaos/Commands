// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/11/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import SwiftUI

/// Demonstrates commands that register their undo actions with the window's `UndoManager`.
///
/// A text editor and a text field sit beside the commands, so their undo behaviour can be
/// compared. Typing in the text editor shares the window's undo stack with the commands, so
/// undo steps back through both in the order they happened. On macOS, a text field keeps its
/// own undo stack while it is being edited, so its typing is undone before any command.
struct UndoManagerExampleView: View {
  /// Centre that performs the commands and registers their inverses.
  @State private var centre = UndoManagerExampleCentre()

  /// Text edited in the text field.
  @State private var fieldText = ""

  /// Text edited in the text editor.
  @State private var editorText = ""

  /// The window's undo manager, passed to each command when it is created.
  @Environment(\.undoManager) private var undoManager

  /// Shows the count, the commands, both kinds of text input, and undo and redo buttons.
  var body: some View {
    VStack(spacing: 12) {
      Text("Done: \(centre.service.count)")
      HStack {
        centre.button(IncrementCountCommand(undoManager: undoManager))
        centre.button(DecrementCountCommand(undoManager: undoManager))
      }
      TextField("Text field", text: $fieldText)
        .textFieldStyle(.roundedBorder)
        .frame(maxWidth: 300)
      TextEditor(text: $editorText)
        .accessibilityLabel("Text editor")
        .frame(width: 300, height: 60)
        .border(.secondary)
      UndoManagerButtons(undoManager: undoManager)
    }
    .padding()
    .navigationTitle("UndoManager")
  }
}

#Preview {
  UndoManagerExampleView()
}
