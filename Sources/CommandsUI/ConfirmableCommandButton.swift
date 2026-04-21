// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/09/2025.
//  Copyright © 2025 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Icons
import SwiftUI

/// Button wrapper that presents a confirmation dialog before invoking a command.
@MainActor
struct ConfirmableCommandButton<C: CommandWithUI, CC: CommandCentre>: View where C.Centre == CC {
  /// Tracks whether the confirmation alert is currently visible.
  @State var isPresented = false

  /// Command to present and eventually execute.
  let command: C

  /// Command centre that performs the command after confirmation.
  let commander: CC

  /// Renders the labelled button and its attached confirmation alert.
  var body: some View {
    let confirmation = command.confirmation(centre: commander) ?? .init(
      title: command.name(centre: commander),
      cancel: String(localized: "confirmation.default.cancel"),
      message: String(localized: "confirmation.default.message"),
      confirm: String(localized: "confirmation.default.confirm")
    )
    
    Button(action: handleShowAlert) {
      Label(command.name(centre: commander), icon: command.icon(centre: commander))
    }
    .alert(confirmation.title, isPresented: $isPresented) {
      Button(confirmation.cancel, role: .cancel) {}
      Button(confirmation.confirm, role: .destructive) { handlePerformCommand() }
    } message: {
      Text(confirmation.message)
    }
  }

  /// Presents the confirmation alert with animation.
  func handleShowAlert() {
    withAnimation {
      isPresented = true
    }
  }

  /// Executes the confirmed command and dismisses the alert afterward.
  func handlePerformCommand() {
    Task {
      do {
        _ = try await commander.perform(command)
      } catch {
        commandChannel.log("Error performing confirmed command \(command.id): \(error)")
      }

      withAnimation {
        isPresented = false
      }
    }
  }
}
