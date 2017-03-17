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

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.BookProduct)
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
        return self.viewModel.nodeForItem(at: indexPath)
      }
    }
  }
  
  func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
    if let loaderNode = node as? LoaderNode {
      loaderNode.updateLoaderVisibility(show: true)
    }
    
    // Check if cell conforms to protocol base card delegate
    if let cardNode = node as? BaseCardPostNode {
      cardNode.delegate = self
    }
    
    // If cell is reading list handle loading the images
    if let readingListCell = node as? ReadingListCardPostCellNode, let indexPath = node.indexPath,
      !readingListCell.node.isImageCollectionLoaded  {
      let max = readingListCell.node.maxNumberOfImages
      self.viewModel.loadReadingListImages(at: indexPath, maxNumberOfImages: max, completionBlock: { (imageCollection) in
        if let imageCollection = imageCollection, imageCollection.count > 0 {
          readingListCell.node.loadImages(with: imageCollection)
        }
      })
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
    case .buyThisBook(let url):
      buyThisBook(url)
    case .addToWishlist:
      break
    case .viewShippingInfo(let url):
      viewShippingInfo(url)
    case .goToReadingList(let readingList):
      pushPostDetailsViewController(resource: readingList)
    case .goToTopic(let topic):
      viewTopicViewController(with: topic)
    case .viewRelatedReadingLists(let readingLists, let url):
      pushPostsViewController(resources: readingLists, url: url)
    case .viewRelatedTopics(let topics, let url):
      pushPostsViewController(resources: topics, url: url)
    }
  }
  
  fileprivate func viewDetails(_ productDetails: ProductDetails) {
    let node = BookDetailsInformationNode()
    node.productDetails = productDetails
    let genericViewController = GenericNodeViewController(node: node, title: viewModel.book.title)
    self.navigationController?.pushViewController(genericViewController, animated: true)

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.BookDetails)
  }
  
  fileprivate func viewAboutDescription(_ description: String) {
    let externalInsets = UIEdgeInsets(
      top: ThemeManager.shared.currentTheme.generalExternalMargin(),
      left: 0, bottom: 0, right: 0)
    let node = BookDetailsAboutNode(externalInsets: externalInsets)
    node.about = description
    node.dispayMode = .expanded
    let genericViewController = GenericNodeViewController(node: node, title: viewModel.book.title)
    self.navigationController?.pushViewController(genericViewController, animated: true)

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.BookDescription)
  }
  
  fileprivate func viewShippingInfo(_ url: URL) {
    WebViewController.present(url: url, inViewController: self)
  }
  
  fileprivate func buyThisBook(_ url: URL) {
    WebViewController.present(url: url, inViewController: self)
  }
  
  fileprivate func viewCategory(_ category: Category) {
    let categoryViewController = Storyboard.Books.instantiate(CategoryViewController.self)
    categoryViewController.viewModel.category = category
    navigationController?.pushViewController(categoryViewController, animated: true)
  }
  
  fileprivate func shareBook(title: String, url: URL) {
    let activityViewController = UIActivityViewController(
      activityItems: [title, url],
      applicationActivities: nil)
    present(activityViewController, animated: true, completion: nil)
  }
  
  func shareOutsideButton(_ sender: Any?) {
    guard let url = viewModel.bookCanonicalURL else {
      return
    }
    perform(action: .share(bookTitle: self.viewModel.book.title ?? "", url: url))
  }
  
  func viewTopicViewController(with topic: Topic) {
    let topicViewController = TopicViewController()
    topicViewController.initialize(withTopic: topic)
    navigationController?.pushViewController(topicViewController, animated: true)
  }
  
  func pushPostDetailsViewController(resource: Resource) {
    let nodeVc = PostDetailsViewController(resource: resource)
    navigationController?.pushViewController(nodeVc, animated: true)
  }
  
  func pushPostsViewController(resources: [ModelResource]?, url: URL?) {
    let postsViewController = PostsViewController()
    postsViewController.initialize(title: nil, resources: resources, loadingMode: PostsViewModel.DataLoadingMode.server(absoluteURL: url))
    navigationController?.pushViewController(postsViewController, animated: true)
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
    perform(action: .buyThisBook(url))
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
    case buyThisBook(URL)
    case share(bookTitle: String, url: URL)
    case addToWishlist
    case goToReadingList(ReadingList)
    case goToTopic(Topic)
    case viewRelatedReadingLists(readingLists: [ReadingList]?, url: URL?)
    case viewRelatedTopics(topics: [Topic]?, url: URL?)
  }
}

// MARK: - Base card post node delegate
extension BookDetailsViewController: BaseCardPostNodeDelegate {
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
  }
}
