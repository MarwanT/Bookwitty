//
//  BookTypeRegistry.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 5/16/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class BookTypeRegistry {
  typealias Entry = (id: String, section: Section, category: Category)

  enum Category {
    case product
    case topic
  }

  enum Section {
    case newsFeed
    case discover
    case readingList
  }
  
  static let shared = BookTypeRegistry()
  private init() {}

  fileprivate var registry: [Entry] = []

}
