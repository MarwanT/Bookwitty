//
//  DataManager.swift
//  Bookwitty
//
//  Created by charles on 4/14/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class DataManager {
  static let shared = DataManager()
  private init() {}

  fileprivate var pool: [String : ModelResource] = [:]
}
