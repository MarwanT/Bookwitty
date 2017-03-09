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
  }
  
}
