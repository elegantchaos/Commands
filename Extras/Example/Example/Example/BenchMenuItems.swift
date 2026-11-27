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
  let centre: ExampleCentre

  /// The bench's menu items, between dividers.
  var body: some View {
    Divider()
    centre.button(BenchCommand<ExampleCentre>(title: "Menu Bar One", behaviour: .enabled))
    centre.button(BenchCommand<ExampleCentre>(title: "Menu Bar Hidden", behaviour: .hidden))
    centre.button(BenchCommand<ExampleCentre>(title: "Menu Bar Two", behaviour: .enabled))
    centre.button(
      BenchCommand<ExampleCentre>(title: "Menu Bar Toggling", behaviour: .togglingVisible))
    Divider()
  }
}

#Preview {
  Menu("Edit") {
    BenchMenuItems(centre: ExampleCentre())
  }
  .padding()
}
