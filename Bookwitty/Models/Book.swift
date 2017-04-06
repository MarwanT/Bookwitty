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

  override class var fields: [Field] {
    return fieldsFromDictionary([
      "title" : Attribute().serializeAs("title"),
      "subtitle" : Attribute().serializeAs("subtitle"),
      "bookDescription" : Attribute().serializeAs("description"),
      "thumbnailImageUrl" : Attribute().serializeAs("thumbnail-image-url"),
      "userId": Attribute().serializeAs("user-id"),
      "createdAt" : DateAttribute().serializeAs("created-at"),
      "updatedAt" : DateAttribute().serializeAs("updated-at"),
      "coverImageUrl" : Attribute().serializeAs("cover-image-url"),
      "counts" : CountsAttribute().serializeAs("counts"),
      "followingNumber": Attribute().serializeAs("following"),
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



// MARK: - Product Details
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
  var publishedAt: Date?
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
    self.publishedAt = Date.from(json["published-at"].stringValue)
    self.publisher = json["publisher"].stringValue
    self.title = json["title"].stringValue
    self.subtitle = json["subtitle"].stringValue
    self.height = json["height"].dictionaryObject
    self.weight = json["weight"].dictionaryObject
    self.width = json["width"].dictionaryObject
    self.numberOfPages = json["nb-of-pages"].stringValue
  }
  
  func associatedKeyValues() -> [(key: String, value: String)] {
    var associatedInformation = [(key: String, value: String)]()
    if let author = author, !author.isBlank {
      associatedInformation.append((Strings.author(), author))
    }
    if let imprint = imprint, !imprint.isBlank {
      associatedInformation.append((Strings.imprint(), imprint))
    }
    if let isbn10 = isbn10, !isbn10.isBlank {
      associatedInformation.append((Strings.isbn10(), isbn10))
    }
    if let isbn13 = isbn13, !isbn13.isBlank {
      associatedInformation.append((Strings.isbn13(), isbn13))
    }
    if let languageOfText = languageOfText, !languageOfText.isBlank {
      let language = Locale.application.localizedString(forLanguageCode: languageOfText) ?? languageOfText
      associatedInformation.append((Strings.language_of_text(), language))
    }
    if let productFormat = productFormat, !productFormat.isBlank {
      associatedInformation.append((Strings.product_format(), productFormat))
    }
    if let publisher = publisher, !publisher.isBlank {
      associatedInformation.append((Strings.publisher(), publisher))
    }
    if let publishedAtString = publishedAt?.formatted().capitalized, !publishedAtString.isBlank {
      associatedInformation.append((Strings.publication_date(), publishedAtString))
    }
    if let subtitle = subtitle, !subtitle.isBlank {
      associatedInformation.append((Strings.subtitle(), subtitle))
    }
    if let heightUnit = height?["unit"] as? String, !heightUnit.isBlank,
      let heightValue = height?["value"] as? CGFloat {
      associatedInformation.append((Strings.height(), "\(heightValue) \(heightUnit)"))
    }
    if let weightUnit = weight?["unit"] as? String, !weightUnit.isBlank,
      let weightValue = weight?["value"] as? CGFloat {
      associatedInformation.append((Strings.weight(), "\(weightValue) \(weightUnit)"))
    }
    if let widthUnit = width?["unit"] as? String, !widthUnit.isBlank,
      let widthValue = width?["value"] as? CGFloat {
      associatedInformation.append((Strings.width(), "\(widthValue) \(widthUnit)"))
    }
    if let numberOfPages = numberOfPages, !numberOfPages.isBlank {
      associatedInformation.append((Strings.number_of_pages(), numberOfPages))
    }
    return associatedInformation
  }
}

extension ProductDetails {
  /*
   *  The list of formats below is taken from the ONIX documentation here:
   *  https://www.medra.org/stdoc/onix-codelist-7.htm
   */
  private static let electronicProductForms = [ "AA", "AB", "AC", "AD", "AE",
      "AF", "AG", "AH", "AI", "AJ", "AK", "AL", "AZ", "DA", "DB", "DC", "DD",
      "DE", "DF", "DG", "DH", "DI", "DJ", "DK", "DL", "DM", "DN", "DZ", "VA",
      "VB", "VC", "VD", "VE", "VF", "VG", "VH", "VI", "VJ", "VK", "VL", "VM",
      "VN", "VO", "VP", "VZ", "WW" ]

  func isElectronicFormat() -> Bool {
    guard let productForm = self.productForm else {
      return false
    }
    return ProductDetails.electronicProductForms.contains(productForm)
  }
}
