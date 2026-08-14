// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands

/// Defines the item-management state capability required by its commands.
///
/// Commands that add, remove, clear, review, or reveal advanced actions
/// constrain their command-centre type to `ItemServiceProvider`. They can
/// therefore run with any suitable centre, without a dependency on importing,
/// undo/redo, UI routing, or other unrelated application services. The concrete
/// `Commander` composes this capability at the application root.
protocol ItemServiceProvider: CommandCentre {
  /// Shared state used by the item-management command implementations.
  var itemService: ItemService { get }
}
