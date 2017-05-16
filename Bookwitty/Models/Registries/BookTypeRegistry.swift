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

  func update(resources: [ModelResource], section: Section) {
    resources.forEach({ resource in
      guard let book = resource as? Book, let id = book.id else {
        return
      }

      if !registry.contains(where: { $0.id == id && $0.section == section }) {
        let category: Category = (book.productFormats?.count ?? 0 == 0) ? .product : .topic
        let entry: Entry = (id, section, category)
        registry.append(entry)
      }
    })
  }

  func category(for resource: ModelResource, section: Section) -> Category? {
    guard let book = resource as? Book, let id = book.id else {
      return nil
    }

    return registry.first(where: { $0.id == id && $0.section == section })?.category
  }
}
