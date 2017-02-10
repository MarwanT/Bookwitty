//
//  NewsFeedViewController.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/8/17.
//  Copyright © 2017 Keeward. All rights reserved.
//
import UIKit
import AsyncDisplayKit

class NewsFeedViewController: ASViewController<ASCollectionNode> {
  let collectionNode: ASCollectionNode
  let flowLayout: UICollectionViewFlowLayout

  let data = [
    "Test Test Test",
    "Test Test Test Test Test Test Test Test Test Test Test Test",
    "Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test",
    "Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test"
  ]

  init() {
    flowLayout = UICollectionViewFlowLayout()
    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)

    super.init(node: collectionNode)

    collectionNode.delegate = self
    flowLayout.minimumInteritemSpacing  = 1
    flowLayout.minimumLineSpacing       = 1
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    collectionNode.delegate = self
    collectionNode.dataSource = self
  }
}

extension NewsFeedViewController: ASCollectionDataSource {
  func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return data.count > 0 ? 1 : 0
  }

  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    return data.count
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    let text = self.data[indexPath.row]

    return {
      let cell = CellNode()
      cell.text = text
      return cell
    }
  }
}

extension NewsFeedViewController: ASCollectionDelegate {
  public func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
    return ASSizeRange(
      min: CGSize(width: collectionNode.frame.width, height: 0),
      max: CGSize(width: collectionNode.frame.width, height: .infinity)
    )
  }
}
