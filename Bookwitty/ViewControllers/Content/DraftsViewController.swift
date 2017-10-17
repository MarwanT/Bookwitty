//
//  DraftsViewController.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/10/13.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class DraftsViewController: ASViewController<ASCollectionNode> {

  fileprivate var flowLayout: UICollectionViewFlowLayout
  fileprivate let collectionNode: ASCollectionNode
  fileprivate let loaderNode: LoaderNode
  fileprivate var loadingStatus: LoadingStatus = .none

  let viewModel = DraftsViewModel()

  init() {
    loaderNode = LoaderNode()

    flowLayout = UICollectionViewFlowLayout()
    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    super.init(node: collectionNode)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    initializeComponents()
    loadDrafts()
  }

  fileprivate func initializeComponents() {
    collectionNode.dataSource = self
    collectionNode.delegate = self
  }

  fileprivate func loadDrafts() {
    loadingStatus = .loading
    viewModel.loadDrafts { (success: Bool, error: BookwittyAPIError?) in
      self.loadingStatus = .none
      self.collectionNode.reloadData()
    }
  }
}

//MARK: - Enum declarations
extension DraftsViewController {
  //Collection Node Sections
  enum Section: Int {
    case drafts
    case activityIndicator

    static let count: Int = 2
  }

  //Loader node loading statuses
  enum LoadingStatus {
    case none
    case loadMore
    case reloading
    case loading
  }

  var showLoader: Bool {
    return loadingStatus != .none
  }
}

//MARK: - ASCollectionDataSource & ASCollectionDelegate implementation
extension DraftsViewController: ASCollectionDataSource, ASCollectionDelegate {
  func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return Section.count
  }

  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    guard let section = Section(rawValue: section) else {
      return 0
    }

    switch section {
    case .drafts:
      return viewModel.numberOfRows()
    case .activityIndicator:
      return showLoader ? 1 : 0
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    return {
      guard let section = Section(rawValue: indexPath.section) else {
        return ASCellNode()
      }

      switch section {
      case .drafts:
        let values = self.viewModel.values(for: indexPath.item)
        let draftNode = DraftNode()
        draftNode.title = values.title
        draftNode.shortDescription = values.updated
        return draftNode
      case .activityIndicator:
        return self.loaderNode
      }
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
    if node is LoaderNode {
      loaderNode.updateLoaderVisibility(show: showLoader)
    }
  }

  public func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
    return ASSizeRange(
      min: CGSize(width: collectionNode.frame.width, height: 0),
      max: CGSize(width: collectionNode.frame.width, height: .infinity)
    )
  }

  func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
    guard let section = Section(rawValue: indexPath.section) else {
      return
    }
  }
}
