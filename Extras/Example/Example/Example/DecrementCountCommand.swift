// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/11/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import Foundation
import Icons

/// Decrements the count, registering an increment with the undo manager it was invoked with.
struct DecrementCountCommand: CommandWithUndo, CommandWithUI {
  /// Centre type, declared because inference cannot resolve two commands that undo each other.
  typealias Centre = UndoManagerExampleCentre

  /// Output type, declared for the same reason as `Centre`.
  typealias Output = Void

  /// Stable identifier for the command.
  let id = "com.elegantchaos.commands.decrement"

  /// Undo manager from the view that invoked the command.
  let undoManager: UndoManager?

  /// Returns the name shown on the command's button and in undo titles.
  func name(centre: UndoManagerExampleCentre) -> String {
    "Decrement"
  }

  /// The example commands have no help text.
  func help(centre: UndoManagerExampleCentre) -> String? {
    nil
  }

  /// Returns the icon shown on the command's button.
  func icon(centre: UndoManagerExampleCentre) -> Icon {
    Icon("minus.circle")
  }

  /// Decrements the count.
  func performSynchronously(centre: UndoManagerExampleCentre) {
    centre.service.decrementDone()
  }

  /// Returns the command that increments the count again.
  func undoCommand(centre: UndoManagerExampleCentre) -> IncrementCountCommand {
    IncrementCountCommand(undoManager: undoManager)
  }
}
