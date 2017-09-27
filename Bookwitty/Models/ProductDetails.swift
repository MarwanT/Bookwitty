//
//  ProductDetails.swift
//  Bookwitty
//
//  Created by Marwan  on 4/6/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import SwiftyJSON

class ProductDetails: NSObject {
  var author: String?
  var categories: [String]?
  var imprint: String?
  var isbn10: String?
  var isbn13: String?
  var isbn13h: String?
  var languageOfText: String?
  var productForm: ProductForm?
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
    self.categories = (json["categories"].arrayObject as? [String])?.filter({ !$0.isBlank })
    self.imprint = json["imprint"].stringValue
    self.isbn10 = json["isbn10"].stringValue
    self.isbn13 = json["isbn13"].stringValue
    self.isbn13h = json["isbn13h"].stringValue
    self.languageOfText = json["language-of-text"].stringValue
    self.productForm = productForm(json["product-form"].stringValue)
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
  
  private func productForm(_ key: String) -> ProductForm? {
    return BookFormatMapper.shared.productForm(for: key)
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
    if let productForm = productForm, !productForm.value.isBlank {
      associatedInformation.append((Strings.product_format(), productForm.value))
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
  var isElectronicFormat: Bool {
    return productForm?.isElectronicFormat ?? false
  }
}
