// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/11/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Command which supports undo/redo via a Foundation UndoManager.
/// A command of this type should be able to perform synchronously, and should
/// implement `performSynchronously` instead of `perform`.
/// It should also implement `undoCommand`, which should return the inverse
/// command to run when it is undone. Both commands should have the same output type.
@MainActor
public protocol CommandWithUndo: Command where Centre: CommandCentreWithUndo {
  /// The inverse command for this one.
  associatedtype UndoCommand: CommandWithUndo
  where UndoCommand.Output == Output, UndoCommand.Centre == Centre

  /// The undo manager associated with this command.
  /// This should be captured when the command is invoked.
  var undoManager: UndoManager? { get }

  /// The name of the undo action for this command, as shown in titles such as "Undo Increment".
  func undoActionName(centre: Centre) -> String

  /// Perform the command's work.
  func performSynchronously(centre: Centre) -> Output

  /// Return the command to perform if the user chooses "Undo" after performing this one.
  func undoCommand(centre: Centre) -> UndoCommand
}

@MainActor
extension CommandWithUndo {
  /// By default, the undo action is named after the command's identifier.
  public func undoActionName(centre: Centre) -> String { id }
}

@MainActor
extension CommandWithUndo {
  /// Performs the command and registers its inverse with the command's undo manager.
  public func perform(centre: Centre) async throws -> Output {
    centre.performAndRegisterUndo(
      command: self, inverse: undoCommand(centre: centre), undoManager: undoManager,
      actionName: undoActionName(centre: centre))
  }
}
