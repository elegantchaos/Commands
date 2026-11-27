// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/11/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

/// Undo and redo buttons for an `UndoManager`, titled with the system's menu titles.
///
/// `UndoManager` is not observable, so the view redraws when the manager reports a change.
struct UndoManagerButtons: View {
  /// The undo manager the buttons drive.
  let undoManager: UndoManager?

  /// Changes whenever the undo manager reports a change, to redraw the buttons.
  @State private var changeCount = 0

  /// Shows Undo and Redo buttons, disabled when there is nothing to undo or redo.
  var body: some View {
    HStack {
      Button(undoManager?.undoMenuItemTitle ?? "", action: undo)
        .disabled(undoManager?.canUndo != true)
      Button(undoManager?.redoMenuItemTitle ?? "", action: redo)
        .disabled(undoManager?.canRedo != true)
    }
    .id(changeCount)
    .onReceive(changes(.NSUndoManagerDidCloseUndoGroup)) { _ in changeCount += 1 }
    .onReceive(changes(.NSUndoManagerDidUndoChange)) { _ in changeCount += 1 }
    .onReceive(changes(.NSUndoManagerDidRedoChange)) { _ in changeCount += 1 }
  }

  /// Undoes the most recent group.
  private func undo() {
    undoManager?.undo()
  }

  /// Redoes the most recently undone group.
  private func redo() {
    undoManager?.redo()
  }

  /// Publishes the undo manager's notifications with the supplied name.
  private func changes(_ name: Notification.Name) -> NotificationCenter.Publisher {
    NotificationCenter.default.publisher(for: name, object: undoManager)
  }
}
