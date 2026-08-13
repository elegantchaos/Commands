// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Icons

/// Adapts a UI-capable command and its centre into a presentable inverse command.
@MainActor
public struct CommandInverseProxyWithUI<C: CommandWithUI>: CommandInverseWithUI {
  /// Core inverse behavior for the wrapped command.
  private let inverse: CommandInverseProxy<C>

  /// UI-capable command whose metadata is presented.
  private let command: C

  /// Command centre used to resolve dynamic metadata.
  private let centre: C.Centre

  /// Creates an inverse that forwards execution and UI metadata from a command.
  public init(command: C, centre: C.Centre) {
    inverse = CommandInverseProxy(command: command, centre: centre)
    self.command = command
    self.centre = centre
  }

  /// Stable identifier forwarded from the wrapped command.
  public var id: String {
    inverse.id
  }

  /// Availability closure forwarded from the wrapped command.
  public var availability: () -> CommandAvailability {
    inverse.availability
  }

  /// Action closure forwarded from the wrapped command.
  public var action: @concurrent (CommandSource) async throws -> CommandInverse? {
    inverse.action
  }

  /// Returns the command's current display name.
  public func name() -> String {
    command.name(centre: centre)
  }

  /// Returns the command's current icon.
  public func icon() -> Icon {
    command.icon(centre: centre)
  }

  /// Returns the command's current help text.
  public func help() -> String? {
    command.help(centre: centre)
  }
}
