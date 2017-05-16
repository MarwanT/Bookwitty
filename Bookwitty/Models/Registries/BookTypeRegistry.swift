//
//  BookTypeRegistry.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 5/16/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class BookTypeRegistry {

  enum Section {
    case newsFeed
    case discover
    case readingList
  }
  
  static let shared = BookTypeRegistry()
  private init() {}

}
