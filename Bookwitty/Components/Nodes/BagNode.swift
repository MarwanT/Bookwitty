//
//  BagNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/11/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit


class BagNode: ASDisplayNode {
  fileprivate let textNode: ASTextNode
  fileprivate let shopOnlineButton: ASButtonNode
  
  override init() {
    textNode = ASTextNode()
    shopOnlineButton = ASButtonNode()
    super.init()
  }
}
