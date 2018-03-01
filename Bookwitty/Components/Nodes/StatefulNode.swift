//
//  StatefulNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/28/18.
//  Copyright © 2018 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class StatefulNode: ASCellNode {
  fileprivate let captionNode: ASTextNode
  fileprivate let actionNode: ASTextNode
  fileprivate let illustrationNode: ASImageNode
  fileprivate let colorNode: ASDisplayNode
  fileprivate let misfortuneNode: MisfortuneNode

  override init() {
    captionNode = ASTextNode()
    actionNode = ASTextNode()
    illustrationNode = ASImageNode()
    colorNode = ASDisplayNode()
    misfortuneNode = MisfortuneNode(mode: MisfortuneNode.Mode.empty)
    super.init()
    automaticallyManagesSubnodes = true
  }
}
