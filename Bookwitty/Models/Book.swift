//
//  Book.swift
//  Bookwitty
//
//  Created by charles on 2/20/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine
import SwiftyJSON

class Book: Resource {

  var title: String?
  var subtitle: String?
  var bookDescription: String?
  var thumbnailImageUrl: String?
  var coverImageUrl: String?

  var userId: String?

  var createdAt: NSDate?
  var updatedAt: NSDate?

  var productDetails: ProductDetails?
  var supplierInformation: SupplierInformation?
  var counts: Counts?

  var productFormats: [String]?

  @objc
  private var reportedAsSpam: NSNumber?
  var isReported: Bool? {
    get {
      return ((reportedAsSpam?.intValue ?? 0) == 1)
    }
    set {
      reportedAsSpam = NSNumber(value: newValue ?? false)
    }
  }
  
  @objc
  private var followingNumber: NSNumber?
  var following: Bool {
    get {
      return ((followingNumber?.intValue ?? 0) == 1)
    }
    set {
      followingNumber = NSNumber(value: newValue)
    }
  }

  @objc
  private var contributorsCollection: LinkedResourceCollection?
  lazy var contributors: [PenName]? = {
    return self.contributorsCollection?.resources as? [PenName]
  }()

  @objc
  fileprivate var countsDictionary: [String : Any]?

  override class var resourceType: ResourceType {
    return "books"
  }
  
  // TODO: Use this variable when displaying a book price across the app
  var preferredPrice: Price? {
    return (productDetails?.isElectronicFormat ?? false) ? nil : supplierInformation?.preferredPrice
  }

  override class var fields: [Field] {
    return fieldsFromDictionary([
      "title" : Attribute().serializeAs("title"),
      "subtitle" : Attribute().serializeAs("subtitle"),
      "bookDescription" : Attribute().serializeAs("description"),
      "thumbnailImageUrl" : Attribute().serializeAs("thumbnail-image-url"),
      "userId": Attribute().serializeAs("user-id"),
      "productFormats": Attribute().serializeAs("product-formats"),
      "createdAt" : DateAttribute().serializeAs("created-at"),
      "updatedAt" : DateAttribute().serializeAs("updated-at"),
      "coverImageUrl" : Attribute().serializeAs("cover-image-url"),
      "counts" : CountsAttribute().serializeAs("counts"),
      "followingNumber": Attribute().serializeAs("following"),
      "reportedAsSpam": BooleanAttribute().serializeAs("reported-as-spam"),
      "contributorsCollection" : ToManyRelationship(PenName.self).serializeAs("contributors"),
      "productDetails" : ProductDetailsAttribute().serializeAs("product-details"),
      "supplierInformation" : SupplierInformationAttribute().serializeAs("supplier-information"),
      ])
  }
}

// MARK: - Parser
extension Book: Parsable {
  typealias AbstractType = Book
}

// MARK: - Declare Book.Meta
extension Book {
  class Meta {
    var numberOfEditionsPerFormat: [String : Int] = [:]
    var totalEditions: Int = 0
    
    init(dictionary: [String : Any]?) {
      guard let dictionary = dictionary else {
        return
      }
      
      if let counts = dictionary["counts"] as? [String : Int] {
        numberOfEditionsPerFormat = counts
      }
      if let totalEditions = dictionary["total-editions"] as? Int {
        self.totalEditions = totalEditions
      }
    }
  }
}

//MARK: - Pandacraft
extension Book {
  private static let pandacraftResourcesIdentifiers = [
    "BKW00000000010000000",
    "BKW00000000020000000",
    "BKW00000000030000000"
  ]
  
  var isPandacraft: Bool {
    return Book.pandacraftResourcesIdentifiers.contains(id ?? "")
  }
}
