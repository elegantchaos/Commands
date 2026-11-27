// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import Icons

/// A command whose availability is fixed, or follows the bench state, so the bench can show how
/// controls behave as availability changes.
struct BenchCommand<Centre: BenchStateProvider>: CommandWithUI {
  /// The command's name, which also identifies it.
  let title: String

  /// How the command's availability behaves.
  let behaviour: Behaviour

  /// The identifier, derived from the name.
  var id: String { "com.elegantchaos.commands.bench.\(title)" }

  /// The name shown on the command's controls.
  func name(centre: Centre) -> String { title }

  /// An icon that differs by behaviour.
  func icon(centre: Centre) -> Icon {
    switch behaviour {
    case .enabled: Icon("star")
    case .hidden: Icon("eye.slash")
    case .togglingEnabled: Icon("arrow.triangle.2.circlepath")
    case .togglingVisible: Icon("eye")
    }
  }

  /// Help naming the behaviour, so tooltips can be checked.
  func help(centre: Centre) -> String? { "\(title): \(behaviour)" }

  /// The availability the behaviour gives.
  func availability(centre: Centre) -> CommandAvailability {
    switch behaviour {
    case .enabled: .enabled
    case .hidden: .hidden
    case .togglingEnabled: centre.bench.isEnabled ? .enabled : .disabled
    case .togglingVisible: centre.bench.isVisible ? .enabled : .hidden
    }
  }

  /// Does nothing; the bench only shows the command's controls.
  func perform(centre: Centre) async throws {}
}

extension BenchCommand {
  /// How a bench command's availability behaves.
  enum Behaviour: CustomStringConvertible {
    /// Always enabled.
    case enabled

    /// Always hidden.
    case hidden

    /// Enabled while the bench state's `isEnabled` is true, else disabled.
    case togglingEnabled

    /// Enabled while the bench state's `isVisible` is true, else hidden.
    case togglingVisible

    /// A short description, for help text.
    var description: String {
      switch self {
      case .enabled: "always enabled"
      case .hidden: "always hidden"
      case .togglingEnabled: "enabled or disabled"
      case .togglingVisible: "enabled or hidden"
      }
    }
  }
}
