// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

/// Selects the system Undo and Redo integration exercised by the example app.
///
/// Launch the app with `-undo-prototype` followed by one of this type's raw values
/// to make a run reproducible from an Xcode scheme.
enum SystemUndoPrototype: String, CaseIterable, Identifiable {
  /// Replaces SwiftUI's Undo and Redo commands with CommandsUI controls.
  case swiftUI

  /// Rewrites Undo and Redo menu invocations through a context-sensitive router.
  case router

  /// Registers synchronous native undo proxies that start Commands reversals.
  case undoManager

  /// Stable identity used by SwiftUI collections.
  var id: Self { self }

  /// The prototype selected by the current process arguments.
  static var selected: Self {
    let arguments = ProcessInfo.processInfo.arguments
    guard
      let optionIndex = arguments.firstIndex(of: "-undo-prototype"),
      arguments.indices.contains(optionIndex + 1),
      let prototype = Self(rawValue: arguments[optionIndex + 1])
    else {
      return .router
    }

    return prototype
  }

  /// A localized name suitable for diagnostic UI in the example.
  var name: LocalizedStringKey {
    switch self {
    case .swiftUI:
      "example.undo.prototype.swiftui"
    case .router:
      "example.undo.prototype.router"
    case .undoManager:
      "example.undo.prototype.manager"
    }
  }

  /// A concise explanation of the active experiment.
  var summary: LocalizedStringKey {
    switch self {
    case .swiftUI:
      "example.undo.prototype.swiftui.summary"
    case .router:
      "example.undo.prototype.router.summary"
    case .undoManager:
      "example.undo.prototype.manager.summary"
    }
  }
}

/// Displays the selected Undo and Redo experiment and its reproducible launch argument.
struct SystemUndoPrototypePanel: View {
  /// The experiment selected for this app run.
  let prototype: SystemUndoPrototype

  var body: some View {
    GroupBox {
      VStack(alignment: .leading) {
        LabeledContent("example.undo.prototype.active") {
          Text(prototype.name)
        }

        Text(prototype.summary)
          .font(.footnote)
          .foregroundStyle(.secondary)

        Text("example.undo.prototype.launch")
          .font(.footnote.monospaced())
          .foregroundStyle(.secondary)
      }
    } label: {
      Label("example.undo.prototype.title", systemImage: "arrow.uturn.backward.circle")
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}
