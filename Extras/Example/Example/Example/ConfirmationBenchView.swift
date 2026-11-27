// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/11/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CommandsUI
import SwiftUI

/// Shows a command that asks for confirmation, presented each way a control can ask.
///
/// The same Clear Items command appears as a button with its own dialog, as a menu item whose
/// confirmation the window's `CommandsHost` presents, and as a button that skips confirmation.
/// The Edit menu has it too, confirmed by the host.
struct ConfirmationBenchView: View {
  /// The command centre.
  let centre: ExampleCentre

  /// The item count, and the controls that add and clear items.
  var body: some View {
    VStack(spacing: 16) {
      Text("Items: \(centre.items.count)")
      centre.button(AddItemCommand())
      centre.button(ClearItemsCommand()) {
        Label("Clear with a Dialog", systemImage: "trash")
      }
      Menu("Clear from a Menu") {
        centre.button(ClearItemsCommand())
      }
      .commandConfirmation(.hosted)
      centre.button(ClearItemsCommand(), confirmation: .never) {
        Label("Clear without Asking", systemImage: "trash.slash")
      }
    }
    .padding()
    .navigationTitle("Confirmation")
  }
}

#Preview {
  ConfirmationBenchView(centre: ExampleCentre())
}
