// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands

/// Defines the importing capability needed by commands in the import area.
///
/// A command that only imports files can constrain its centre to this protocol
/// rather than depending on `ItemServiceProvider` or undo support. The concrete
/// `Commander` composes this focused capability with its other service areas.
protocol ImportServiceProvider: CommandCentre {
  /// Service that records files chosen by importer commands.
  var importService: ImportService { get }
}
