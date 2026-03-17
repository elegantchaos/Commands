// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 17/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import SwiftUI
import UniformTypeIdentifiers

public enum ImporterCommandURLState {
  case unknown
  case chosen([URL])
  case error(Error)
}

public protocol ImporterCommand: CommandWithUI {
  var types: [UTType] { get }
  var allowsMultipleSelection: Bool { get }
  var state: ImporterCommandURLState { get set }
}

/// Button wrapper that presents an importer sheet before invoking a command.
struct ImporterCommandButton<C: ImporterCommand, CC: CommandCentre>: View where C.Centre == CC {
  @State var isShowingSheet = false
  @State var command: C

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
          command.state = .chosen(urls)
        case .failure(let error):
          command.state = .error(error)
        }
        centre.performWithoutWaiting(command)
      }
    }
  }
}
