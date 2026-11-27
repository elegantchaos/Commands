// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CommandsUI
import SwiftUI

/// Hidden commands in a list and a menu, beside the same containers without them, so a gap left
/// by a hidden command can be seen; the Edit menu has the same arrangement.
struct ContainersBenchView: View {
  /// The command centre.
  let centre: ExampleCentre

  /// The list and menu, with and without a hidden command.
  var body: some View {
    HStack(alignment: .top) {
      ContainerColumn(title: "With a hidden command", centre: centre, includesHidden: true)
      ContainerColumn(title: "Without", centre: centre, includesHidden: false)
    }
    .padding()
    .navigationTitle("Lists and Menus")
  }
}

/// A list and a menu of bench commands, optionally with a hidden one between the others.
private struct ContainerColumn: View {
  /// The column's heading.
  let title: String

  /// The command centre.
  let centre: ExampleCentre

  /// Whether a hidden command sits between the enabled ones.
  let includesHidden: Bool

  /// The column's identifier prefix for UI tests.
  private var identifier: String { includesHidden ? "withHidden" : "without" }

  /// The heading, list and menu.
  var body: some View {
    VStack(alignment: .leading) {
      Text(title).font(.headline)
      List {
        centre.button(command("List One", .enabled))
        if includesHidden { centre.button(command("List Hidden", .hidden)) }
        centre.button(command("List Two", .enabled))
      }
      .accessibilityIdentifier("bench.list.\(identifier)")
      Menu("Menu") {
        centre.button(command("Menu One", .enabled))
        if includesHidden { centre.button(command("Menu Hidden", .hidden)) }
        centre.button(command("Menu Two", .enabled))
      }
      .accessibilityIdentifier("bench.menu.\(identifier)")
    }
  }

  /// A bench command.
  private func command(_ title: String, _ behaviour: BenchCommand<ExampleCentre>.Behaviour)
    -> BenchCommand<ExampleCentre>
  {
    BenchCommand(title: title, behaviour: behaviour)
  }
}

#Preview {
  ContainersBenchView(centre: ExampleCentre())
}
