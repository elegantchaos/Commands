// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 17/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import SwiftUI
import UniformTypeIdentifiers

public protocol ImporterCommand: CommandWithUI {
  var types: [UTType] { get }
  var allowsMultipleSelection: Bool { get }
  mutating func setURLS(_ urls: [URL])
}

/// Button wrapper that presents an importer sheet before invoking a command.
struct ImporterCommandButton<C: ImporterCommand, CC: CommandCentre>: View where C.Centre == CC {
  @State var isShowingSheet = false

  let command: C
  let centre: CC
  let role: ButtonRole?

  var body: some View {
    let availability = centre.availability(command)
    if availability != .hidden {
      Button(role: role, action: { isShowingSheet = true }) {
        Label(command.name, icon: command.icon)
      }
      .disabled(centre.shouldDisable(command))
      #if !os(watchOS) && !os(tvOS)
        .keyboardShortcut(command.shortcut)
      #endif
      .help(command.help ?? "")
      .fileImporter(
        isPresented: $isShowingSheet,
        allowedContentTypes: command.types,
        allowsMultipleSelection: command.allowsMultipleSelection
      ) { result in
        switch result {
        case .success(let urls):
          var c = command
          c.setURLS(urls)
          centre.performWithoutWaiting(c)
        case .failure:
          break  // TODO: handle error
        }
      }
    }
  }
}
