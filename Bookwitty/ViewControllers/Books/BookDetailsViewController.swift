//
//  BookDetailsViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 3/1/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Spine

class BookDetailsViewController: ASViewController<ASCollectionNode> {
  let viewModel = BookDetailsViewModel()
  
  let collectionNode: ASCollectionNode
  let flowLayout: UICollectionViewFlowLayout
  
  let loaderNode = LoaderNode()
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  init(with book: Book) {
    flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets.zero
    flowLayout.minimumInteritemSpacing  = 0
    flowLayout.minimumLineSpacing       = 0
    
    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    viewModel.book = book
    
    loaderNode.style.width = ASDimensionMake(UIScreen.main.bounds.width)
    
    super.init(node: collectionNode)
    
    viewModel.viewController = self
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = viewModel.viewControllerTitle
    
    collectionNode.delegate = self
    collectionNode.dataSource = self
    
    loadNavigationBarButtons()
    
    showBottomLoader(reloadSection: true)
    viewModel.loadContent { (success, errors) in
      self.hideBottomLoader()
      let sectionsNeedsReloading = self.viewModel.sectionsNeedsReloading()
      self.reloadCollectionViewSections(sections: sectionsNeedsReloading)
    }

    applyLocalization()
    addObservers()

    navigationItem.backBarButtonItem = UIBarButtonItem.back

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.BookProduct)
  }

  private func addObservers() {
    NotificationCenter.default.addObserver(self, selector:
      #selector(self.updatedResources(_:)), name: DataManager.Notifications.Name.UpdateResource, object: nil)

    observeLanguageChanges()
  }
  
  private func loadNavigationBarButtons() {
    let shareButton = UIBarButtonItem(
      image: #imageLiteral(resourceName: "shareOutside"),
      style: UIBarButtonItemStyle.plain,
      target: self,
      action: #selector(shareOutsideButton(_:)))
    navigationItem.rightBarButtonItem = shareButton
  }
  
  func showBottomLoader(reloadSection: Bool = false) {
    viewModel.shouldShowBottomLoader = true
    if reloadSection {
      reloadCollectionViewSections(sections: [BookDetailsViewModel.Section.activityIndicator])
    }
  }
  
  func hideBottomLoader(reloadSection: Bool = false) {
    viewModel.shouldShowBottomLoader = false
    if reloadSection {
      reloadCollectionViewSections(sections: [BookDetailsViewModel.Section.activityIndicator])
    }
  }
  
  func reloadCollectionViewSections(sections: [BookDetailsViewModel.Section]) {
    let mutableIndexSet = NSMutableIndexSet()
    sections.forEach({ mutableIndexSet.add($0.rawValue) })
    collectionNode.reloadSections(mutableIndexSet as IndexSet)
  }

  @objc
  fileprivate func updatedResources(_ notification: NSNotification) {
    let visibleItemsIndexPaths = collectionNode.indexPathsForVisibleItems.filter({
      ($0.section == BookDetailsViewModel.Section.recommendedReadingLists.rawValue
        || $0.section == BookDetailsViewModel.Section.relatedTopics.rawValue)
    })
    
    guard let identifiers = notification.object as? [String],
      identifiers.count > 0,
      visibleItemsIndexPaths.count > 0 else {
        return
    }

    let indexPathForAffectedItems = viewModel.indexPathForAffectedItems(resourcesIdentifiers: identifiers, visibleItemsIndexPaths: visibleItemsIndexPaths)
    collectionNode.performBatchUpdates({
      collectionNode.reloadItems(at: indexPathForAffectedItems)
    }, completion: nil)
  }

}

extension BookDetailsViewController: ASCollectionDataSource, ASCollectionDelegate {
  func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return viewModel.numberOfSections
  }
  
  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    return viewModel.numberOfItemsForSection(section: section)
  }
  
  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    if indexPath.section == BookDetailsViewModel.Section.activityIndicator.rawValue {
      return {
        return self.loaderNode
      }
    } else {
      return {
        let node = self.viewModel.nodeForItem(at: indexPath)
        if let cardNode = node as? BaseCardPostNode {
          self.setupCardNode(baseCardNode: cardNode, indexPath: indexPath)
        }

        return node
      }
    }
  }
  
  func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
    if let loaderNode = node as? LoaderNode {
      loaderNode.updateLoaderVisibility(show: true)
    } else if let card = node as? BaseCardPostNode {
      guard let indexPath = collectionNode.indexPath(for: node),
        let commonResource = viewModel.resource(at: indexPath) else {
          return
      }

      if let sameInstance = card.baseViewModel?.resource?.sameInstanceAs(newResource: commonResource), !sameInstance {
        card.baseViewModel?.resource = commonResource
      }
    }
  }
  
  func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
    return ASSizeRange(
      min: CGSize(width: collectionNode.frame.width, height: 0),
      max: CGSize(width: collectionNode.frame.width, height: .infinity)
    )
  }
  
  func collectionNode(_ collectionNode: ASCollectionNode, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    return viewModel.shouldSelectItem(at: indexPath)
  }
  
  func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
    collectionNode.deselectItem(at: indexPath, animated: true)
    perform(action: viewModel.actionForItem(at: indexPath))
  }

  func setupCardNode(baseCardNode: BaseCardPostNode, indexPath: IndexPath) {
    // Check if cell conforms to protocol base card delegate
    baseCardNode.delegate = self

    if let readingListCell = baseCardNode as? ReadingListCardPostCellNode,
      !readingListCell.node.isImageCollectionLoaded  {
      let max = readingListCell.node.maxNumberOfImages
      self.viewModel.loadReadingListImages(at: indexPath, maxNumberOfImages: max, completionBlock: { (imageCollection) in
        if let imageCollection = imageCollection, imageCollection.count > 0 {
          readingListCell.node.prepareImages(imageCount: imageCollection.count)
          readingListCell.node.loadImages(with: imageCollection)
        }
      })
    }
  }
}

// MARK: - Actions
extension BookDetailsViewController {
  fileprivate func perform(action: Action?) {
    guard let action = action else {
      return
    }
    switch action {
    case .viewImageFullScreen:
      break
    case .viewFormat:
      break
    case .viewCategory(let category):
      viewCategory(category)
    case .viewDescription(let description):
      viewAboutDescription(description)
    case .viewDetails(let productDetails):
      viewDetails(productDetails)
    case .share(let title, let url):
      shareBook(title: title, url: url)
    case .buyThisBook(let bookTitle, let url):
      buyThisBook(bookTitle: bookTitle, url: url)
    case .addToWishlist:
      break
    case .viewShippingInfo(let url):
      viewShippingInfo(url)
    case .goToReadingList(let readingList):
      pushPostDetailsViewController(resource: readingList)
    case .goToTopic(let topic):
      viewTopicViewController(with: topic)
    case .viewRelatedReadingLists(let bookTitle, let readingLists, let url):
      pushPostsViewController(bookTitle: bookTitle, resources: readingLists, url: url)
    case .viewRelatedTopics(let bookTitle, let topics, let url):
      pushPostsViewController(bookTitle: bookTitle, resources: topics, url: url)
    }
  }
  
  fileprivate func viewDetails(_ productDetails: ProductDetails) {
    let node = BookDetailsInformationNode()
    node.productDetails = productDetails
    let genericViewController = GenericNodeViewController(node: node, title: viewModel.book.title)
    self.navigationController?.pushViewController(genericViewController, animated: true)

    //MARK: [Analytics] Event
    let event: Analytics.Event = Analytics.Event(category: .BookProduct,
                                                 action: .GoToDetails)
    Analytics.shared.send(event: event)

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.BookDetails)
  }
  
  fileprivate func viewAboutDescription(_ description: String) {
    let externalInsets = UIEdgeInsets(
      top: ThemeManager.shared.currentTheme.generalExternalMargin(),
      left: 0, bottom: 0, right: 0)
    let node = BookDetailsAboutNode(externalInsets: externalInsets)
    node.setText(aboutText: description, displayMode: .expanded)
    let genericViewController = GenericNodeViewController(node: node, title: viewModel.book.title)
    self.navigationController?.pushViewController(genericViewController, animated: true)

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.BookDescription)
  }
  
  fileprivate func viewShippingInfo(_ url: URL) {
    WebViewController.present(url: url)
  }
  
  fileprivate func buyThisBook(bookTitle: String, url: URL) {
    WebViewController.present(url: url)

    //MARK: [Analytics] Event
    let event: Analytics.Event = Analytics.Event(category: .BookProduct,
                                                 action: .BuyThisBook,
                                                 name: bookTitle)
    Analytics.shared.send(event: event)
  }
  
  fileprivate func viewCategory(_ category: Category) {
    let categoryViewController = Storyboard.Books.instantiate(CategoryViewController.self)
    categoryViewController.viewModel.category = category
    navigationController?.pushViewController(categoryViewController, animated: true)

    //MARK: [Analytics] Event
    let event: Analytics.Event = Analytics.Event(category: .BookProduct,
                                                 action: .GoToCategory,
                                                 name: category.value ?? "")
    Analytics.shared.send(event: event)
  }
  
  fileprivate func shareBook(title: String, url: URL) {
    presentShareSheet(shareContent: [title, url])

    //MARK: [Analytics] Event
    let event: Analytics.Event = Analytics.Event(category: .BookProduct,
                                                 action: .Share,
                                                 name: title)
    Analytics.shared.send(event: event)
  }
  
  func shareOutsideButton(_ sender: Any?) {
    guard let url = viewModel.bookCanonicalURL else {
      return
    }
    perform(action: .share(bookTitle: self.viewModel.book.title ?? "", url: url))
  }
  
  func viewTopicViewController(with topic: Topic) {
    let topicViewController = TopicViewController()
    topicViewController.initialize(with: topic as? ModelCommonProperties)
    navigationController?.pushViewController(topicViewController, animated: true)
  }
  
  func pushPostDetailsViewController(resource: Resource) {
    let nodeVc = PostDetailsViewController(resource: resource)
    navigationController?.pushViewController(nodeVc, animated: true)
  }
  
  func pushPostsViewController(bookTitle: String, resources: [ModelResource]?, url: URL?) {
    let postsViewController = PostsViewController()
    postsViewController.initialize(title: nil, resources: resources, loadingMode: PostsViewModel.DataLoadingMode.server(absoluteURL: url))
    navigationController?.pushViewController(postsViewController, animated: true)

    //MARK: [Analytics] Event
    let action: Analytics.Action
    if resources?.contains(where: { $0.registeredResourceType == ReadingList.resourceType }) ?? false {
      action = .ViewAllReadingLists
    } else if resources?.contains(where: { $0.registeredResourceType == ReadingList.resourceType }) ?? false {
      action = .ViewAllTopics
    } else {
      action = .Default
    }

    let event: Analytics.Event = Analytics.Event(category: .BookProduct,
                                                 action: action,
                                                 name: bookTitle)
    Analytics.shared.send(event: event)
  }
}

// MARK: - Book details about node
extension BookDetailsViewController: BookDetailsAboutNodeDelegate {
  func aboutNodeDidTapViewDescription(aboutNode: BookDetailsAboutNode) {
    guard let description = aboutNode.about else {
      return
    }
    perform(action: .viewDescription(description))
  }
}

// MARK: - Book details e-commerce node
extension BookDetailsViewController: BookDetailsECommerceNodeDelegate {
  func eCommerceNodeDidTapOnBuyBook(node: BookDetailsECommerceNode) {
    guard let url = viewModel.bookCanonicalURL else {
      return
    }
    let title = self.viewModel.book.title ?? ""
    perform(action: .buyThisBook(bookTitle: title, url))
  }
  
  func eCommerceNodeDidTapOnShippingInformation(node: BookDetailsECommerceNode) {
    guard let url = viewModel.shipementInfoURL else {
      return
    }
    perform(action: .viewShippingInfo(url))
  }
}

// MARK: - Declarations
extension BookDetailsViewController {  
  enum Action {
    case viewImageFullScreen
    case viewFormat
    case viewDetails(ProductDetails)
    case viewCategory(Category)
    case viewDescription(String)
    case viewShippingInfo(URL)
    case buyThisBook(bookTitle: String, URL)
    case share(bookTitle: String, url: URL)
    case addToWishlist
    case goToReadingList(ReadingList)
    case goToTopic(Topic)
    case viewRelatedReadingLists(bookTitle: String, readingLists: [ReadingList]?, url: URL?)
    case viewRelatedTopics(bookTitle: String, topics: [Topic]?, url: URL?)
  }
}

// MARK: - Base card post node delegate
extension BookDetailsViewController: BaseCardPostNodeDelegate {
  func cardInfoNode(card: BaseCardPostNode, cardPostInfoNode: CardPostInfoNode, didRequestAction action: CardPostInfoNode.Action, forSender sender: Any) {
    guard let indexPath = collectionNode.indexPath(for: card) else {
      return
    }
    let resourcesCommonProperties = viewModel.resourcesCommonProperties(for: indexPath)
    if let resource = resourcesCommonProperties?[indexPath.row - 1],
      let penName = resource.penName {

      pushProfileViewController(penName: penName)

      //MARK: [Analytics] Event
      let category: Analytics.Category
      switch resource.registeredResourceType {
      case Image.resourceType:
        category = .Image
      case Quote.resourceType:
        category = .Quote
      case Video.resourceType:
        category = .Video
      case Audio.resourceType:
        category = .Audio
      case Link.resourceType:
        category = .Link
      case Author.resourceType:
        category = .Author
      case ReadingList.resourceType:
        category = .ReadingList
      case Topic.resourceType:
        category = .Topic
      case Text.resourceType:
        category = .Text
      case Book.resourceType:
        category = .TopicBook
      case PenName.resourceType:
        category = .PenName
      default:
        category = .Default
      }
      let event: Analytics.Event = Analytics.Event(category: category,
                                                   action: .GoToPenName,
                                                   name: penName.name ?? "")
      Analytics.shared.send(event: event)
    }
  }
  
  func cardActionBarNode(card: BaseCardPostNode, cardActionBar: CardActionBarNode, didRequestAction action: CardActionBarNode.Action, forSender sender: ASButtonNode, didFinishAction: ((_ success: Bool) -> ())?) {
    guard let indexPath = card.indexPath else {
      return
    }
    
    switch(action) {
    case .wit:
      viewModel.witContent(indexPath: indexPath) { (success) in
        didFinishAction?(success)
      }
    case .unwit:
      viewModel.unwitContent(indexPath: indexPath) { (success) in
        didFinishAction?(success)
      }
    case .share:
      if let sharingInfo: [String] = viewModel.sharingContent(indexPath: indexPath) {
        presentShareSheet(shareContent: sharingInfo)
      }
    case .follow:
      viewModel.follow(indexPath: indexPath) { (success) in
        didFinishAction?(success)
      }
    case .unfollow:
      viewModel.unfollow(indexPath: indexPath) { (success) in
        didFinishAction?(success)
      }
    default:
      //TODO: handle comment
      break
    }

    //MARK: [Analytics] Event
    guard let resource = viewModel.resource(at: indexPath) else { return }
    let category: Analytics.Category
    switch resource.registeredResourceType {
    case Image.resourceType:
      category = .Image
    case Quote.resourceType:
      category = .Quote
    case Video.resourceType:
      category = .Video
    case Audio.resourceType:
      category = .Audio
    case Link.resourceType:
      category = .Link
    case Author.resourceType:
      category = .Author
    case ReadingList.resourceType:
      category = .ReadingList
    case Topic.resourceType:
      category = .Topic
    case Text.resourceType:
      category = .Text
    case Book.resourceType:
      category = .TopicBook
    case PenName.resourceType:
      category = .PenName
    default:
      category = .Default
    }

    let name: String = resource.title ?? ""
    let analyticsAction = Analytics.Action.actionFrom(cardAction: action, with: category)
    let event: Analytics.Event = Analytics.Event(category: category,
                                                 action: analyticsAction,
                                                 name: name)
    Analytics.shared.send(event: event)
  }
}

//MARK: - Localizable implementation
extension BookDetailsViewController: Localizable {
  func applyLocalization() {
    collectionNode.reloadData()
  }

  fileprivate func observeLanguageChanges() {
    NotificationCenter.default.addObserver(self, selector: #selector(languageValueChanged(notification:)), name: Localization.Notifications.Name.languageValueChanged, object: nil)
  }

  @objc
  fileprivate func languageValueChanged(notification: Notification) {
    applyLocalization()
  }
}
