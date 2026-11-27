// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

/// The bench's pages in a split view, and the timer that toggles the bench state.
struct BenchView: View {
  /// The command centre shared by every page.
  let centre: ExampleCentre

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
      BenchPageView(page: page ?? .toolbar, centre: centre)
    }
    .task(runToggling)
  }

  /// Runs the bench state's timer for as long as the view is shown.
  private func runToggling() async {
    await centre.bench.runToggling()
  }
}

/// The page for a bench page identifier.
private struct BenchPageView: View {
  /// The page to show.
  let page: BenchPage

  /// The command centre.
  let centre: ExampleCentre

  /// The page's view.
  var body: some View {
    switch page {
    case .toolbar: ToolbarBenchView(centre: centre)
    case .containers: ContainersBenchView(centre: centre)
    case .undoManager: UndoManagerExampleView()
    case .history: HistoryExampleView(centre: centre)
    }
  }
}

/// The bench's pages.
enum BenchPage: String, CaseIterable, Identifiable {
  /// Command buttons in a toolbar, with changing availability.
  case toolbar

  /// Hidden commands in a list and a menu.
  case containers

  /// Commands that undo through the window's `UndoManager`, beside text inputs.
  case undoManager

  /// Commands that undo through the centre's own `HistoryService`.
  case history

  /// The page's identity.
  var id: Self { self }

  /// The page's name in the list.
  var title: String {
    switch self {
    case .toolbar: "Toolbar"
    case .containers: "Lists and Menus"
    case .undoManager: "UndoManager"
    case .history: "History"
    }
  }
}

#Preview {
  BenchView(centre: ExampleCentre())
}
