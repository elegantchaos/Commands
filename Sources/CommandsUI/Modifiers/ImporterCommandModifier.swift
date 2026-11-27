// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 17/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import SwiftUI

/// Modifier which applies a fileImporter to the view that shows
/// import sheet for the associated `ImporterCommand`.
/// If you use `centre.importer(myImporterCommand)` to make a button
/// in a view, then it does the work of attaching one of these to the button for you,
/// and you don't need to use this modifier directly.
///
/// However, using `centre.importer` won't work in a contextual menu, since
/// attaching a fileImporter to the menu doesn't work. In that situation you'll
/// need to make a button to set the isShowing binding to true, place that in
/// the context menu, and use this modifier to attach the sheet to the view
/// that owns the context menu.
public struct ImporterCommandModifier<C: ImporterCommand, Centre: CommandCentre>: ViewModifier
where C.Centre == Centre {
  /// Controls presentation of the file importer.
  @Binding var isShowing: Bool

  /// Shared mutable command state updated from the importer result.
  @Binding var command: C

  /// Command centre used to execute the importer-backed command.
  let centre: Centre

  /// Confirms the chosen input before performing, when the command declares a confirmation.
  private let confirmationState = CommandConfirmationState()

  /// Creates a modifier that binds importer presentation to a command instance.
  public init(isShowing: Binding<Bool>, command: Binding<C>, centre: Centre) {
    self._isShowing = isShowing
    self._command = command
    self.centre = centre
  }

  /// Applies the importer sheet and forwards its result into the command.
  ///
  /// Once the user has chosen, the command asks for its confirmation, if it declares one, as a
  /// command button does, and runs only if the user accepts.
  public func body(content: Content) -> some View {
    content
      #if !os(watchOS) && !os(tvOS)
        .fileImporter(
          isPresented: $isShowing,
          allowedContentTypes: command.types,
          allowsMultipleSelection: command.allowsMultipleSelection
        ) { result in
          var chosen = command
          switch result {
          case .success(let urls):
            chosen.state = .chosen(urls)
          case .failure(let error):
            chosen.state = .error(error)
          }
          command = chosen
          confirmationState.request(chosen.confirmation(centre: centre), mode: nil) {
            [centre] in
            centre.performWithoutWaiting(chosen)
          }
        }
        .commandLocalConfirmation(confirmationState)
      #endif
  }
}
