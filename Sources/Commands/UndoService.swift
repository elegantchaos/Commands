// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Errors reported while performing an undo operation.
public enum UndoServiceError: Error, Equatable {
  /// An undo operation is already in progress.
  case undoInProgress
}

/// A lightweight, observable stack of command inverses.
@MainActor
@Observable
open class UndoService {
  /// Stack of command inverses.
  /// Performing the actions of these will undo the commands they represent.
  var undoStack: [CommandInverse] = []

  /// Whether an inverse is currently being performed.
  public private(set) var isUndoing = false

  public init() {
  }

  /// Are there items on the undo stack?
  open var hasUndo: Bool {
    !undoStack.isEmpty
  }

  /// Record a `CommandInverse` on the stack.
  open func recordUndo(_ invocation: CommandInverse) {
    undoStack = undoStack + [invocation]
  }

  /// Performs the most recently recorded inverse.
  ///
  /// The inverse remains available when it throws. Calls made while an undo is
  /// in progress throw `UndoServiceError.undoInProgress`.
  open func performUndo() async throws {
    guard isUndoing == false else {
      throw UndoServiceError.undoInProgress
    }

    guard let index = undoStack.indices.last else {
      return
    }

    let inverse = undoStack[index]
    isUndoing = true
    defer { isUndoing = false }

    try Task.checkCancellation()
    try await inverse.action(.undo)
    undoStack.remove(at: index)
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
