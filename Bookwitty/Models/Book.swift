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
  var bookDescription: [String : Any]?
  var thumbnailImageUrl: String?
  var coverImageUrl: String?

  var userId: String?

  var createdAt: String?
  var updatedAt: String?

  var productDetails: ProductDetails?
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
      "productDetails" : ProductDetailsAttribute().serializeAs("product-details"),
      "supplierInformation" : Attribute().serializeAs("supplier-information"),
      ])
  }
}


// MARK: - Parser
extension Book: Parsable {
  typealias AbstractType = Book
}




class ProductDetails: NSObject {
  var author: String?
  var categories: [String]?
  var imprint: String?
  var isbn10: String?
  var isbn13: String?
  var isbn13h: String?
  var languageOfText: String?
  var productForm: String?
  var productFormat: String?
  var publishedAt: String?
  var publisher: String?
  var title: String?
  var subtitle: String?
  var height: [String : Any]?
  var weight: [String : Any]?
  var width: [String : Any]?
  var numberOfPages: String?
  
  
  override init() {
    super.init()
  }
  
  init(for dictionary: [String : Any]) {
    super.init()
    setValues(dictionary: dictionary)
  }
  
  private func setValues(dictionary: [String : Any]) {
    let json = JSON(dictionary)
    
    self.author = json["author"].stringValue
    self.categories = json["categories"].arrayObject as? [String]
    self.imprint = json["imprint"].stringValue
    self.isbn10 = json["isbn10"].stringValue
    self.isbn13 = json["isbn13"].stringValue
    self.isbn13h = json["isbn13h"].stringValue
    self.languageOfText = json["language-of-text"].stringValue
    self.productForm = json["product-form"].stringValue
    self.productFormat = json["product-format"].stringValue
    self.publishedAt = json["published-at"].stringValue
    self.publisher = json["publisher"].stringValue
    self.title = json["title"].stringValue
    self.subtitle = json["subtitle"].stringValue
    self.height = json["height"].dictionaryObject
    self.weight = json["weight"].dictionaryObject
    self.width = json["width"].dictionaryObject
    self.numberOfPages = json["nb-of-pages"].stringValue
  }
}


// MARK: - Supplier Information
class SupplierInformation: NSObject {
  var quantity: Int?
  var listPrice: Price?
  var price: Price?
  var userPrice: Price?
  
  override init() {
    super.init()
  }
  
  init(for dictionary: [String : Any]) {
    super.init()
    setValues(dictionary: dictionary)
  }
  
  private func setValues(dictionary: [String : Any]) {
    let json = JSON(dictionary)
    self.quantity = json["quantity"].intValue
    self.listPrice = Price(for: json["list-price"].dictionaryObject)
    self.price = Price(for: json["price"].dictionaryObject)
    self.userPrice = Price(for: json["user-price"].dictionaryObject)
  }
}


// MARK: - Price
struct Price {
  var currency: String?
  let value: String?
  
  init(for dictionary: [String : Any]?) {
    guard let dictionary = dictionary else {
      currency = nil
      value = nil
      return
    }
    let json = JSON(dictionary)
    currency = json["currency"].stringValue
    value = json["value"].stringValue
  }
}

