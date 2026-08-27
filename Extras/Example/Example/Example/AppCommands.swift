// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CommandsUI
import SwiftUI

/// Adds example commands to the platform command menus.
struct AppCommands: Commands {
  /// Shared command centre used to resolve command state.
  let commander: Commander

  /// The system Undo and Redo experiment selected for this run.
  let systemUndoPrototype: SystemUndoPrototype

  /// Routes menu invocations for the router experiment.
  let systemUndoRouter: SystemUndoRouter

  var body: some Commands {
    CommandGroup(after: .newItem) {
      commander.importer(ImportCommand())
    }

    CommandMenu("example.menu.title") {
      commander.button(AddCommand())
      commander.button(RemoveCommand())
      commander.confirmableButton(ClearCommand(), role: .destructive)

      Divider()

      commander.button(ToggleAdvancedCommand())
      commander.button(ReviewCommand())
    }

    if systemUndoPrototype == .swiftUI {
      CommandGroup(replacing: .undoRedo) {
        commander.undoButton(showsCommandPresentation: true)
        commander.redoButton(showsCommandPresentation: true)
      }
    }

    if systemUndoPrototype == .router {
      CommandGroup(replacing: .undoRedo) {
        Button(systemUndoRouter.undoTitle, action: systemUndoRouter.undo)
          .keyboardShortcut("z", modifiers: .command)
          .disabled(systemUndoRouter.canUndo == false)

        Button(systemUndoRouter.redoTitle, action: systemUndoRouter.redo)
          .keyboardShortcut("Z", modifiers: .command)
          .disabled(systemUndoRouter.canRedo == false)
      }
    }
  }
}
