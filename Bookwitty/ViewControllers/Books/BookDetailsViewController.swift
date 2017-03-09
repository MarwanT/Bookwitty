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
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = viewModel.viewControllerTitle
    
    collectionNode.delegate = self
    collectionNode.dataSource = self
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
    case .viewCategory:
      break
    case .viewDescription:
      break
    case .viewDetails:
      viewDetails()
    case .share:
      break
    case .buyThisBook:
      buyThisBook()
    case .addToWishlist:
      break
    case .viewShippingInfo:
      viewShippingInfo()
    }
  }
  
  fileprivate func viewDetails() {
    print("View Details")
  }
  
  fileprivate func viewShippingInfo() {
    print("View Shipping Info")
  }
  
  fileprivate func buyThisBook() {
    print("Buy This Book")
  }
}

// MARK: - Declarations
extension BookDetailsViewController {
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
  
  enum Action {
    case viewImageFullScreen
    case viewFormat
    case viewDetails
    case viewCategory
    case viewDescription
    case viewShippingInfo
    case buyThisBook
    case share
    case addToWishlist
  }
}
