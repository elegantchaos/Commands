// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import SwiftUI

/// Applies shared availability, help, and shortcut presentation to a command control.
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
    content
      .disabled(availability != .enabled || isPerforming)
      #if !os(watchOS) && !os(tvOS)
        .keyboardShortcut(shortcut)
      #endif
      .help(help ?? "")
  }
}

extension View {
  /// Applies shared presentation for command availability, help, and shortcuts.
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
