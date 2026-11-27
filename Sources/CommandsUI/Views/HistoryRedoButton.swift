// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Icons
import SwiftUI

/// A button that performs the next redo action held by a history service.
///
/// The button remains visible but disabled when there is no redo action. It is
/// hidden only when the pending action reports `.hidden` availability.
@MainActor
public struct HistoryRedoButton: View {
  /// History service that owns the pending redo action.
  private let historyService: HistoryService

  /// Optional semantic role for the button.
  private let role: ButtonRole?

  /// Whether the pending action's UI metadata should replace the standard Redo label.
  private let showsCommandPresentation: Bool

  /// Creates a redo button for the supplied history service.
  public init(
    historyService: HistoryService,
    role: ButtonRole? = nil,
    showsCommandPresentation: Bool = false
  ) {
    self.historyService = historyService
    self.role = role
    self.showsCommandPresentation = showsCommandPresentation
  }

  /// Renders the pending redo action unless it is hidden.
  public var body: some View {
    let entry = historyService.nextRedo
    let availability = entry?.availability() ?? .disabled
    let presentation = showsCommandPresentation ? entry?.presentation : nil

    if availability != .hidden {
      Button(role: role, action: performRedo) {
        label(presentation: presentation)
      }
      .commandPresentation(
        availability: availability,
        help: presentation?.help,
        isPerforming: historyService.isRedoing
      )
    }
  }

  /// Button label for the pending action or the standard Redo action.
  @ViewBuilder private func label(presentation: HistoryEntryPresentation?) -> some View {
    if let presentation {
      Label(
        String.localizedStringWithFormat(
          String(localized: "action.redo", bundle: #bundle),
          presentation.name
        ),
        icon: presentation.icon
      )
    } else {
      Text("action.redo.simple", bundle: #bundle)
    }
  }

  /// Starts the redo operation and logs any user-facing execution failure.
  private func performRedo() {
    Task {
      do {
        try await historyService.performRedo()
      } catch {
        commandChannel.log("Error performing redo: \(error)")
      }
    }
  }
}
