// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CommandsUI
import SwiftUI

/// Bench commands in the Edit menu: a hidden command between two enabled ones shows whether a
/// hidden command leaves a gap, and a toggling one shows a menu item changing availability.
struct BenchMenuItems: View {
  /// The command centre.
  let commander: ExampleCommander

  /// The bench's menu items, between dividers.
  var body: some View {
    Divider()
    commander.button(BenchCommand<ExampleCommander>(title: "Menu Bar One", behaviour: .enabled))
    commander.button(BenchCommand<ExampleCommander>(title: "Menu Bar Hidden", behaviour: .hidden))
    commander.button(BenchCommand<ExampleCommander>(title: "Menu Bar Two", behaviour: .enabled))
    commander.button(
      BenchCommand<ExampleCommander>(title: "Menu Bar Toggling", behaviour: .togglingVisible))
    Divider()
  }
}
