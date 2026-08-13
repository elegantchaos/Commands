// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Adapts a command and its centre into a `CommandInverse`.
@MainActor
public struct CommandInverseProxy<C: Command>: CommandInverse {
  let command: C
  let centre: C.Centre

  public init(command: C, centre: C.Centre) {
    self.command = command
    self.centre = centre
  }

  public var id: String {
    command.id
  }

  public var availability: () -> CommandAvailability {
    {
      centre.availability(command)
    }
  }

  public var action: @concurrent (CommandSource) async throws -> CommandInverse? {
    { source in
      _ = try await centre.perform(command, from: source)
      return command.inverse(centre: centre)
    }
  }
}
