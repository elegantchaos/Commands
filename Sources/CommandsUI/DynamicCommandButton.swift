// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/03/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import SwiftUI

#if os(macOS)
  import AppKit
#endif

/// Button that resolves a dynamic command trigger at activation time.
@MainActor
struct DynamicCommandButton<Centre: CommandCentre, Wrapped: CommandWithUI, Content: View>: View where Wrapped.Centre == Centre {
  /// Command centre that executes the resolved command.
  let commander: Centre

  /// Optional role for the button.
  let role: ButtonRole?

  /// Closure that builds a concrete command for a resolved trigger.
  let command: @MainActor (CommandTrigger) -> Wrapped

  /// Content displayed inside the button.
  let content: () -> Content

  @State private var suppressPrimaryAction = false

  var body: some View {
    baseButton
      // TODO: Track the current dynamic trigger in view state so macOS can use
      // modifier changes to update availability, help, and shortcut ahead of the
      // click. That likely means monitoring key and mouse modifier events and
      // refreshing a stored CommandTrigger as the pointer focus changes. iOS still
      // cannot predict tap vs long-press up front, so its disabled state will
      // remain primary-trigger based unless the UI is split into distinct controls.
      .disabled(commander.shouldDisable(primaryCommand))
      #if !os(watchOS) && !os(tvOS)
        .keyboardShortcut(primaryCommand.shortcut)
      #endif
      .help(primaryCommand.help ?? "")
  }

  /// Concrete command used for default UI state such as disabled, help, and shortcut.
  private var primaryCommand: Wrapped {
    command(.primary)
  }

  /// Performs the wrapped command for the supplied trigger.
  private func performWrappedCommand(_ trigger: CommandTrigger) {
    commander.performWithoutWaiting(command(trigger))
  }

  @ViewBuilder
  private var baseButton: some View {
    #if os(macOS)
      Button(role: role, action: { performWrappedCommand(currentTrigger) }) {
        content()
      }
    #elseif os(iOS)
      Button(role: role, action: performPrimaryAction) {
        content()
      }
      .simultaneousGesture(
        LongPressGesture().onEnded { _ in
          suppressPrimaryAction = true
          performWrappedCommand(.secondary)
        }
      )
    #else
      Button(role: role, action: { performWrappedCommand(.primary) }) {
        content()
      }
    #endif
  }

  #if os(macOS)
    /// Maps the current macOS modifier state to an abstract command trigger.
    private var currentTrigger: CommandTrigger {
      guard let event = NSApp.currentEvent else {
        return .primary
      }

      switch event.type {
        case .leftMouseDown, .leftMouseUp, .rightMouseDown, .rightMouseUp, .otherMouseDown, .otherMouseUp:
          break
        default:
          return .primary
      }

      let modifiers = event.modifierFlags
      if modifiers.contains(.command) {
        return .secondary
      }
      if modifiers.contains(.option) {
        return .tertiary
      }
      return .primary
    }
  #endif

  #if os(iOS)
    /// Performs the primary iOS action unless it was consumed by a long press.
    private func performPrimaryAction() {
      if suppressPrimaryAction {
        suppressPrimaryAction = false
      } else {
        performWrappedCommand(.primary)
      }
    }
  #endif
}
