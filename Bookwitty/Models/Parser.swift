//
//  Parser.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/5/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

class Parser {
  static let sharedInstance = Parser()
  let serializer: Serializer = Serializer()

  init() {
    serializer.keyFormatter = DasherizedKeyFormatter()
    registerResources()
    registerValueFormatters()
  }

  private func registerResources() {
    serializer.registerResource(User.self)
    serializer.registerResource(PenName.self)
  }

  private func registerValueFormatters() {
    //Register any value formatter here using the serializer
  }
}
