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

  init() {
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
  }

  fileprivate func initializeComponents() {
    collectionNode.dataSource = self
    collectionNode.delegate = self
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
      return 0
    case .activityIndicator:
      return 1
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    return {
      guard let section = Section(rawValue: indexPath.section) else {
        return ASCellNode()
      }

      switch section {
      case .drafts:
        return ASCellNode()
      case .activityIndicator:
        return ASCellNode()
      }
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
