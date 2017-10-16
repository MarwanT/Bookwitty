//
//  DraftNode.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/10/16.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class DraftNode: ASCellNode {
  fileprivate let titleNode: ASTextNode
  fileprivate let descriptionNode: ASTextNode

  override init() {
    titleNode = ASTextNode()
    descriptionNode = ASTextNode()
    super.init()
    setupNode()
  }

  fileprivate func setupNode() {
    automaticallyManagesSubnodes = true
  }
}
