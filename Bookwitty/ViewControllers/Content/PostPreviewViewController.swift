//
//  PostPreviewViewController.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/10/06.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class PostPreviewViewController: ASViewController<ASCollectionNode> {

  enum Sections: Int {
    case customize
    case penName
    case cover
    case title
    case description
    case newCover
    case newTitle

    static let count: Int = 7
  }
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
    
  }
}

extension PostPreviewViewController: ASCollectionDataSource, ASCollectionDelegate {
  func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return Sections.count
  }

  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    guard let section = Sections(rawValue: section) else {
      return 0
    }

    switch section {
    case .penName:
      return 0
    case .cover:
      return 0
    case .title:
      return 0
    case .description:
      return 0
    case .characters:
      return 0
    case .newCover:
      return 0
    case .newTitle:
      return 0
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    return {
      return ASCellNode()
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {

  }

  public func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
    return ASSizeRange(
      min: CGSize(width: collectionNode.frame.width, height: 0),
      max: CGSize(width: collectionNode.frame.width, height: .infinity)
    )
  }

  func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {

  }
}
