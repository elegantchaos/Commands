// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Icons
import SwiftUI

/// A button that performs the next reversal held by a history service.
///
/// The button remains visible but disabled when there is no reversal. It is
/// hidden only when the pending reversal reports `.hidden` availability.
@MainActor
public struct HistoryUndoButton: View {
  /// History service that owns the pending reversal.
  private let historyService: HistoryService

  /// Optional semantic role for the button.
  private let role: ButtonRole?

  /// Whether the pending reversal's UI metadata should replace the standard Undo label.
  private let showsCommandPresentation: Bool

  /// Creates an undo button for the supplied history service.
  public init(
    historyService: HistoryService,
    role: ButtonRole? = nil,
    showsCommandPresentation: Bool = false
  ) {
    self.historyService = historyService
    self.role = role
    self.showsCommandPresentation = showsCommandPresentation
  }

  /// Renders the pending reversal unless it is hidden.
  public var body: some View {
    let entry = historyService.nextUndo
    let availability = entry?.availability() ?? .disabled
    let presentation = showsCommandPresentation ? entry?.presentation : nil

    if availability != .hidden {
      Button(role: role, action: performUndo) {
        label(presentation: presentation)
      }
      .commandPresentation(
        availability: availability,
        help: presentation?.help,
        isPerforming: historyService.isUndoing
      )
    }
  }

  /// Button label for the pending reversal or the standard Undo action.
  @ViewBuilder private func label(presentation: HistoryEntryPresentation?) -> some View {
    if let presentation {
      Label(
        String.localizedStringWithFormat(
          String(localized: "action.undo", bundle: #bundle),
          presentation.name
        ),
        icon: presentation.icon
      )
    } else {
      Text("action.undo.simple", bundle: #bundle)
    }
  }

  /// Starts the undo operation and logs any user-facing execution failure.
  private func performUndo() {
    Task {
      do {
        try await historyService.performUndo()
      } catch {
        commandChannel.log("Error performing undo: \(error)")
      }
    }
  }
}
