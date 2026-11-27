// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/11/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands

/// Performs the UndoManager tab's commands and registers their inverses with the window's undo manager.
final class UndoManagerExampleCentre: CommandCentreWithUndo, ExampleServiceProvider {
  /// Count changed by the commands.
  let service = ExampleService()

  /// The centre owns the undo actions it registers.
  var undoTarget: AnyObject { self }
}
