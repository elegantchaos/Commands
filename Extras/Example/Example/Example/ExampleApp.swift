// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

@main
/// Launches the Commands example application.
struct ExampleApp: App {
  /// Shared commander used by every command surface in the app.
  @State private var commander = ExampleCommander()

  var body: some Scene {
    WindowGroup {
      ContentView(commander: commander)
    }
    .commands { ExampleCommands(commander: commander) }
  }
}
