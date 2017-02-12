//
//  ArticleCardPostCellNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/13/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class ArticleCardPostCellNode: BaseCardPostNode {

  let node: ArticleCardContentNode
  override var shouldShowInfoNode: Bool { return true }
  override var contentShouldExtendBorders: Bool { return true }
  override var contentNode: ASDisplayNode { return node }

  override init() {
    node = ArticleCardContentNode()
    super.init()
  }
}

class ArticleCardContentNode: ASDisplayNode {
  override init() {
    super.init()
  }
}
