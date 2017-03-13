//
//  BookDetailsViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 3/1/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class BookDetailsViewController: ASViewController<ASCollectionNode> {
  let viewModel = BookDetailsViewModel()
  
  let collectionNode: ASCollectionNode
  let flowLayout: UICollectionViewFlowLayout
  
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
    
    super.init(node: collectionNode)
    
    viewModel.viewController = self
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = viewModel.viewControllerTitle
    
    collectionNode.delegate = self
    collectionNode.dataSource = self
    
    loadNavigationBarButtons()
    
    viewModel.loadContent { (success, errors) in
      // TODO: Handle reloading the content
      self.collectionNode.reloadData()
    }
  }
  
  private func loadNavigationBarButtons() {
    let shareButton = UIBarButtonItem(
      image: #imageLiteral(resourceName: "shareOutside"),
      style: UIBarButtonItemStyle.plain,
      target: self,
      action: #selector(shareOutsideButton(_:)))
    navigationItem.rightBarButtonItem = shareButton
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
    return {
      return self.viewModel.nodeForItem(at: indexPath)
    }
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
    }
  }
  
  fileprivate func viewDetails(_ productDetails: ProductDetails) {
    let node = BookDetailsInformationNode()
    node.productDetails = productDetails
    let genericViewController = GenericNodeViewController(node: node, title: viewModel.book.title)
    self.navigationController?.pushViewController(genericViewController, animated: true)
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
  }
}
