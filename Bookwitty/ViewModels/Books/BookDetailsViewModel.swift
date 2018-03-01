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
  fileprivate var bookId: String? = nil
  var relatedReadingLists: (readingLists: [ReadingList]?, prefixed: [ReadingList]?, nextPageURL: URL?)? = nil
  var relatedTopics: (topics: [Topic]?, prefixed: [Topic]?, nextPageURL: URL?)? = nil
  
  let maximumNumberOfDetails: Int = 3
  var bookDetailedInformation: [(key: String, value: String)]? = nil
  var bookCategories: [Category]? = nil
  weak var viewController: BookDetailsViewController? = nil
  
  var shouldShowBottomLoader = false
  fileprivate var shouldReloadBookDetailsSections = false
  fileprivate var shouldReloadRelatedReadingListsSections = false
  fileprivate var shouldReloadRelatedTopicsSections = false
  
  func initialize(with book: Book) {
    self.book = book
  }

  func initialize(withId id: String) {
    self.bookId = id
  }
  
  var viewControllerTitle: String? {
    return ""
  }
  
  var shipementInfoURL: URL? {
    return Environment.current.shipementInfoURL
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

  func indexPathForAffectedItems(resourcesIdentifiers: [String], visibleItemsIndexPaths: [IndexPath]) -> [IndexPath] {
    return visibleItemsIndexPaths.filter({
      indexPath in

      guard let resource = resource(at: indexPath), let identifier = resource.id else {
        return false
      }

      return resourcesIdentifiers.contains(identifier)
    })
  }

  func deleteResource(with identifier: String) {
    if let prefixedReadingListsIndex = self.relatedReadingLists?.prefixed?.index(where: { $0.id == identifier }) {
      self.relatedReadingLists?.readingLists?.remove(at: prefixedReadingListsIndex)
    }

    if let readingListsIndex = self.relatedReadingLists?.readingLists?.index(where: { $0.id == identifier }) {
      self.relatedReadingLists?.readingLists?.remove(at: readingListsIndex)
    }

    if let prefixedTopicIndex = self.relatedTopics?.prefixed?.index(where: { $0.id == identifier }) {
      self.relatedTopics?.prefixed?.remove(at: prefixedTopicIndex)
    }

    if let topicsIndex = self.relatedTopics?.topics?.index(where: { $0.id == identifier }) {
      self.relatedTopics?.topics?.remove(at: topicsIndex)
    }
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
      return relatedReadingLists?.prefixed
    case .relatedTopics:
      return relatedTopics?.prefixed
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
      headerNode.delegate = viewController
      node = headerNode
    case .format:
      let formatNode = BookDetailsFormatNode()
      formatNode.format = book.productDetails?.productForm?.value
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
      let aboutNode = GeneralDetailsNode(externalInsets: externalInsets)
      aboutNode.setText(aboutText: book.bookDescription)
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
        let (key, value) = bookDetailedInformation[section.dataIndex(for: indexPath)]
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
        let category = categories[section.dataIndex(for: indexPath)]
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
      guard let relatedReadingLists = relatedReadingLists?.prefixed, relatedReadingLists.count > 0 else {
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
        let resource = relatedReadingLists[section.dataIndex(for: indexPath)]
        guard let cardNode = CardFactory.createCardFor(resourceType: resource.registeredResourceType) else {
          break
        }
        
        cardNode.baseViewModel?.resource = resource
        return cardNode
      }
    case .relatedTopics:
      guard let relatedTopics = relatedTopics?.prefixed, relatedTopics.count > 0 else {
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
        let resource = relatedTopics[section.dataIndex(for: indexPath)]
        guard let cardNode = CardFactory.createCardFor(resourceType: resource.registeredResourceType) else {
          break
        }

        cardNode.baseViewModel?.resource = resource
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
    guard let section = Section(rawValue: indexPath.section), let resourcesCommonProperties = resourcesCommonProperties(for: indexPath), resourcesCommonProperties.count > 0
    else {
      return nil
    }
    
    let resourceProperty = resourcesCommonProperties[section.dataIndex(for: indexPath)]
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
    return (book.supplierInformation != nil &&
      !(book.productDetails?.isElectronicFormat ?? false)) ? 1 : 0
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
    guard let relatedReadingLists = relatedReadingLists?.prefixed, relatedReadingLists.count > 0 else {
      return 0
    }
    let header: Int = 1
    let footer: Int = 1
    return relatedReadingLists.count + header + footer
  }
  
  var itemsInRelatedTopics: Int {
    guard let relatedTopics = relatedTopics?.prefixed, relatedTopics.count > 0 else {
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
    case .format:
      return true
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
    case .recommendedReadingLists:
      guard let readingLists = relatedReadingLists?.prefixed else {
        return false
      }
      switch indexPath.item {
      case 0: // Header
        return false
      case (readingLists.count + 1): // Footer
        return true
      default:
        return true
      }
    case .relatedTopics:
      guard let relatedTopics = relatedTopics?.prefixed else {
        return false
      }
      switch indexPath.item {
      case 0: // Header
        return false
      case (relatedTopics.count + 1): // Footer
        return true
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
    case .format:
      return .viewFormat(book)
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
        return .viewCategory(categories[section.dataIndex(for: indexPath)])
      }
    case .recommendedReadingLists:
      guard let readingLists = relatedReadingLists?.prefixed else {
        return nil
      }
      switch indexPath.row {
      case 0: // Header
        return nil
      case readingLists.count + 1: // Footer
        return .viewRelatedReadingLists(
          bookTitle: book.title ?? "",
          readingLists: relatedReadingLists?.readingLists,
          url: relatedReadingLists?.nextPageURL)
      default:
        return .goToReadingList(readingLists[indexPath.item - 1])
      }
    case .relatedTopics:
      guard let relatedTopics = relatedTopics?.prefixed else {
        return nil
      }
      switch indexPath.row {
      case 0: // Header
        return nil
      case relatedTopics.count + 1: // Footer
        return .viewRelatedTopics(
          bookTitle: book.title ?? "",
          topics: self.relatedTopics?.topics,
          url: self.relatedTopics?.nextPageURL)
      default:
        return .goToTopic(relatedTopics[indexPath.item - 1])
      }
    default:
      return nil
    }
  }
}

// MARK: - API Calls
extension BookDetailsViewModel {
  fileprivate var shouldLoadBookData: Bool {
    return bookId != nil
  }
  
  func loadContent(completion: @escaping (_ success: Bool, _ error: [BookwittyAPIError?]) -> Void) {
    let queue = DispatchGroup()
    
    var loadBookDetailsSuccess: Bool = false
    var loadRelatedReadingListsSuccess: Bool = false
    var loadRelatedTopicsSuccess: Bool = false
    var loadBookDetailsError: BookwittyAPIError? = nil
    var loadRelatedReadingListsError: BookwittyAPIError? = nil
    var loadRelatedTopicsError: BookwittyAPIError? = nil
    
    if shouldLoadBookData {
      queue.enter()
      loadBookDetails { (success, error) in
        loadBookDetailsSuccess = success
        loadBookDetailsError = error
        queue.leave()
      }
    } else {
      loadBookDetailsSuccess = true
      loadBookDetailsError = nil
    }
    
    queue.enter()
    loadRelatedReadingLists { (success, error) in
      loadRelatedReadingListsSuccess = success
      loadRelatedReadingListsError = error
      queue.leave()
    }
    
    queue.enter()
    loadRelatedTopics { (success, error) in
      loadRelatedTopicsSuccess = success
      loadRelatedTopicsError = error
      queue.leave()
    }
    
    queue.notify(queue: DispatchQueue.main) { 
      completion(
        loadBookDetailsSuccess && (loadRelatedTopicsSuccess && loadRelatedReadingListsSuccess),
        [loadBookDetailsError, loadRelatedReadingListsError, loadRelatedTopicsError])
    }
  }
  
  func loadBookDetails(completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) {
    guard let bookId = bookId else {
      completion(false, nil)
      return
    }
    
    _ = GeneralAPI.content(of: bookId, include: nil, completion: {
      (success: Bool, book: Book?, error: BookwittyAPIError?) in
      defer {
        completion(success, error)
      }
      
      guard success, let book = book else {
        return
      }
      
      self.book = book
      self.bookId = nil
      self.shouldReloadBookDetailsSections = true
    })
  }
  
  func loadRelatedReadingLists(completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) {
    guard let bookId = book.id else {
      return
    }
    
    _ = GeneralAPI.postsLinkedContent(
      contentIdentifier: bookId, type: [ReadingList.resourceType], completion: {
        (success, resources, nextPage, error) in
        var success: Bool = success
        var error: BookwittyAPIError? = error
        defer {
          completion(success, error)
        }
        
        guard success, let resources = resources else {
          return
        }

        DataManager.shared.update(resources: resources)

        let readingLists = resources.flatMap({ $0 as? ReadingList })
        let displayedReadingLists = Array(readingLists.prefix(self.maximumNumberOfDetails))
        self.relatedReadingLists = (readingLists, displayedReadingLists, nextPage)
        self.shouldReloadRelatedReadingListsSections = true
    })
  }
  
  func loadRelatedTopics(completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) {
    guard let bookId = book.id else {
      return
    }
    
    _ = GeneralAPI.postsLinkedContent(
      contentIdentifier: bookId, type: [Topic.resourceType], completion: {
        (success, resources, nextPage, error) in
        var success: Bool = success
        var error: BookwittyAPIError? = error
        defer {
          completion(success, error)
        }
        
        guard success, let resources = resources else {
          return
        }

        DataManager.shared.update(resources: resources)
        
        let topics = resources.flatMap({ $0 as? Topic })
        let displayedTopics = Array(topics.prefix(self.maximumNumberOfDetails))
        self.relatedTopics = (topics, displayedTopics, nextPage)
        self.shouldReloadRelatedTopicsSections = true
    })
  }
  
  // Wit And Unwit API calls
  
  func witContent(indexPath: IndexPath, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let section = Section(rawValue: indexPath.section), let resourcesCommonProperties = resourcesCommonProperties(for: indexPath), let contentId = resourcesCommonProperties[section.dataIndex(for: indexPath)].id else {
      completionBlock(false)
      return
    }
    
    _ = NewsfeedAPI.wit(contentId: contentId, completion: { (success, error) in
      if success {
        DataManager.shared.updateResource(with: contentId, after: DataManager.Action.wit)
      }
      completionBlock(success)
    })
  }
  
  func unwitContent(indexPath: IndexPath, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let section = Section(rawValue: indexPath.section), let resourcesCommonProperties = resourcesCommonProperties(for: indexPath), let contentId = resourcesCommonProperties[section.dataIndex(for: indexPath)].id else {
      completionBlock(false)
      return
    }
    
    _ = NewsfeedAPI.unwit(contentId: contentId, completion: { (success, error) in
      if success {
        DataManager.shared.updateResource(with: contentId, after: DataManager.Action.unwit)
      }
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
    
    var hasHeaderRow: Bool {
      switch self {
      case .details, .categories, .recommendedReadingLists, .relatedTopics:
        return true
      default:
        return false
      }
    }
    
    func dataIndex(for indexPath: IndexPath) -> Int {
      if hasHeaderRow {
        return (indexPath.item - 1)
      } else {
        return indexPath.item
      }
    }
  }
}

// MARK: - Handle Reading Lists Images
extension BookDetailsViewModel {
  func loadReadingListImages(at indexPath: IndexPath, maxNumberOfImages: Int, completionBlock: @escaping (_ imageCollection: [String]?) -> ()) {
    guard let section = Section(rawValue: indexPath.section), let relatedReadingLists = relatedReadingLists?.prefixed else {
      completionBlock(nil)
      return
    }

    let readingList = relatedReadingLists[section.dataIndex(for: indexPath)]
    guard let readingListId = readingList.id else {
      completionBlock(nil)
      return
    }
    
    let pageSize: String = String(maxNumberOfImages)
    let page: (number: String?, size: String?) = (nil, pageSize)
    _ = GeneralAPI.postsContent(contentIdentifier: readingListId, page: page) {
      (success: Bool, resources: [ModelResource]?, next: URL?, error: BookwittyAPIError?) in
      var imageCollection: [String]? = nil
      defer {
        completionBlock(imageCollection)
      }
      if let resources = resources, success {
        var images: [String] = []
        resources.forEach({ (resource) in
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

// MARK: - PenName Follow/Unfollow
extension BookDetailsViewModel {
  func follow(indexPath: IndexPath, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let section = Section(rawValue: indexPath.section),
      let resources = resourcesCommonProperties(for: indexPath),
      let resourceId = resources[section.dataIndex(for: indexPath)].id else {
        completionBlock(false)
      return
    }
    //Expected types: Topic
    followRequest(identifier: resourceId, completionBlock: completionBlock)
  }

  func unfollow(indexPath: IndexPath, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let section = Section(rawValue: indexPath.section),
      let resources = resourcesCommonProperties(for: indexPath),
      let resourceId = resources[section.dataIndex(for: indexPath)].id else {
        completionBlock(false)
        return
    }
    //Expected types: Topic
    unfollowRequest(identifier: resourceId, completionBlock: completionBlock)
  }

  fileprivate func followRequest(identifier: String, completionBlock: @escaping (_ success: Bool) -> ()) {
    _ = GeneralAPI.follow(identifer: identifier) { (success, error) in
      if success {
        DataManager.shared.updateResource(with: identifier, after: DataManager.Action.follow)
      }
      completionBlock(success)
    }
  }

  fileprivate func unfollowRequest(identifier: String, completionBlock: @escaping (_ success: Bool) -> ()) {
    _ = GeneralAPI.unfollow(identifer: identifier) { (success, error) in
      if success {
        DataManager.shared.updateResource(with: identifier, after: DataManager.Action.unfollow)
      }
      completionBlock(success)
    }
  }
}

extension BookDetailsViewModel {
  fileprivate func resourceFor(id: String?) -> ModelResource? {
    guard let id = id else {
      return nil
    }
    return DataManager.shared.fetchResource(with: id)
  }

  func resource(at indexPath: IndexPath) -> ModelCommonProperties? {
    guard let section = Section(rawValue: indexPath.section),
      let resources = resourcesCommonProperties(for: indexPath) else {
        return nil
    }

    guard indexPath.row > 0 && (section.dataIndex(for: indexPath)) < resources.count else {
      return nil
    }

    let resource = resourceFor(id: resources[section.dataIndex(for: indexPath)].id)
    return resource as? ModelCommonProperties
  }
}

