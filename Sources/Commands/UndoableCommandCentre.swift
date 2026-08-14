// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// A command centre that records inverses in an undo service.
///
/// This protocol owns the package's undo/redo execution policy. While its
/// service performs undo or redo, it allows only commands with that service's
/// active context and prevents forward commands from changing history.
@MainActor
public protocol UndoableCommandCentre: CommandCentre {
  var undoService: UndoService { get }
}

@MainActor
extension UndoableCommandCentre {
  /// Allows only the context owned by the active undo or redo operation.
  ///
  /// Keeping this rule here ensures `CommandCentre` remains independent of
  /// undo and redo.
  public func isAllowed(during context: CommandExecutionContext?) -> Bool {
    undoService.isPerformingHistoryOperation == false || undoService.isActive(context)
  }

  /// Records the start of a forward command so history operations can wait for it to finish.
  public func recordStartedCommand<C: Command>(_ command: C)
  where C.Centre == Self {
    guard undoService.isPerformingHistoryOperation == false else {
      return
    }
    undoService.beginForwardCommand()
  }

  /// Records the completion of a forward command and its reversal when it succeeded.
  ///
  /// Custom lifecycle implementations must preserve the paired forward-command
  /// tracking and must not record reversals for failed commands or active history operations.
  public func recordFinishedCommand<C: Command>(
    _ command: C,
    outcome: CommandOutcome
  ) where C.Centre == Self {
    guard undoService.isPerformingHistoryOperation == false else {
      return
    }
    defer { undoService.finishForwardCommand() }
    if case .succeeded = outcome, let reversal = command.reversal(centre: self) {
      undoService.recordUndo(reversal)
    }
  }
}
