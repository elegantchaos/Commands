// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 17/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import SwiftUI

/// Button wrapper that sets a binding to true when pressed.
/// Intended for use with `ImporterCommandModifier` for situations where
/// you need to place an ImporterCommand inside a contextual menu.
public struct ImporterCommandShowButton<C: ImporterCommand, CC: CommandCentre>: View where C.Centre == CC {
  /// Command whose importer sheet should be shown.
  let command: C

  /// Command centre used to resolve command metadata.
  let centre: CC
  
  /// Presentation state for the importer sheet.
  @Binding var isShowingImportSheet: Bool
  
  /// Creates a button that flips the importer presentation state.
  public init(command: C, centre: CC, isShowingImportSheet: Binding<Bool>) {
    self.command = command
    self.centre = centre
    self._isShowingImportSheet = isShowingImportSheet
  }
  
  /// Renders the button that triggers importer-sheet presentation.
  public var body: some View {
    Button(action: { isShowingImportSheet = !isShowingImportSheet }) {
      Label(command.name(centre: centre), icon: command.icon(centre: centre))
    }
  }
}
