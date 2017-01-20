//
//  Environment.swift
//  Bookwitty
//
//  Created by Marwan  on 1/17/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

public enum Environment {
  case localDevice
  case mock
  case preproduction
  case production
  
  public private(set) static var current: Environment = .mock
  
  public static func initialize() {
    // TODO: Set the current environment through cocoa keys
    current = .mock
  }
  
  var baseURL: URL {
    switch self {
    case .localDevice, .mock, .preproduction, .production:
      return URL(string: AppKeys.shared.bookwittyServerBaseURLAbsoluteString)!
    }
  }
}
