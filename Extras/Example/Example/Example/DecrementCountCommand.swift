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
  typealias Centre = UndoManagerExampleCommander

  /// Result type, declared for the same reason as `Centre`.
  typealias ResultType = Void

  /// Stable identifier, also used to look up the command's localized name.
  let id = "com.elegantchaos.commands.decrement"

  /// Undo manager from the view that invoked the command.
  let undoManager: UndoManager?

  /// Returns the icon shown on the command's button.
  func icon(centre: UndoManagerExampleCommander) -> Icon {
    Icon("minus.circle")
  }

  /// Decrements the count.
  func performSynchronously(centre: UndoManagerExampleCommander) {
    centre.service.decrementDone()
  }

  /// Returns the command that increments the count again.
  func undoCommand(centre: UndoManagerExampleCommander) -> IncrementCountCommand {
    IncrementCountCommand(undoManager: undoManager)
  }
}
