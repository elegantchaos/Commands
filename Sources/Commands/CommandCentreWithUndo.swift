// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/11/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// A command centre that registers the inverse of each `CommandWithUndo` it performs with the
/// undo manager the command was invoked with.
///
/// The centre is the target of its registered undo actions. `UndoManager` does not keep its
/// targets alive, so the undo stack never keeps the centre alive; the centre's lifetime stays with
/// whatever owns it.
@MainActor
public protocol CommandCentreWithUndo: CommandCentre, AnyObject {
  /// Hook to do something with the result of a command that was undone/redone, which would otherwise be discarded.
  func recordUndoRedoResult<C: CommandWithUndo>(_ command: C, result: C.Output)
  where C.Centre == Self
}

@MainActor
extension CommandCentreWithUndo {
  /// Performs the supplied command, and registers its inverse as the undo action.
  ///
  /// Only `CommandWithUndo.perform(centre:)` calls this, after the centre's `perform` has checked
  /// the command's availability and started its lifecycle. When the undo manager later runs the
  /// registered action, the inverse gets the same availability check and lifecycle hooks.
  /// `UndoManager` cannot receive an error, so an unavailable inverse is reported through
  /// `recordFailedCommand` and is not performed; the action is then gone from the undo stack.
  ///
  /// `actionName` is passed in, not read from `inverse`, because it names the user's action, not the
  /// command that reverses it. Undoing "Increment" performs a decrement, but the menu should
  /// still say "Undo Increment" and then "Redo Increment". The commands swap roles at each
  /// undo and redo, so the original action name is carried through every registration.
  ///
  /// The registered action reaches the centre through the undo manager's target and holds the
  /// undo manager weakly, so neither is kept alive by the undo stack. Commands must hold their
  /// undo manager weakly too; see `CommandWithUndo.undoManager`.
  func performAndRegisterUndo<C, U>(
    command: C, inverse: U, undoManager: UndoManager?, actionName: String
  ) -> C.Output
  where
    C: CommandWithUndo, C.Centre == Self, U: CommandWithUndo, U.Centre == Self,
    C.Output == U.Output
  {
    commandChannel.debug(
      "registered inverse \(inverse.id) for command \(command.id) as \(actionName)"
    )

    // Commands are usually performed asynchronously, after the event that triggered them. An
    // event-grouping undo manager would leave the group for this registration open until the
    // next event ends, merging the command with whatever that event does, such as typing. So
    // when no group is open, the command gets a group of its own that closes when it finishes.
    // Event grouping is paused meanwhile, because beginning a group at the top level would
    // otherwise first open the manager's automatic event group around it.
    let ownedGroup = undoManager.flatMap { $0.groupingLevel == 0 ? $0 : nil }
    let groupedByEvent = ownedGroup?.groupsByEvent ?? false
    ownedGroup?.groupsByEvent = false
    ownedGroup?.beginUndoGrouping()
    defer {
      ownedGroup?.endUndoGrouping()
      ownedGroup?.groupsByEvent = groupedByEvent
    }

    undoManager?.registerUndo(withTarget: self) { [weak undoManager] centre in
      guard centre.availability(inverse) == .enabled else {
        centre.recordFailedCommand(inverse, error: CommandError.commandUnavailable)
        return
      }

      centre.recordStartedCommand(inverse)
      let result = centre.performAndRegisterUndo(
        command: inverse, inverse: command, undoManager: undoManager, actionName: actionName)
      centre.recordFinishedCommand(inverse, outcome: .succeeded)
      centre.recordUndoRedoResult(inverse, result: result)
    }
    undoManager?.setActionName(actionName)
    return command.performSynchronously(centre: self)
  }

  /// By default, logs and discards the result of an undone or redone command.
  public func recordUndoRedoResult<C>(_ command: C, result: C.Output)
  where C: CommandWithUndo, C.Centre == Self {
    commandChannel.debug(
      "discarded result \(result) for command \(command.undoActionName(centre: self))")
  }
}
