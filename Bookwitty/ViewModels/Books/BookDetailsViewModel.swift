//
//  BookDetailsViewModel.swift
//  Bookwitty
//
//  Created by Marwan  on 3/1/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

enum BookDetailsSection: Int {
  case header = 0
  case format
  case eCommerce
  case about
  case serie
  case peopleWhoLikeThisBook
  case details
  case categories
  case recommendedReadingLists
  case relatedTopics
}

final class BookDetailsViewModel {
  var book: Book! = nil
  
  var viewControllerTitle: String? {
    return ""
  }
  
  var numberOfSections: Int {
    return 10
  }
  
  func numberOfItemsForSection(section: Int) -> Int {
    guard let section = BookDetailsSection(rawValue: section) else {
      return 0
    }
    switch section {
    case .header:
      return itemsInHeader
    case .format:
      return itemsInFormat
    case .eCommerce:
      return itemsInECommerce
    case .about:
      return itemsInAbout
    case .serie:
      return itemsInBookPartOfSerie
    case .peopleWhoLikeThisBook:
      return itemsInPeopleWhoLikeThisBook
    case .details:
      return itemsInDetails
    case .categories:
      return itemsInCategories
    case .recommendedReadingLists:
      return itemsInRecommendedReadingLists
    case .relatedTopics:
      return itemsInRelatedTopics
    }
  }
}

// MARK: - Content Providers
extension BookDetailsViewModel {
  func nodeForItem(at indexPath: IndexPath) -> ASCellNode {
    var node = ASCellNode()
    guard let section = BookDetailsSection(rawValue: indexPath.section) else {
      return node
    }
    
    switch section {
    case .header: // Header
      let headerNode = BookDetailsHeaderNode()
      headerNode.title = book.title
      headerNode.author = book.productDetails?.author
      headerNode.imageURL = URL(string: book.coverImageUrl ?? "")
      node = headerNode
    case .format:
      let formatNode = BookDetailsFormatNode()
      formatNode.format = book.productDetails?.productFormat
      node = formatNode
    case .eCommerce:
      let eCommerceNode = BookDetailsECommerceNode()
      eCommerceNode.set(supplierInformation: book.supplierInformation)
      node = eCommerceNode
    case .about:
      let aboutNode = BookDetailsAboutNode()
      aboutNode.about = book.bookDescription
      node = aboutNode
    case .serie:
      break
    case .peopleWhoLikeThisBook:
      break
    case .details:
      break
    case .categories:
      break
    case .recommendedReadingLists:
      break
    case .relatedTopics:
      break
    }
    
    return node
  }
}

// MARK: - Sections Validations
extension BookDetailsViewModel {
  var itemsInHeader: Int {
    return 1
  }
  
  var itemsInFormat: Int {
    if let format = book.productDetails?.productFormat, !format.isEmpty {
      return 1
    } else {
      return 0
    }
  }
  
  var itemsInECommerce: Int {
    return book.supplierInformation != nil ? 1 : 0
  }
  
  var itemsInAbout: Int {
    if let aboutInfo = book.bookDescription, !aboutInfo.isEmpty {
      return 1
    } else {
      return 0
    }
  }
  
  var itemsInBookPartOfSerie: Int {
    return 0
  }
  
  var itemsInPeopleWhoLikeThisBook: Int {
    return 0
  }
  
  var itemsInDetails: Int {
    return 0
  }
  
  var itemsInCategories: Int {
    return 0
  }
  
  var itemsInRecommendedReadingLists: Int {
    return 0
  }
  
  var itemsInRelatedTopics: Int {
    return 0
  }
}
