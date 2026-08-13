// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Opaque capability that authorizes a command within a coordinated execution.
///
/// Services that coordinate a sequence of commands create a context and pass it
/// only to work that belongs to that sequence. A command centre can use object
/// identity to decide whether the context is currently authorized. The owning
/// service retains the active context, so authorization requires neither global
/// nor task-scoped state. This type intentionally has no history semantics.
@MainActor
public final class CommandExecutionContext {
  /// Creates a context for use by a coordinating service in this module.
  init() {
  }
}
