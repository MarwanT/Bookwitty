//
//  PostDetailsItemNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/9/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class PostDetailsItemNode: ASDisplayNode {

}

class PostDetailItemNode: ASDisplayNode {
  let imageNode: ASNetworkImageNode
  let headLineNode: ASTextNode
  let subheadLineNode: ASTextNode
  let captionNode: ASTextNode
  let bodyNode: ASTextNode

  override init() {
    imageNode = ASNetworkImageNode()
    headLineNode = ASTextNode()
    subheadLineNode = ASTextNode()
    captionNode = ASTextNode()
    bodyNode = ASTextNode()
    super.init()
    initializeNode()
  }

  func initializeNode() {
    //Image Setup
    imageNode.style.preferredSize = CGSize(width: 75.0, height: 75.0)
    //Body Setup
    bodyNode.maximumNumberOfLines = 7
    //HeadLine Setup
    headLineNode.maximumNumberOfLines = 3
    //subheadLine Setup
    subheadLineNode.maximumNumberOfLines = 2
    //caption Setup
    captionNode.maximumNumberOfLines = 1

    bodyNode.style.flexGrow = 1
    headLineNode.style.flexGrow = 1
    subheadLineNode.style.flexGrow = 1
    captionNode.style.flexGrow = 1

    bodyNode.style.flexShrink = 1
    headLineNode.style.flexShrink = 1
    subheadLineNode.style.flexShrink = 1
    captionNode.style.flexShrink = 1
  }

}
