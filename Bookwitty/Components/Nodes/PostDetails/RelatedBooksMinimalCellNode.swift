//
//  RelatedBooksMinimalCellNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/14/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class RelatedBooksMinimalCellNode: ASCellNode {
  fileprivate let cellSize = CGSize.init(width: 90.0, height: 264.0)

  fileprivate let imageNode: ASNetworkImageNode
  fileprivate let titleNode: ASTextNode
  fileprivate let subTitleNode: ASTextNode
  fileprivate let priceNode: ASTextNode

  override init() {
    imageNode = ASNetworkImageNode()
    titleNode = ASTextNode()
    subTitleNode = ASTextNode()
    priceNode = ASTextNode()
    super.init()
    automaticallyManagesSubnodes = true
    initializeNode()
  }

  func initializeNode() {
    style.preferredSize = cellSize
  }

}
