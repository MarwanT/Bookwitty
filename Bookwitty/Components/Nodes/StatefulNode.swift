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
  let captionNode: ASTextNode
  let actionNode: ASTextNode
  let illustrationNode: ASImageNode
  let misfortuneNode: MisfortuneNode

  override init() {
    captionNode = ASTextNode()
    actionNode = ASTextNode()
    illustrationNode = ASImageNode()
    misfortuneNode = MisfortuneNode(mode: MisfortuneNode.Mode.empty)
    super.init()
  }
}
