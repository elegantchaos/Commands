//
//  ExampleCommandState.swift
//  Example
//
//  Created by Sam Deane on 05/08/2026.
//

import Commands
import Observation

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

protocol ExampleServiceProvider: CommandCentre {
  var service: ExampleService { get }

}
