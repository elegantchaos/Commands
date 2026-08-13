// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Describes the inverse of a command.
@MainActor
public protocol CommandInverse {
  /// Stable identifier for the inverse command.
  var id: String { get }

  /// Returns the inverse command's current availability.
  var availability: () -> CommandAvailability { get }

  /// Performs the inverse from the supplied source and returns its replacement.
  ///
  /// The returned inverse reverses this action, allowing `UndoService` to move
  /// between undo and redo states without losing its history.
  var action: (CommandSource) async throws -> CommandInverse? { get }
}
