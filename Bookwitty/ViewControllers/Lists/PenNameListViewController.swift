//
//  PenNameListViewController.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 6/22/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class PenNameListViewController: ASViewController<ASCollectionNode> {

  fileprivate let collectionNode: ASCollectionNode
  fileprivate var flowLayout: UICollectionViewFlowLayout

  fileprivate let viewModel = PenNameListViewModel()

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init() {
    flowLayout = UICollectionViewFlowLayout()
    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    super.init(node: collectionNode)
  }

  func initialize(with penNames: [PenName]) {
    viewModel.initialize(with: penNames)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    initializeComponents()

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.PenNameList)
  }

  fileprivate func initializeComponents() {
    collectionNode.delegate = self
    collectionNode.dataSource = self

    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing = 0
    flowLayout.sectionHeadersPinToVisibleBounds = true
  }
}

extension PenNameListViewController: ASCollectionDataSource, ASCollectionDelegate {
  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    return 5 //TODO: Set the value
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    return {
      let node = PenNameFollowNode()
      node.showBottomSeparator = true
      return node
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
    guard let indexPath = collectionNode.indexPath(for: node),
      let cell = node as? PenNameFollowNode else {
        return
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
    //TODO: push the pen name details vc
  }
}
