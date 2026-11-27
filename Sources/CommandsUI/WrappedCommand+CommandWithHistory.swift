// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/11/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands

/// A wrapped command records history whenever the command it wraps does.
@MainActor
extension WrappedCommand: CommandWithHistory where C: CommandWithHistory {
  /// Returns the wrapped command's reversal.
  public func reversal(centre: C.Centre) -> C.ReversalCommand? {
    command.reversal(centre: centre)
  }
}
