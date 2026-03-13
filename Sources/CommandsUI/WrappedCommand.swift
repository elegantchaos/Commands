// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/10/2025.
//  Copyright © 2025 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Icons
import Foundation
import SwiftUI

/// Decorates another command while allowing selected UI or execution details to be overridden.
///
/// Subclasses can override only the aspects they need to customise while keeping
/// the wrapped command as the source of truth for everything else.
@MainActor
open class WrappedCommand<C: CommandWithUI>: CommandWithUI {
  /// Command centre type accepted by the wrapped command.
  public typealias Centre = C.Centre

  /// Identifier forwarded from the wrapped command.
  open var id: String { command.id }

  /// Icon forwarded from the wrapped command.
  open var icon: Icon { command.icon }

  /// Display name forwarded from the wrapped command.
  open var name: String { command.name }

  /// Keyboard shortcut forwarded from the wrapped command.
  open var shortcut: CommandShortcut? { command.shortcut }

  /// Help text forwarded from the wrapped command.
  open var help: String? { command.help }

  /// Confirmation model forwarded from the wrapped command.
  open var confirmation: CommandConfirmation? { command.confirmation }

  /// Resource bundle forwarded from the wrapped command.
  open var bundle: Bundle { command.bundle }

  /// Wrapped command that remains the source of truth by default.
  let command: C

  /// Creates a wrapper around the supplied command.
  public init(_ command: C) {
    self.command = command
  }

  /// Returns the wrapped command's availability unless overridden.
  open func availability(centre: C.Centre) -> CommandAvailability {
    command.availability(centre: centre)
  }

  /// Executes the wrapped command unless overridden.
  open func perform(centre: C.Centre) async throws -> C.ResultType {
    try await command.perform(centre: centre)
  }
}
