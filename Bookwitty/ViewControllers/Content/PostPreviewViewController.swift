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

  fileprivate let penNameNode: PenNameCellNode
  fileprivate let titleNode: EditableTextNode
  fileprivate let descriptionNode: LimitedEditableTextNode
  fileprivate let coverNode: CoverPhotoNode

  fileprivate var flowLayout: UICollectionViewFlowLayout
  fileprivate let collectionNode: ASCollectionNode
  
  init() {
    penNameNode = PenNameCellNode(withSeparator: false, withCellHeight: 45.0)
    titleNode = EditableTextNode()
    descriptionNode = LimitedEditableTextNode()
    coverNode = CoverPhotoNode()

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
    applyTheme()
  }

  fileprivate func initializeComponents() {
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing = 0

    collectionNode.delegate = self
    collectionNode.dataSource = self
  }
}

//MARK: - Themeable implementation
extension PostPreviewViewController: Themeable {
  func applyTheme() {
    collectionNode.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
    penNameNode.backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
    coverNode.backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
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
    case .customize:
      return 0
    case .penName:
      return 0
    case .cover:
      return 0
    case .title:
      return 0
    case .description:
      return 0
    case .newCover:
      return 0
    case .newTitle:
      return 0
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    return {
      guard let section = Sections(rawValue: indexPath.section) else {
        return ASCellNode()
      }

      switch section {
      case .customize:
        return ASCellNode()
      case .penName:
        return ASCellNode()
      case .cover:
        return ASCellNode()
      case .title:
        return ASCellNode()
      case .description:
        return ASCellNode()
      case .newCover:
        return ASCellNode()
      case .newTitle:
        return ASCellNode()
      }
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

  fileprivate func createSeparatorNode() -> ASCellNode {
    let separatorNode = ASCellNode()
    separatorNode.style.height = ASDimensionMake(1)
    separatorNode.style.flexGrow = 0.0
    separatorNode.style.flexShrink = 1
    separatorNode.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    return separatorNode
  }
}
