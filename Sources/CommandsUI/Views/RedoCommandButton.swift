// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Icons
import SwiftUI

/// A button that performs the next redo action held by an undo service.
///
/// The button remains visible but disabled when there is no redo action. It is
/// hidden only when the pending action reports `.hidden` availability.
@MainActor
public struct RedoCommandButton: View {
  /// Undo service that owns the pending redo action.
  private let undoService: UndoService

  /// Optional semantic role for the button.
  private let role: ButtonRole?

  /// Whether the pending action's UI metadata should replace the standard Redo label.
  private let showsCommandPresentation: Bool

  /// Creates a redo button for the supplied service.
  public init(
    undoService: UndoService,
    role: ButtonRole? = nil,
    showsCommandPresentation: Bool = false
  ) {
    self.undoService = undoService
    self.role = role
    self.showsCommandPresentation = showsCommandPresentation
  }

  /// Renders the pending redo action unless it is hidden.
  public var body: some View {
    let reversal = undoService.nextRedo
    let availability = reversal?.availability() ?? .disabled
    let presentation = showsCommandPresentation ? reversal as? any CommandReversalWithUI : nil

    if availability != .hidden {
      Button(role: role, action: performRedo) {
        label(presentation: presentation)
      }
      .commandPresentation(
        availability: availability,
        help: presentation?.help(),
        isPerforming: undoService.isRedoing
      )
    }
  }

  /// Button label for the pending action or the standard Redo action.
  @ViewBuilder private func label(presentation: (any CommandReversalWithUI)?) -> some View {
    if let presentation {
      Label(
        String.localizedStringWithFormat(
          String(localized: "action.redo", bundle: #bundle),
          presentation.historyActionName()
        ),
        icon: presentation.icon()
      )
    } else {
      Text("action.redo.simple", bundle: #bundle)
    }
  }

  /// Starts the redo operation and logs any user-facing execution failure.
  private func performRedo() {
    Task {
      do {
        try await undoService.performRedo()
      } catch {
        commandChannel.log("Error performing redo: \(error)")
      }
    }
  }
}
