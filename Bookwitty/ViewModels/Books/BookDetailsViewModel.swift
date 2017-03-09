//
//  BookDetailsViewModel.swift
//  Bookwitty
//
//  Created by Marwan  on 3/1/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit


final class BookDetailsViewModel {
  var book: Book! = nil
  
  let maximumNumberOfDetails: Int = 3
  var bookDetailedInformation: [(key: String, value: String)]? = nil
  var bookCategories: [Category]? = nil
  
  var viewControllerTitle: String? {
    return ""
  }
  
  var numberOfSections: Int {
    return 10
  }
  
  func numberOfItemsForSection(section: Int) -> Int {
    guard let section = Section(rawValue: section) else {
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
    guard let section = Section(rawValue: indexPath.section) else {
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
      guard let bookDetailedInformation = bookDetailedInformation else {
        break
      }
      switch indexPath.row {
      case 0: // Header
        let headerNode = SectionTitleHeaderNode()
        headerNode.configuration.externalEdgeInsets.top = (ThemeManager.shared.currentTheme.generalExternalMargin() * 2)
        headerNode.setTitle(
          title: Strings.book_details(),
          verticalBarColor: ThemeManager.shared.currentTheme.colorNumber8(),
          horizontalBarColor: ThemeManager.shared.currentTheme.colorNumber7())
        node = headerNode
      case (bookDetailedInformation.count + 1): // Footer
        let footerNode = DisclosureNodeCell()
        footerNode.configuration.addInternalBottomSeparator = true
        footerNode.text = Strings.view_all()
        footerNode.configuration.style = .highlighted
        node = footerNode
      default: // Information
        let (key, value) = bookDetailedInformation[indexPath.row - 1]
        let infoCell = DetailsInfoCellNode()
        infoCell.key = key
        infoCell.value = value
        infoCell.configuration.addInternalBottomSeparator = true
        node = infoCell
      }
    case .categories:
      guard let categories = bookCategories, categories.count > 0 else {
        break
      }
      switch indexPath.row {
      case 0: // Header
        let headerNode = SectionSubtitleHeaderNode()
        headerNode.title = Strings.book_categories()
        node = headerNode
      default: // Information
        let category = categories[indexPath.row - 1]
        let disclosureNode = DisclosureNodeCell()
        disclosureNode.text = category.value
        disclosureNode.configuration.addInternalBottomSeparator = true
        var separatorLeftInset = ThemeManager.shared.currentTheme.generalExternalMargin()
        if indexPath.row == categories.count {
          separatorLeftInset = 0
        }
        disclosureNode.configuration.separatorInsets.left = separatorLeftInset
        node = disclosureNode
      }
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
    if let details = book.productDetails?.associatedKeyValues(), details.count > 0 {
      let numberOfInformationRows: Int = details.count < maximumNumberOfDetails ? details.count : maximumNumberOfDetails
      bookDetailedInformation = Array(details.prefix(numberOfInformationRows))
      let header: Int = 1
      let footer: Int = 1
      return header + numberOfInformationRows + footer
    } else {
      return 0
    }
  }
  
  var itemsInCategories: Int {
    guard let categoriesIds = book.productDetails?.categories else {
      return 0
    }
    let bookCategories = CategoryManager.shared.categories(from: categoriesIds)
    guard bookCategories.count > 0 else {
      return 0
    }
    
    self.bookCategories = bookCategories
    let header: Int = 1
    return bookCategories.count + header
  }
  
  var itemsInRecommendedReadingLists: Int {
    return 0
  }
  
  var itemsInRelatedTopics: Int {
    return 0
  }
}

// MARK: - Selection
extension BookDetailsViewModel {
  func shouldSelectItem(at indexPath: IndexPath) -> Bool {
    guard let section = Section(rawValue: indexPath.section) else {
      return false
    }
    
    switch section {
    case .details:
      guard let bookDetailedInformation = bookDetailedInformation else {
        return false
      }
      switch indexPath.row {
      case 0: // Header
        return false
      case (bookDetailedInformation.count + 1): // Footer
        return true
      default: // Information
        return false
      }
    case .categories:
      guard bookCategories != nil else {
        return false
      }
      switch indexPath.row {
      case 0: // Header
        return false
      default:
        return true
      }
    default:
      return false
    }
  }
  
  func actionForItem(at indexPath: IndexPath) -> BookDetailsViewController.Action? {
    guard let section = Section(rawValue: indexPath.section) else {
      return nil
    }
    
    switch section {
    case .details:
      guard let bookDetailedInformation = bookDetailedInformation else {
        return nil
      }
      switch indexPath.row {
      case 0: // Header
        return nil
      case (bookDetailedInformation.count + 1): // Footer
        return .viewDetails
      default: // Information
        return nil
      }
    case .categories:
      guard let categories = bookCategories else {
        return nil
      }
      switch indexPath.row {
      case 0: // Header
        return nil
      default:
        return .viewCategory(categories[indexPath.row - 1])
      }
    default:
      return nil
    }
  }
}

// MARK: - Declarations
extension BookDetailsViewModel {
  enum Section: Int {
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
}
