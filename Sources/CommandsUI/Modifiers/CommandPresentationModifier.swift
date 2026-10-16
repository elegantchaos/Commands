// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import SwiftUI

/// Applies shared availability, help, and shortcut presentation to a command control.
///
/// Leaves the control out while its command is hidden, so a hidden command adds no row to a
/// list and no item to a menu, and otherwise disables it unless the command is enabled and
/// nothing is already performing it. Because the result is conditional, a control placed
/// directly in a toolbar item can make a macOS toolbar rebuild and flicker; place command
/// buttons in toolbars with `CommandToolbarItem`, which gives them a fixed outer view.
private struct CommandPresentationModifier: ViewModifier {
  /// Availability resolved during the enclosing view's current body evaluation.
  let availability: CommandAvailability

  /// Optional help text for the command control.
  let help: String?

  /// Optional keyboard shortcut for the command control.
  let shortcut: CommandShortcut?

  /// Whether a control-specific operation, such as undo, is already in progress.
  let isPerforming: Bool

  /// Applies the command presentation without re-evaluating command state.
  func body(content: Content) -> some View {
    if availability != .hidden {
      content
        .disabled(availability != .enabled || isPerforming)
        #if !os(watchOS) && !os(tvOS)
          .keyboardShortcut(shortcut)
        #endif
        .help(help ?? "")
    }
  }
}

extension View {
  /// Applies shared presentation for command availability, help, and shortcuts: leaves the
  /// control out while the command is hidden, and disables it unless it is enabled. Apply it
  /// last, so a hidden command leaves out everything attached to its control.
  func commandPresentation(
    availability: CommandAvailability,
    help: String? = nil,
    shortcut: CommandShortcut? = nil,
    isPerforming: Bool = false
  ) -> some View {
    modifier(
      CommandPresentationModifier(
        availability: availability,
        help: help,
        shortcut: shortcut,
        isPerforming: isPerforming
      ))
  }
}
