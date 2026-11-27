// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/11/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands

/// Performs the UndoManager page's commands and registers their inverses with the window's undo manager.
final class UndoManagerExampleCentre: CommandCentreWithUndo, ExampleServiceProvider {
  /// Count changed by the commands.
  let service = ExampleService()
}
