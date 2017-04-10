//
//  BookCardPostCellNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 4/10/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class BookCardPostCellNode: BaseCardPostNode {

  let node: BookCardPostContentNode
  var showsInfoNode: Bool = false
  override var shouldShowInfoNode: Bool { return showsInfoNode }
  override var contentShouldExtendBorders: Bool { return false }
  override var contentNode: ASDisplayNode { return node }

  override init() {
    node = BookCardPostContentNode()
    super.init()
  }

  convenience init(shouldShowInfoNode: Bool) {
    self.init()
    showsInfoNode = shouldShowInfoNode
  }
}

class BookCardPostContentNode: ASDisplayNode {
}
