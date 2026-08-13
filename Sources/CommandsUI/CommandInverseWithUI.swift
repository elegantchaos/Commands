// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Icons

/// An inverse command that exposes presentation metadata for a user interface.
@MainActor
public protocol CommandInverseWithUI: CommandInverse {
  /// Returns the user-visible name of the inverse command.
  func name() -> String

  /// Returns the icon representing the inverse command.
  func icon() -> Icon

  /// Returns optional help text for the inverse command.
  func help() -> String?
}
