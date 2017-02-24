//
//  Book.swift
//  Bookwitty
//
//  Created by charles on 2/20/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

class Book: Resource {

  var title: String?
  var subtitle: String?
  var bookDescription: [String : Any]?
  var thumbnailImageUrl: String?
  var coverImageUrl: String?

  var userId: String?

  var createdAt: String?
  var updatedAt: String?

  var productDetails: [String : Any]?
  var supplierInformation: [String : Any]?

  override class var resourceType: ResourceType {
    return "books"
  }

  override class var fields: [Field] {
    return fieldsFromDictionary([
      "title" : Attribute().serializeAs("title"),
      "subtitle" : Attribute().serializeAs("subtitle"),
      "bookDescription" : Attribute().serializeAs("description"),
      "thumbnailImageUrl" : Attribute().serializeAs("thumbnail-image-url"),
      "userId": Attribute().serializeAs("user-id"),
      "createdAt" : Attribute().serializeAs("created-at"),
      "updatedAt" : Attribute().serializeAs("updated-at"),
      "coverImageUrl" : Attribute().serializeAs("cover-image-url"),
      "productDetails" : Attribute().serializeAs("product-details"),
      "supplierInformation" : Attribute().serializeAs("supplier-information"),
      ])
  }
}


// MARK: - Parser
extension Book: Parsable {
  typealias AbstractType = Book
}
