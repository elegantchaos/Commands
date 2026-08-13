// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// A command centre that records inverses in an undo service.
@MainActor
public protocol UndoableCommandCentre: CommandCentre {
  var undoService: UndoService { get }
}

@MainActor
extension UndoableCommandCentre {
  /// Allows history commands to finish while a history operation is suspended.
  public func isAllowed(from source: CommandSource) -> Bool {
    undoService.operation == nil || source == .undo || source == .redo
  }

  public func recordFinishedCommand<C: Command>(_ command: C, from source: CommandSource)
  where C.Centre == Self {
    if let invocation = command.inverse(centre: self), source != .undo, source != .redo {
      undoService.recordUndo(invocation)
    }
  }
}
