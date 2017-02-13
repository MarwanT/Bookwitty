//
//  PhotoCardPostCellNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/13/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class PhotoCardPostCellNode: BaseCardPostNode {
  let node: PhotoCardContentNode
  override var shouldShowInfoNode: Bool { return true }
  override var contentShouldExtendBorders: Bool { return true }
  override var contentNode: ASDisplayNode { return node }

  override init() {
    node = PhotoCardContentNode()
    super.init()
  }
}

class PhotoCardContentNode: ASDisplayNode {
  var imageNode: ASNetworkImageNode
  override init() {
    imageNode = ASNetworkImageNode()
    super.init()
    addSubnode(imageNode)
  }
}
