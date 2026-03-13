// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 17/10/2025.
//  Copyright © 2025 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Information needed to display a confirmation dialog for a command.
public struct CommandConfirmation {
  /// Title shown in the confirmation dialog.
  public let title: String

  /// Label for the cancel action.
  public let cancel: String

  /// Explanatory body text for the dialog.
  public let message: String

  /// Label for the destructive or confirm action.
  public let confirm: String

  /// Creates a confirmation model from already-localized strings.
  public init(title: String, cancel: String, message: String, confirm: String) {
    self.title = title
    self.cancel = cancel
    self.message = message
    self.confirm = confirm
  }

  /// Creates a confirmation model by resolving localized resources immediately.
  public init(titleKey: LocalizedStringResource, cancelKey: LocalizedStringResource, messageKey: LocalizedStringResource, confirmKey: LocalizedStringResource) {
    self.init(title: String(localized: titleKey), cancel: String(localized: cancelKey), message: String(localized: messageKey), confirm: String(localized: confirmKey))
  }
}
