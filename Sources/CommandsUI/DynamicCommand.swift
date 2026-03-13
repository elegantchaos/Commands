// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Foundation
import Icons

/// Command that resolves a wrapped UI command from an abstract interaction trigger.
@MainActor
public struct DynamicCommand<Wrapped: CommandWithUI>: CommandWithUI {
  /// Trigger used to select the wrapped command variant.
  public let trigger: CommandTrigger

  private let wrappedCommand: @MainActor (CommandTrigger) -> Wrapped

  /// Creates a dynamic command for the supplied trigger and command factory.
  public init(trigger: CommandTrigger, wrappedCommand: @escaping @MainActor (CommandTrigger) -> Wrapped) {
    self.trigger = trigger
    self.wrappedCommand = wrappedCommand
  }

  /// Stable identifier for the resolved wrapped command.
  public var id: String { resolvedCommand.id }

  /// Display name for the resolved wrapped command.
  public var name: String { resolvedCommand.name }

  /// Icon for the resolved wrapped command.
  public var icon: Icon { resolvedCommand.icon }

  /// Help text for the resolved wrapped command.
  public var help: String? { resolvedCommand.help }

  /// Confirmation details for the resolved wrapped command.
  public var confirmation: CommandConfirmation? { resolvedCommand.confirmation }

  /// Resource bundle used by the resolved wrapped command.
  public var bundle: Bundle { resolvedCommand.bundle }

  /// Shortcut used by the resolved wrapped command.
  public var shortcut: CommandShortcut? { resolvedCommand.shortcut }

  /// Returns availability for the resolved wrapped command.
  public func availability(centre: Wrapped.Centre) -> CommandAvailability {
    resolvedCommand.availability(centre: centre)
  }

  /// Performs the resolved wrapped command.
  public func perform(centre: Wrapped.Centre) async throws -> Wrapped.ResultType {
    try await resolvedCommand.perform(centre: centre)
  }

  /// Wrapped command selected for the current trigger.
  private var resolvedCommand: Wrapped {
    wrappedCommand(trigger)
  }
}
