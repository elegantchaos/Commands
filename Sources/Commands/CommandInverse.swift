// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Describes the inverse of a command.
@MainActor
public protocol CommandInverse {
  var id: String { get }
  
  /// Determine whether the inverse should be regarded as enabled, disabled, etc.
  var availability: () -> CommandAvailability { get }
  
  /// Perform the inverse command.
  /// Typically this is done by invoking another command on the same command centre
  /// that was used when the `CommandInverse` instance was created; though this
  /// is not strictly enforced.
  var action: (CommandSource) async throws -> () { get }
}
