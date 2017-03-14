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
  var relatedReadingLists: [ReadingList]? = nil
  var relatedTopics: [Topic]? = nil
  
  let maximumNumberOfDetails: Int = 3
  var bookDetailedInformation: [(key: String, value: String)]? = nil
  var bookCategories: [Category]? = nil
  weak var viewController: BookDetailsViewController? = nil
  
  var shouldShowBottomLoader = false
  fileprivate var shouldReloadBookDetailsSections = false
  fileprivate var shouldReloadRelatedReadingListsSections = false
  fileprivate var shouldReloadRelatedTopicsSections = false
  
  var viewControllerTitle: String? {
    return ""
  }
  
  var shipementInfoURL: URL? {
    return URL(string: "/shipping?layout=app", relativeTo: Environment.current.baseURL)
  }
  
  var bookCanonicalURL: URL? {
    return book.canonicalURL
  }
  
  var numberOfSections: Int {
    return Section.numberOfSections
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
    case .activityIndicator:
      return itemsInActivityIndicator
    }
  }
  
  /// Currently this method au-resets should reload flags when called
  func sectionsNeedsReloading() -> [Section] {
    var sections = [Section]()
    if shouldReloadBookDetailsSections {
      shouldReloadBookDetailsSections = false
      sections += [.header, .format, .about, .eCommerce, .details, .categories]
    }
    if shouldReloadRelatedReadingListsSections {
      shouldReloadRelatedReadingListsSections = false
      sections += [.recommendedReadingLists]
    }
    if shouldReloadRelatedTopicsSections {
      shouldReloadRelatedTopicsSections = false
      sections += [.relatedTopics]
    }
    sections += [.activityIndicator]
    return sections
  }
}

// MARK: - Helpers 
extension BookDetailsViewModel {
  func resourcesCommonProperties(for indexPath: IndexPath) -> [ModelCommonProperties]? {
    guard let section = Section(rawValue: indexPath.section) else {
      return nil
    }
    
    switch section {
    case .recommendedReadingLists:
      return relatedReadingLists
    case .relatedTopics:
      return relatedTopics
    default:
      return nil
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
      eCommerceNode.delegate = viewController
      eCommerceNode.set(supplierInformation: book.supplierInformation)
      node = eCommerceNode
    case .about:
      let externalInsets = UIEdgeInsets(
        top: ThemeManager.shared.currentTheme.generalExternalMargin() * 2,
        left: 0, bottom: 0, right: 0)
      let aboutNode = BookDetailsAboutNode(externalInsets: externalInsets)
      aboutNode.about = book.bookDescription
      aboutNode.delegate = viewController
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
        let externalInsets = UIEdgeInsets(
          top: ThemeManager.shared.currentTheme.generalExternalMargin() * 2,
          left: 0, bottom: 0, right: 0)
        let headerNode = SectionTitleHeaderNode(externalInsets: externalInsets)
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
      guard let relatedReadingLists = relatedReadingLists, relatedReadingLists.count > 0 else {
        break
      }
      switch indexPath.row {
      case 0: // Header
        let externalInsets = UIEdgeInsets(
          top: ThemeManager.shared.currentTheme.generalExternalMargin() * 2,
          left: 0, bottom: ThemeManager.shared.currentTheme.generalExternalMargin(), right: 0)
        let headerNode = SectionTitleHeaderNode(externalInsets: externalInsets)
        headerNode.setTitle(
          title: Strings.book_recommended_in_reading_lists(),
          verticalBarColor: ThemeManager.shared.currentTheme.colorNumber4(),
          horizontalBarColor: ThemeManager.shared.currentTheme.colorNumber3())
        node = headerNode
      case relatedReadingLists.count + 1: // Footer
        let footerNode = DisclosureNodeCell()
        footerNode.configuration.addInternalBottomSeparator = true
        footerNode.text = Strings.view_all()
        footerNode.configuration.style = .highlighted
        node = footerNode
      default:
        let resource = relatedReadingLists[indexPath.row - 1]
        guard let cardNode = CardFactory.shared.createCardFor(resource: resource) else {
          break
        }
        return cardNode
      }
    case .relatedTopics:
      guard let relatedTopics = relatedTopics, relatedTopics.count > 0 else {
        break
      }
      switch indexPath.row {
      case 0: // Header
        let externalInsets = UIEdgeInsets(
          top: ThemeManager.shared.currentTheme.generalExternalMargin() * 2,
          left: 0, bottom: ThemeManager.shared.currentTheme.generalExternalMargin(), right: 0)
        let headerNode = SectionTitleHeaderNode(externalInsets: externalInsets)
        headerNode.setTitle(
          title: Strings.related_bookwitty_topics(),
          verticalBarColor: ThemeManager.shared.currentTheme.colorNumber13(),
          horizontalBarColor: ThemeManager.shared.currentTheme.colorNumber2())
        node = headerNode
      case relatedTopics.count + 1: // Footer
        let footerNode = DisclosureNodeCell()
        footerNode.configuration.addInternalBottomSeparator = true
        footerNode.text = Strings.view_all()
        footerNode.configuration.style = .highlighted
        node = footerNode
      default:
        let resource = relatedTopics[indexPath.row - 1]
        guard let cardNode = CardFactory.shared.createCardFor(resource: resource) else {
          break
        }
        return cardNode
      }
    case .activityIndicator:
      let loaderNode = LoaderNode()
      loaderNode.style.width = ASDimensionMake(UIScreen.main.bounds.width)
      node = loaderNode
    }
    
    return node
  }
  
  func sharingContent(indexPath: IndexPath) -> [String]? {
    guard let resourcesCommonProperties = resourcesCommonProperties(for: indexPath), resourcesCommonProperties.count > 0
    else {
      return nil
    }
    
    let resourceProperty = resourcesCommonProperties[indexPath.row - 1]
    let shortDesciption = resourceProperty.title ?? resourceProperty.shortDescription ?? ""
    if let sharingUrl = resourceProperty.canonicalURL {
      return [shortDesciption, sharingUrl.absoluteString]
    }
    return [shortDesciption]
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
    guard let relatedReadingLists = relatedReadingLists, relatedReadingLists.count > 0 else {
      return 0
    }
    let header: Int = 1
    let footer: Int = 1
    return relatedReadingLists.count + header + footer
  }
  
  var itemsInRelatedTopics: Int {
    guard let relatedTopics = relatedTopics, relatedTopics.count > 0 else {
      return 0
    }
    let header: Int = 1
    let footer: Int = 1
    return relatedTopics.count + header + footer
  }
  
  var itemsInActivityIndicator: Int {
    return shouldShowBottomLoader ? 1 : 0
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
        guard let productDetails = book.productDetails else {
          return nil
        }
        return .viewDetails(productDetails)
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

// MARK: - API Calls
extension BookDetailsViewModel {
  func loadContent(completion: @escaping (_ success: Bool, _ error: [BookwittyAPIError?]) -> Void) {
    let queue = DispatchGroup()
    
    var loadBookDetailsSuccess: Bool = false
    var loadRelatedContentSuccess: Bool = false
    var loadBookDetailsError: BookwittyAPIError? = nil
    var loadRelatedContentError: BookwittyAPIError? = nil
    
    queue.enter()
    loadBookDetails { (success, error) in
      loadBookDetailsSuccess = success
      loadBookDetailsError = error
      queue.leave()
    }
    
    queue.enter()
    loadRelatedContent { (success, error) in
      loadRelatedContentSuccess = success
      loadRelatedContentError = error
      queue.leave()
    }
    
    queue.notify(queue: DispatchQueue.main) { 
      completion(
        loadBookDetailsSuccess && loadRelatedContentSuccess,
        [loadBookDetailsError, loadRelatedContentError])
    }
  }
  
  func loadBookDetails(completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) {
    var success: Bool = false
    var error:BookwittyAPIError? = nil
    defer {
      completion(success, error)
    }
    
    // TODO: Load book details From API
    success = true
    shouldReloadBookDetailsSections = false
  }
  
  func loadRelatedContent(completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) {
    guard let bookId = book.id else {
      return
    }
    
    _ = GeneralAPI.posts(
      contentIdentifier: bookId, type: [ReadingList.resourceType, Topic.resourceType], completion: {
        (success, resources, nextPage, error) in
        var success: Bool = success
        var error: BookwittyAPIError? = error
        defer {
          completion(success, error)
        }
        
        guard success, let resources = resources else {
          return
        }
        
        self.relatedReadingLists = Array(resources.flatMap({ $0 as? ReadingList }).prefix(self.maximumNumberOfDetails))
        self.relatedTopics = Array(resources.flatMap({ $0 as? Topic }).prefix(self.maximumNumberOfDetails))
        
        self.shouldReloadRelatedReadingListsSections =
          (self.relatedReadingLists?.count ?? 0 > 0) ? true : false
        self.shouldReloadRelatedTopicsSections =
          (self.relatedTopics?.count ?? 0 > 0) ? true : false
    })
  }
  
  // Wit And Unwit API calls
  
  func witContent(indexPath: IndexPath, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let resourcesCommonProperties = resourcesCommonProperties(for: indexPath), let contentId = resourcesCommonProperties[indexPath.row - 1].id else {
      completionBlock(false)
      return
    }
    
    _ = NewsfeedAPI.wit(contentId: contentId, completion: { (success, error) in
      completionBlock(success)
    })
  }
  
  func unwitContent(indexPath: IndexPath, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let resourcesCommonProperties = resourcesCommonProperties(for: indexPath), let contentId = resourcesCommonProperties[indexPath.row - 1].id else {
      completionBlock(false)
      return
    }
    
    _ = NewsfeedAPI.unwit(contentId: contentId, completion: { (success, error) in
      completionBlock(success)
    })
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
    case activityIndicator
    
    static var numberOfSections: Int {
      return 11
    }
  }
}

// MARK: - Handle Reading Lists Images
extension BookDetailsViewModel {
  func loadReadingListImages(at indexPath: IndexPath, maxNumberOfImages: Int, completionBlock: @escaping (_ imageCollection: [String]?) -> ()) {
    guard let relatedReadingLists = relatedReadingLists else {
      completionBlock(nil)
      return
    }
    
    let readingList = relatedReadingLists[indexPath.row - 1]
    
    var ids: [String] = []
    if let list = readingList.postsRelations {
      for item in list {
        ids.append(item.id)
      }
    }
    
    if ids.count > 0 {
      let limitToMaximumIds = Array(ids.prefix(maxNumberOfImages))
      loadReadingListItems(readingListIds: limitToMaximumIds, completionBlock: completionBlock)
    } else {
      completionBlock(nil)
    }
  }
  
  private func loadReadingListItems(readingListIds: [String], completionBlock: @escaping (_ imageCollection: [String]?) -> ()) {
    _ = UserAPI.batch(identifiers: readingListIds) { (success, resources, error) in
      var imageCollection: [String]? = nil
      defer {
        completionBlock(imageCollection)
      }
      if success {
        var images: [String] = []
        resources?.forEach({ (resource) in
          if let res = resource as? ModelCommonProperties {
            if let imageUrl = res.thumbnailImageUrl {
              images.append(imageUrl)
            }
          }
        })
        imageCollection = images
      }
    }
  }
}
