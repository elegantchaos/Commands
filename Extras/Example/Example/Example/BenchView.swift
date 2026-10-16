// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

/// The bench's pages in a split view, and the timer that toggles the bench state.
struct BenchView: View {
  /// The command centre shared by every page.
  let commander: ExampleCommander

  /// The page shown in the detail column.
  @State private var page: BenchPage? = .toolbar

  /// The page list, and the chosen page.
  var body: some View {
    NavigationSplitView {
      List(BenchPage.allCases, selection: $page) { page in
        Text(page.title)
          .tag(page)
          .accessibilityIdentifier("bench.page.\(page.rawValue)")
      }
      .navigationTitle("Bench")
    } detail: {
      BenchPageView(page: page ?? .toolbar, commander: commander)
    }
    .task(runToggling)
  }

  /// Runs the bench state's timer for as long as the view is shown.
  private func runToggling() async {
    await commander.bench.runToggling()
  }
}

/// The page for a bench page identifier.
private struct BenchPageView: View {
  /// The page to show.
  let page: BenchPage

  /// The command centre.
  let commander: ExampleCommander

  /// The page's view.
  var body: some View {
    switch page {
    case .toolbar: ToolbarBenchView(commander: commander)
    case .containers: ContainersBenchView(commander: commander)
    case .undo: UndoBenchView(commander: commander)
    }
  }
}

/// The bench's pages.
enum BenchPage: String, CaseIterable, Identifiable {
  /// Command buttons in a toolbar, with changing availability.
  case toolbar

  /// Hidden commands in a list and a menu.
  case containers

  /// Performing, undoing and redoing a command.
  case undo

  /// The page's identity.
  var id: Self { self }

  /// The page's name in the list.
  var title: String {
    switch self {
    case .toolbar: "Toolbar"
    case .containers: "Lists and Menus"
    case .undo: "Undo and Redo"
    }
  }
}
