// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Icons
import SwiftUI

/// A button that performs the next reversal held by an undo service.
///
/// The button remains visible but disabled when there is no reversal. It is
/// hidden only when the pending reversal reports `.hidden` availability.
@MainActor
public struct UndoCommandButton: View {
  /// Undo service that owns the pending reversal.
  private let undoService: UndoService

  /// Optional semantic role for the button.
  private let role: ButtonRole?

  /// Whether the pending reversal's UI metadata should replace the standard Undo label.
  private let showsCommandPresentation: Bool

  /// Creates an undo button for the supplied service.
  public init(
    undoService: UndoService,
    role: ButtonRole? = nil,
    showsCommandPresentation: Bool = false
  ) {
    self.undoService = undoService
    self.role = role
    self.showsCommandPresentation = showsCommandPresentation
  }

  /// Renders the pending reversal unless it is hidden.
  public var body: some View {
    let reversal = undoService.nextUndo
    let availability = reversal?.availability() ?? .disabled
    let presentation = showsCommandPresentation ? reversal as? any CommandReversalWithUI : nil

    if availability != .hidden {
      Button(role: role, action: performUndo) {
        label(presentation: presentation)
      }
      .commandPresentation(
        availability: availability,
        help: presentation?.help(),
        isPerforming: undoService.isUndoing
      )
    }
  }

  /// Button label for the pending reversal or the standard Undo action.
  @ViewBuilder private func label(presentation: (any CommandReversalWithUI)?) -> some View {
    if let presentation {
      Label(
        String.localizedStringWithFormat(
          String(localized: "action.undo", bundle: #bundle),
          presentation.historyActionName()
        ),
        icon: presentation.icon()
      )
    } else {
      Text("action.undo.simple", bundle: #bundle)
    }
  }

  /// Starts the undo operation and logs any user-facing execution failure.
  private func performUndo() {
    Task {
      do {
        try await undoService.performUndo()
      } catch {
        commandChannel.log("Error performing undo: \(error)")
      }
    }
  }
}
