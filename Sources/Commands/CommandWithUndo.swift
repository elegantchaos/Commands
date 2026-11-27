// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/11/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Command which supports undo/redo via a Foundation UndoManager.
/// A command of this type should be able to perform synchronously, and should
/// implement `performSynchronously` instead of `perform`.
/// It should also implement `undoCommand`, which should return the inverse
/// command to run when it is undone. Both commands should have the same result type.
@MainActor
public protocol CommandWithUndo: Command where Centre: CommandCentreWithUndo {
  /// The inverse command for this one.
  associatedtype UndoCommand: CommandWithUndo where UndoCommand.ResultType == ResultType, UndoCommand.Centre == Centre

  /// The undo manager associated with this command.
  /// This should be captured when the command is invoked.
  var undoManager: UndoManager? { get }
  
  /// Name to use for the UndoManager to use for the command.
  func nameForUndo(centre: Centre) -> String
  
  /// Perform the command's work.
  func performSynchronously(centre: Centre) -> ResultType
  
  /// Return the command to perform if the user chooses "Undo" after performing this one.
  func undoCommand(centre: Centre) -> UndoCommand
}

@MainActor
public extension CommandWithUndo {
  func nameForUndo(centre: Centre) -> String { id }
}

@MainActor
public extension CommandWithUndo {
  func perform(centre: Centre) async throws -> ResultType where ResultType == UndoCommand.ResultType, Centre: CommandCentreWithUndo, UndoCommand.Centre: CommandCentreWithUndo {
    return centre.performAndRegisterUndo(command: self, undo: undoCommand(centre: centre), undoManager: undoManager, name: nameForUndo(centre: centre))
  }
  
}
