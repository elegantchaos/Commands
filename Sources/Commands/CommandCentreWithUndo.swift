// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/11/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// A command centre which interacts with an UndoManager to register an undo for any command
/// that it performs.
@MainActor
public protocol CommandCentreWithUndo: CommandCentre {
  /// The target to use for UndoManager when registering undo handlers.
  var undoTarget: AnyObject { get }
  
  /// Perform the supplied command, and register a different supplied command as the undo action.
  func performAndRegisterUndo<C, U>(command: C, undo: U, undoManager: UndoManager?, name: String) -> C.ResultType   where C: CommandWithUndo, C.Centre == Self, U: CommandWithUndo, U.Centre == Self, C.ResultType == U.ResultType
  
  /// Hook to do something with the result of a command that was undone/redone, which would otherwise be discarded.
  func recordUndoRedoResult<C: CommandWithUndo>(_ command: C, result: C.ResultType)
}

@MainActor
public extension CommandCentreWithUndo {
  /// Perform the supplied command, and register a different supplied command as the undo action.
  func performAndRegisterUndo<C, U>(command: C, undo: U, undoManager: UndoManager?, name: String) -> C.ResultType where C: CommandWithUndo, C.Centre == Self, U: CommandWithUndo, U.Centre == Self, C.ResultType == U.ResultType {
    print("registered undo \(undo.nameForUndo(centre: self)) for command \(command.nameForUndo(centre: self))")
    undoManager?.registerUndo(withTarget: undoTarget) { _ in
      let result = performAndRegisterUndo(command: undo, undo: command, undoManager: undoManager, name: name)
      recordUndoRedoResult(undo, result: result)
    }
    undoManager?.setActionName(name)
    return command.performSynchronously(centre: self)
  }
  
  func recordUndoRedoResult<C>(_ command: C, result: C.ResultType) where C: CommandWithUndo, C.Centre == Self {
    print("discarded result \(result) for command \(command.nameForUndo(centre: self))")
  }
}
