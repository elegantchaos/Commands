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
  ///
  /// `name` is passed in, not read from `undo`, because it names the user's action, not the
  /// command that reverses it. Undoing "Increment" performs a decrement, but the menu should
  /// still say "Undo Increment" and then "Redo Increment". The commands swap roles at each
  /// undo and redo, so the original name is carried through every registration.
  func performAndRegisterUndo<C, U>(command: C, undo: U, undoManager: UndoManager?, name: String)
    -> C.ResultType
  where
    C: CommandWithUndo, C.Centre == Self, U: CommandWithUndo, U.Centre == Self,
    C.ResultType == U.ResultType

  /// Hook to do something with the result of a command that was undone/redone, which would otherwise be discarded.
  func recordUndoRedoResult<C: CommandWithUndo>(_ command: C, result: C.ResultType)
  where C.Centre == Self
}

@MainActor
extension CommandCentreWithUndo {
  /// Perform the supplied command, and register a different supplied command as the undo action.
  ///
  /// `name` is passed in, not read from `undo`, because it names the user's action, not the
  /// command that reverses it. Undoing "Increment" performs a decrement, but the menu should
  /// still say "Undo Increment" and then "Redo Increment". The commands swap roles at each
  /// undo and redo, so the original name is carried through every registration.
  ///
  /// When the undo manager later runs the registered action, the undo command gets the same
  /// availability check and lifecycle hooks as a forward command performed through the centre.
  /// `UndoManager` cannot receive an error, so an unavailable undo command is reported through
  /// `recordFailedCommand` and is not performed; the action is then gone from the undo stack.
  public func performAndRegisterUndo<C, U>(
    command: C, undo: U, undoManager: UndoManager?, name: String
  ) -> C.ResultType
  where
    C: CommandWithUndo, C.Centre == Self, U: CommandWithUndo, U.Centre == Self,
    C.ResultType == U.ResultType
  {
    commandChannel.debug(
      "registered undo \(undo.nameForUndo(centre: self)) for command \(command.nameForUndo(centre: self))"
    )
    undoManager?.registerUndo(withTarget: undoTarget) { _ in
      guard availability(undo) == .enabled else {
        recordFailedCommand(undo, error: CommandError.commandUnavailable)
        return
      }

      recordStartedCommand(undo)
      let result = performAndRegisterUndo(
        command: undo, undo: command, undoManager: undoManager, name: name)
      recordFinishedCommand(undo, outcome: .succeeded)
      recordUndoRedoResult(undo, result: result)
    }
    undoManager?.setActionName(name)
    return command.performSynchronously(centre: self)
  }

  /// By default, logs and discards the result of an undone or redone command.
  public func recordUndoRedoResult<C>(_ command: C, result: C.ResultType)
  where C: CommandWithUndo, C.Centre == Self {
    commandChannel.debug(
      "discarded result \(result) for command \(command.nameForUndo(centre: self))")
  }
}
