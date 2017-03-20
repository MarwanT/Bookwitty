//
//  ReadingListsViewController.swift
//  Bookwitty
//
//  Created by charles on 3/8/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ReadingListsViewController: ASViewController<ASCollectionNode> {
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()

  fileprivate let collectionNode: ASCollectionNode
  fileprivate let flowLayout: UICollectionViewFlowLayout

  fileprivate let viewModel = ReadingListsViewModel()

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init() {
    flowLayout = UICollectionViewFlowLayout()
    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    super.init(node: collectionNode)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = Strings.reading_lists()

    collectionNode.dataSource = self
    collectionNode.delegate = self

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.ReadingLists)
  }

  private func initializeComponents() {
    
  }

  func initialize(with lists: [ReadingList]) {
    viewModel.initialize(with: lists)
    collectionNode.reloadData()
  }
}

//MARK: -
extension ReadingListsViewController: ASCollectionDataSource, ASCollectionDelegate {
  func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return 1
  }

  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    return viewModel.numberOfItems()
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    guard let readingList = viewModel.readingList(at: indexPath.item) else {
      return { ASCellNode() }
    }

    return {
      guard let readingListNode = CardFactory.shared.createCardFor(resource: readingList) else {
        return ASCellNode()
      }
      return readingListNode
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
    if let indexPath = collectionNode.indexPath(for: node), indexPath.item % 7 == 0 {
      viewModel.loadNextReadingListPageContent(closure: {
        (success, indices) in
        self.collectionNode.reloadItems(at: indices.map({ IndexPath(item: $0, section: 0) }))
      })
    }
  }

  public func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
    return ASSizeRange(
      min: CGSize(width: collectionNode.frame.width, height: 0),
      max: CGSize(width: collectionNode.frame.width, height: .infinity)
    )
  }
}
