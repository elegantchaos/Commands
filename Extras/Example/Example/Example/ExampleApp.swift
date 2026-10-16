// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CommandsUI
import SwiftUI

/// The example app: a bench of pages showing command controls in each place they are used, and
/// the bench's commands in the Edit menu.
@main
struct ExampleApp: App {
  /// The command centre shared by every page and the menu bar.
  @State private var commander = ExampleCommander()

  /// The bench window, with bench commands added to the Edit menu.
  var body: some Scene {
    WindowGroup {
      BenchView(commander: commander)
    }
    .commands {
      CommandGroup(after: .pasteboard) {
        BenchMenuItems(commander: commander)
      }
    }
  }
}
