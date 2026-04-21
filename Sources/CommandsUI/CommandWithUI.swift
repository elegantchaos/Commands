// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 17/10/2025.
//  Copyright © 2025 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Icons
import SwiftUI

#if os(watchOS) || os(tvOS)
  /// Lightweight keyboard shortcut placeholder for platforms that do not surface real shortcuts.
  public struct CommandShortcut {
    /// Creates a no-op shortcut placeholder.
    public init(_ key: CommandKey, modifiers: CommandModifiers = []) {
    }
  }

  /// Cross-platform shortcut modifier representation for watchOS and tvOS builds.
  public struct CommandModifiers: OptionSet, Sendable {
    /// Raw option-set storage.
    public let rawValue: Int

    /// Creates an option set from its raw value.
    public init(rawValue: Int) {
      self.rawValue = rawValue
    }

    public static let command = CommandModifiers(rawValue: 1 << 0)
    public static let option = CommandModifiers(rawValue: 1 << 1)
    public static let shift = CommandModifiers(rawValue: 1 << 2)
    public static let control = CommandModifiers(rawValue: 1 << 3)
  }

  public typealias CommandKey = String

#else

  public typealias CommandShortcut = KeyboardShortcut
  public typealias CommandModifiers = EventModifiers
  public typealias CommandKey = KeyEquivalent
#endif


/// A command that can be surfaced by a UI.
@MainActor
public protocol CommandWithUI: Command {
  /// The user-visible name of the command.
  func name(centre: Centre) -> String

  /// The icon for the command.
  func icon(centre: Centre) -> Icon

  /// An optional help string for the command.
  /// Can be shown in a tooltip or help menu.
  func help(centre: Centre) -> String?

  /// An optional confirmation dialog to show before performing the command.
  func confirmation(centre: Centre) -> CommandConfirmation?

  /// The bundle to use for localization and other resources.
  var bundle: Bundle { get }

  /// The keyboard shortcut for the command, if any.
  var shortcut: CommandShortcut? { get }
}

@MainActor
public extension CommandWithUI {

  /// By default, the name is a localized String using the command ID as the key.
  func name(centre: Centre) -> String { String(localized: String.LocalizationValue(id), bundle: bundle) }

  /// By default, no confirmation is required.
  func confirmation(centre: Centre) -> CommandConfirmation? { nil }

  /// By default, the help string is looked up using the command ID.
  func help(centre: Centre) -> String? { String(localized: String.LocalizationValue(id + ".help"), bundle: bundle) }

  /// By default, use the main bundle for localization and resources.
  var bundle: Bundle { .main }

  /// By default, no shortcut is provided.
  var shortcut: CommandShortcut? { nil }
}
