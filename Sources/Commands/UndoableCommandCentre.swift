// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

@MainActor
public protocol UndoableCommandCenter: CommandCentre {
  var undoService: UndoService { get }
}

@MainActor
public extension UndoableCommandCenter {
  func recordFinishedCommand<C: Command>(_ command: C, from source: CommandSource) where C.Centre == Self {
    if let invocation = command.inverse(centre: self), source != .undo {
      undoService.recordUndo(invocation)
    }
  }
}
