// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/11/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Command whose effect can be reversed through its centre's `HistoryService`.
///
/// Commands opt into history by adopting this protocol; commands that change nothing
/// reversible adopt only `Command`. After a command succeeds, its centre asks it for
/// a reversal and records that command in the history. Performing a reversal asks the
/// reversal for its own reversal in turn, which lets undo and redo traverse the same entry.
///
/// When a command and its reversal name each other, Swift cannot infer their associated
/// types; declare `Centre` and `ResultType` explicitly on one of them.
@MainActor
public protocol CommandWithHistory: Command where Centre: CommandCentreWithHistory {
  /// The command that reverses this one.
  associatedtype ReversalCommand: CommandWithHistory
  where ReversalCommand.Centre == Centre

  /// Returns the command that reverses this one, or `nil` when it cannot be reversed.
  ///
  /// The centre calls this after the command has been performed successfully, so the
  /// reversal can capture state the command produced.
  func reversal(centre: Centre) -> ReversalCommand?
}
