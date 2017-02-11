//
//  CardActionBarNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/11/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class CardActionBarNode: ASCellNode {

  var witButton: ASButtonNode
  var commentButton: ASButtonNode
  var shareButton: ASButtonNode

  private override init() {
    witButton = ASButtonNode()
    commentButton = ASButtonNode()
    shareButton = ASButtonNode()
    super.init()
    addSubnode(witButton)
    addSubnode(commentButton)
    addSubnode(shareButton)
  }
}
