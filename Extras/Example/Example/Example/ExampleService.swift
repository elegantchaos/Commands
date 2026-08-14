// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/08/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import Observation

/// Observable counter state used by the example commands.
@Observable
class ExampleService {
  var count = 0

  func incrementDone() {
    count += 1
  }

  func decrementDone() {
    count -= 1
  }
}

/// Supplies the service required by the example commands.
protocol ExampleServiceProvider: CommandCentre {
  var service: ExampleService { get }

}
