// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 17/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import SwiftUI
import UniformTypeIdentifiers

/// Resolution state for an importer-backed command before and after the picker runs.
public enum ImporterCommandURLState {
  /// No importer result has been received yet.
  case unknown

  /// The importer completed successfully with the selected URLs.
  case chosen([URL])

  /// The importer failed with the captured error.
  case error(Error)
}

/// A UI-capable command that is driven by SwiftUI's file importer.
public protocol ImporterCommand: CommandWithUI {
  /// Supported content types for the importer presentation.
  var types: [UTType] { get }

  /// Whether the importer allows selecting multiple URLs.
  var allowsMultipleSelection: Bool { get }

  /// Mutable importer result state carried between picker presentation and execution.
  var state: ImporterCommandURLState { get set }
}

/// Button wrapper that presents an importer sheet before invoking a command.
struct ImporterCommandButton<C: ImporterCommand, CC: CommandCentre>: View where C.Centre == CC {
  /// Tracks presentation of the file importer sheet.
  @State var isShowingSheet = false

  /// Mutable command state updated by the importer modifier.
  @State var command: C

  /// Command centre that resolves metadata and performs the command.
  let centre: CC

  /// Optional semantic role applied to the visible button.
  let role: ButtonRole?

  var body: some View {
    let availability = centre.availability(command)
    if availability != .hidden {
      Button(role: role, action: { isShowingSheet = true }) {
        Label(command.name(centre: centre), icon: command.icon(centre: centre))
      }
      .disabled(centre.shouldDisable(command))
      .help(command.help(centre: centre) ?? "")
      #if !os(watchOS) && !os(tvOS)
        .keyboardShortcut(command.shortcut)
        .modifier(ImporterCommandModifier(isShowing: $isShowingSheet, command: $command, centre: centre))
      #endif
    }
  }
}
