// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CommandsUI
import SwiftUI

/// Command buttons in a toolbar, placed with `toolbarItem(_:)`, whose availability changes on a
/// timer.
///
/// The manual checks: with only "Toggle enabled" on, nothing is added or removed, so only Tool
/// Toggling should change; any change to the rest of the toolbar, including the sidebar button,
/// is a flicker. With "Toggle visible" on, the toolbar resizes as Tool Appearing comes and goes.
/// A hidden command should leave no gap on macOS.
struct ToolbarBenchView: View {
  /// The command centre.
  let commander: ExampleCommander

  /// The controls for the bench state, and what they currently give.
  var body: some View {
    @Bindable var bench = commander.bench
    Form {
      Toggle("Toggle enabled every 1.5 seconds", isOn: $bench.isTogglingEnabled)
        .accessibilityIdentifier("bench.togglingEnabled")
      Toggle("Toggle visible every 1.5 seconds", isOn: $bench.isTogglingVisible)
        .accessibilityIdentifier("bench.togglingVisible")
      LabeledContent("Tool Toggling is", value: bench.isEnabled ? "enabled" : "disabled")
      LabeledContent("Tool Appearing is", value: bench.isVisible ? "shown" : "hidden")
    }
    .formStyle(.grouped)
    .navigationTitle("Toolbar")
    .toolbar {
      BenchToolbar(commander: commander)
    }
  }
}

/// The bench toolbar: an enabled, a hidden, an enabled-or-disabled and an enabled-or-hidden
/// command.
private struct BenchToolbar: ToolbarContent {
  /// The command centre.
  let commander: ExampleCommander

  /// The four commands' items.
  var body: some ToolbarContent {
    commander.toolbarItem(command("Tool Enabled", .enabled))
    commander.toolbarItem(command("Tool Hidden", .hidden))
    commander.toolbarItem(command("Tool Toggling", .togglingEnabled))
    commander.toolbarItem(command("Tool Appearing", .togglingVisible))
  }

  /// A bench command.
  private func command(_ title: String, _ behaviour: BenchCommand<ExampleCommander>.Behaviour)
    -> BenchCommand<ExampleCommander>
  {
    BenchCommand(title: title, behaviour: behaviour)
  }
}
