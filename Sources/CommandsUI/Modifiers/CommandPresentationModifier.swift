// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import SwiftUI

/// Applies shared availability, help, and shortcut presentation to a command control.
///
/// Leaves the control out while its command is hidden, and otherwise disables it unless the
/// command is enabled and nothing is already performing it. The control sits inside a stack
/// that adds no spacing, whether or not it is hidden, so it keeps one outer view: on macOS, a
/// toolbar item whose content's outermost view is conditional makes SwiftUI rebuild every item
/// in the window's toolbar each time that content re-evaluates, even when the condition has not
/// changed, so the whole toolbar flickers whenever a command's availability changes.
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
    VStack(spacing: 0) {
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
