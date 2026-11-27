// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/10/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

extension ToolbarContent {
  /// Hides the content on macOS while `isHidden` is true, so a hidden command leaves no slot.
  ///
  /// Other platforms have no way to hide toolbar content, so there the content is unchanged and
  /// a hidden command leaves an empty item.
  func commandHidden(_ isHidden: Bool) -> some ToolbarContent {
    #if os(macOS)
      hidden(isHidden)
    #else
      self
    #endif
  }
}
