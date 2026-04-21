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
  let command: C
  let centre: CC
  
  @Binding var isShowingImportSheet: Bool
  
  public init(command: C, centre: CC, isShowingImportSheet: Binding<Bool>) {
    self.command = command
    self.centre = centre
    self._isShowingImportSheet = isShowingImportSheet
  }
  
  public var body: some View {
    Button(action: { isShowingImportSheet = !isShowingImportSheet }) {
      Label(command.name(centre: centre), icon: command.icon(centre: centre))
    }
    
  }
}
