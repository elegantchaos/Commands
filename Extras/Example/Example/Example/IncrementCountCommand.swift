// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/11/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import Foundation
import Icons

/// Increments the count, registering a decrement with the undo manager it was invoked with.
struct IncrementCountCommand: CommandWithUndo, CommandWithUI {
  /// Stable identifier for the command.
  let id = "com.elegantchaos.commands.increment"

  /// Undo manager from the view that invoked the command.
  let undoManager: UndoManager?

  /// Returns the name shown on the command's button and in undo titles.
  func name(centre: UndoManagerExampleCentre) -> String {
    "Increment"
  }

  /// The example commands have no help text.
  func help(centre: UndoManagerExampleCentre) -> String? {
    nil
  }

  /// Returns the icon shown on the command's button.
  func icon(centre: UndoManagerExampleCentre) -> Icon {
    Icon("plus.circle")
  }

  /// Increments the count.
  func performSynchronously(centre: UndoManagerExampleCentre) {
    centre.service.incrementDone()
  }

  /// Returns the command that decrements the count again.
  func undoCommand(centre: UndoManagerExampleCentre) -> DecrementCountCommand {
    DecrementCountCommand(undoManager: undoManager)
  }
}
