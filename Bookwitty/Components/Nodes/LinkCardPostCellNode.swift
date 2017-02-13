//
//  LinkCardPostCellNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/13/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class LinkCardPostCellNode: BaseCardPostNode {
  
  let node: LinkCardPostContentNode
  override var shouldShowInfoNode: Bool { return true }
  override var contentShouldExtendBorders: Bool { return true }
  override var contentNode: ASDisplayNode { return node }

  override init() {
    node = LinkCardPostContentNode()
    super.init()
  }
}

class LinkCardPostContentNode: ASDisplayNode {

  var imageNode: ASNetworkImageNode
  var titleNode: ASTextNode
  var descriptionNode: ASTextNode
  var commentsSummaryNode: ASTextNode

  override init() {
    imageNode = ASNetworkImageNode()
    titleNode = ASTextNode()
    descriptionNode = ASTextNode()
    commentsSummaryNode = ASTextNode()
    super.init()
    addSubnode(imageNode)
    addSubnode(titleNode)
    addSubnode(descriptionNode)
    addSubnode(commentsSummaryNode)
  }
}
