// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Errors reported while performing a history operation.
public enum UndoServiceError: Error, Equatable {
  /// An undo or redo operation is already in progress.
  case historyOperationInProgress
}

/// A lightweight, observable history of command inverses.
///
/// The cursor separates completed history from entries that can be redone.
/// Each successful history operation replaces the executed inverse with the
/// inverse returned by that action, so undo and redo can traverse the same
/// history in either direction.
@MainActor
@Observable
open class UndoService {
  /// A history operation that is currently in progress.
  public enum Operation: Equatable {
    /// Reverses a completed history entry.
    case undo

    /// Reapplies an undone history entry.
    case redo
  }

  /// Inverses for completed and redoable history entries.
  var undoStack: [CommandInverse] = []

  /// The number of completed entries at the front of `undoStack`.
  var undoCursor = 0

  /// The history operation that is currently being performed, if any.
  public private(set) var operation: Operation?

  /// Whether an undo operation is currently being performed.
  public var isUndoing: Bool {
    operation == .undo
  }

  /// Whether a redo operation is currently being performed.
  public var isRedoing: Bool {
    operation == .redo
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

  /// Performs the next inverse that reverses a completed history entry.
  ///
  /// The inverse remains available when it throws. Calls made while undo or
  /// redo is in progress throw `UndoServiceError.historyOperationInProgress`.
  open func performUndo() async throws {
    guard operation == nil else {
      throw UndoServiceError.historyOperationInProgress
    }

    guard undoCursor > 0 else {
      return
    }

    let index = undoCursor - 1
    let inverse = undoStack[index]
    operation = .undo
    defer { operation = nil }

    try Task.checkCancellation()
    let replacement = try await inverse.action(.undo)
    updateHistory(at: index, with: replacement, cursor: index)
  }

  /// Performs the next inverse that reapplies an undone history entry.
  ///
  /// The inverse remains available when it throws. Calls made while undo or
  /// redo is in progress throw `UndoServiceError.historyOperationInProgress`.
  open func performRedo() async throws {
    guard operation == nil else {
      throw UndoServiceError.historyOperationInProgress
    }

    guard undoCursor < undoStack.count else {
      return
    }

    let index = undoCursor
    let inverse = undoStack[index]
    operation = .redo
    defer { operation = nil }

    try Task.checkCancellation()
    let replacement = try await inverse.action(.redo)
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
