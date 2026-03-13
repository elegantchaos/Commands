// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

/// Abstract interaction trigger used to choose between related command variants.
public enum CommandTrigger: String, CaseIterable, Sendable {
  /// The default interaction for the current platform.
  /// On macOS this is a normal click, iOS a normal tap.
  case primary

  /// The secondary interaction for the current platform.
  /// On macOS this might be a command-click, on iOS a long-press.
  case secondary

  /// The tertiary interaction for the current platform.
  /// On macOS this might be an option-click, on iOS a double-tap.
  case tertiary
}
