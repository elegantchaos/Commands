// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 17/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import SwiftUI

#if !os(watchOS) && !os(tvOS)

/// Modifier which applies a fileImporter to the view that shows
/// import sheet for the associated `ImporterCommand`.
/// If you use `commander.importer(myImporterCommand)` to make a button
/// in a view, then it does the work of attaching one of these to the button for you,
/// and you don't need to use this modifier directly.
///
/// However, using `commander.importer` won't work in a contextual menu, since
/// attaching a fileImporter to the menu doesn't work. In that situation you'll
/// need to make a button to set the isShowing binding to true, place that in
/// the context menu, and use this modifier to attach the sheet to the view
/// that owns the context menu.
public struct ImporterCommandModifier<C: ImporterCommand, CC: CommandCentre>: ViewModifier where C.Centre == CC {
  /// Controls presentation of the file importer.
  @Binding var isShowing: Bool

  /// Mutable command state updated from the importer result.
  @State var command: C

  /// Command centre used to execute the importer-backed command.
  let centre: CC
  
  /// Creates a modifier that binds importer presentation to a command instance.
  public init(isShowing: Binding<Bool>, command: C, centre: CC) {
    self._isShowing = isShowing
    self._command = .init(initialValue: command)
    self.centre = centre
  }
  
  /// Applies the importer sheet and forwards its result into the command.
  public func body(content: Content) -> some View {
    content
      .fileImporter(
        isPresented: $isShowing,
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
#endif
