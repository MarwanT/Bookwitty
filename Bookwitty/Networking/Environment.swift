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
    case .localDevice:
      return URL(string: "https://private-7bb9fa-dannyhajj.apiary-mock.com/api")!
    case .mock:
      return URL(string: "https://private-7bb9fa-dannyhajj.apiary-mock.com/api")!
    case .preproduction:
      // TODO: Set the correct Preproduction base URL
      return URL(string: "https://private-7bb9fa-dannyhajj.apiary-mock.com/api")!
    case .production:
      // TODO: Set the correct Production base URL
      return URL(string: "https://private-7bb9fa-dannyhajj.apiary-mock.com/api")!
    }
  }
}
