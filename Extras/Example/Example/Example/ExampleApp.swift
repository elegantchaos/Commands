// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

// TODO: Fix import sheet from button on macOS
// TODO: Fix import sheet from menu on iPad
// TODO: Integrate with the system Undo/Redo menus.

@main
/// Launches the Commands example application.
struct ExampleApp: App {
  /// Shared commander used by every command surface in the app.
  @State private var commander = Commander()

  var body: some Scene {
    WindowGroup {
      ContentView(commander: commander)
    }
    .commands { AppCommands(commander: commander) }
  }
}
