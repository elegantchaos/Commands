// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Errors reported while performing a history operation.
public enum UndoServiceError: Error, Equatable, Sendable {
  /// An undo or redo operation is already in progress.
  case historyOperationInProgress

  /// A forward command must finish before a history operation can begin.
  case forwardCommandInProgress
}

/// A lightweight, observable history of command inverses.
///
/// The cursor separates completed history from entries that can be redone.
/// Each successful history operation replaces the executed inverse with the
/// inverse returned by that action, so undo and redo can traverse the same
/// history in either direction. Each service owns all state for its active
/// history operation; it does not use global or task-local state.
@MainActor
@Observable
open class UndoService {
  /// An active history operation and its execution context.
  ///
  /// Keeping these values in one enum makes it impossible to expose a history
  /// mode without its matching execution context.
  private enum ActiveOperation {
    /// Reverses a completed history entry using the associated context.
    case undo(CommandExecutionContext)

    /// Reapplies an undone history entry using the associated context.
    case redo(CommandExecutionContext)

    /// The execution context carried by the operation.
    var context: CommandExecutionContext {
      switch self {
      case .undo(let context), .redo(let context):
        context
      }
    }
  }

  /// Inverses for completed and redoable history entries.
  var undoStack: [CommandInverse] = []

  /// The number of completed entries at the front of `undoStack`.
  var undoCursor = 0

  /// Active history operation and its execution context.
  private var activeOperation: ActiveOperation?

  /// Number of forward commands that have started but not yet finished.
  ///
  /// Forward commands can overlap, so this is a count rather than another
  /// active-operation case. History operations wait until the count reaches zero.
  private var forwardCommandCount = 0

  /// Whether an undo or redo operation is currently being performed.
  ///
  /// This module-internal query lets `UndoableCommandCentre` protect history
  /// without exposing additional public state.
  var isPerformingHistoryOperation: Bool {
    activeOperation != nil
  }

  /// Whether an undo operation is currently being performed.
  public var isUndoing: Bool {
    if case .undo = activeOperation {
      true
    } else {
      false
    }
  }

  /// Whether a redo operation is currently being performed.
  public var isRedoing: Bool {
    if case .redo = activeOperation {
      true
    } else {
      false
    }
  }

  public init() {
  }

  /// Whether there is an entry that can be undone.
  open var hasUndo: Bool {
    nextUndo != nil
  }

  /// The inverse that will be performed by the next undo operation.
  open var nextUndo: CommandInverse? {
    guard undoCursor > 0 else {
      return nil
    }
    return undoStack[undoCursor - 1]
  }

  /// Whether there is an entry that can be redone.
  open var hasRedo: Bool {
    nextRedo != nil
  }

  /// The inverse that will be performed by the next redo operation.
  open var nextRedo: CommandInverse? {
    guard undoCursor < undoStack.count else {
      return nil
    }
    return undoStack[undoCursor]
  }

  /// Records a new inverse and discards any entries that could previously be redone.
  open func recordUndo(_ invocation: CommandInverse) {
    undoStack.removeSubrange(undoCursor...)
    undoStack.append(invocation)
    undoCursor = undoStack.count
  }

  /// Marks the start of a forward command that can change undo history.
  ///
  /// Every call must be paired with `finishForwardCommand()` after the command
  /// completes, including when it throws.
  public func beginForwardCommand() {
    forwardCommandCount += 1
  }

  /// Marks the completion of a forward command that can change undo history.
  public func finishForwardCommand() {
    precondition(forwardCommandCount > 0, "No forward command is in progress.")
    forwardCommandCount -= 1
  }

  /// Performs the next inverse that reverses a completed history entry.
  ///
  /// The inverse remains available when it throws. Calls made while undo or
  /// redo is in progress throw `UndoServiceError.historyOperationInProgress`.
  /// Calls made while forward commands are active throw
  /// `UndoServiceError.forwardCommandInProgress`.
  open func performUndo() async throws {
    guard isPerformingHistoryOperation == false else {
      throw UndoServiceError.historyOperationInProgress
    }

    guard forwardCommandCount == 0 else {
      throw UndoServiceError.forwardCommandInProgress
    }

    guard undoCursor > 0 else {
      return
    }

    let index = undoCursor - 1
    let inverse = undoStack[index]
    let context = CommandExecutionContext()
    activeOperation = .undo(context)
    defer {
      activeOperation = nil
    }

    try Task.checkCancellation()
    let replacement = try await inverse.action(context)
    updateHistory(at: index, with: replacement, cursor: index)
  }

  /// Performs the next inverse that reapplies an undone history entry.
  ///
  /// The inverse remains available when it throws. Calls made while undo or
  /// redo is in progress throw `UndoServiceError.historyOperationInProgress`.
  /// Calls made while forward commands are active throw
  /// `UndoServiceError.forwardCommandInProgress`.
  open func performRedo() async throws {
    guard isPerformingHistoryOperation == false else {
      throw UndoServiceError.historyOperationInProgress
    }

    guard forwardCommandCount == 0 else {
      throw UndoServiceError.forwardCommandInProgress
    }

    guard undoCursor < undoStack.count else {
      return
    }

    let index = undoCursor
    let inverse = undoStack[index]
    let context = CommandExecutionContext()
    activeOperation = .redo(context)
    defer {
      activeOperation = nil
    }

    try Task.checkCancellation()
    let replacement = try await inverse.action(context)
    updateHistory(at: index, with: replacement, cursor: index + 1)
  }

  /// Replaces a performed entry with its inverse, or removes it when no inverse exists.
  private func updateHistory(at index: Int, with replacement: CommandInverse?, cursor: Int) {
    if let replacement {
      undoStack[index] = replacement
      undoCursor = cursor
    } else {
      undoStack.remove(at: index)
      undoCursor = index
    }
  }

  /// Returns whether the supplied context is active for this service.
  func isActive(_ context: CommandExecutionContext?) -> Bool {
    activeOperation?.context === context
  }

  /// Textual description of the stack.
  open var stackDescription: String {
    undoStack
      .map { $0.id }
      .joined(separator: " > ")
  }
}

@MainActor
extension UndoService: @MainActor CustomDebugStringConvertible {
  public var debugDescription: String { stackDescription }
}
