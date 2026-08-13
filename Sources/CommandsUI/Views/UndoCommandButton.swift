// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Icons
import SwiftUI

/// A button that performs the next inverse held by an undo service.
///
/// The button remains visible but disabled when there is no inverse. It is
/// hidden only when the pending inverse reports `.hidden` availability.
@MainActor
public struct UndoCommandButton: View {
  /// Undo service that owns the pending inverse.
  private let undoService: UndoService

  /// Optional semantic role for the button.
  private let role: ButtonRole?

  /// Whether the pending inverse's UI metadata should replace the standard Undo label.
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

  /// Renders the pending inverse unless it is hidden.
  public var body: some View {
    let inverse = undoService.nextUndo
    let availability = inverse?.availability() ?? .disabled
    let presentation = showsCommandPresentation ? inverse as? any CommandInverseWithUI : nil

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

  /// Button label for the pending inverse or the standard Undo action.
  @ViewBuilder private func label(presentation: (any CommandInverseWithUI)?) -> some View {
    if let presentation {
      Label(.actionUndo(action: presentation.name()), icon: presentation.icon())
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
