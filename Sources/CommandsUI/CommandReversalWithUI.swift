// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Icons

/// A command reversal that exposes presentation metadata for a user interface.
@MainActor
public protocol CommandReversalWithUI: CommandReversal {
  /// Returns the user-visible name of the reversal.
  func name() -> String

  /// Returns the user-visible name of the original history action.
  ///
  /// The history action can differ from the reversal that executes it. For
  /// example, undoing “Add Item” executes a “Remove Item” reversal while the
  /// appropriate menu label remains “Undo Add Item”.
  func historyActionName() -> String

  /// Returns the icon representing the reversal.
  func icon() -> Icon

  /// Returns optional help text for the reversal.
  func help() -> String?
}

@MainActor
extension CommandReversalWithUI {
  /// Uses the reversal's name when an implementation has no distinct history label.
  public func historyActionName() -> String {
    name()
  }
}
