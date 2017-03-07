//
//  DetailsInfoCellNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/7/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class DetailsInfoCellNode: ASCellNode {
  fileprivate var keyTextNode: ASTextNode
  fileprivate var valueTextNode: ASTextNode
  
  override init() {
    keyTextNode = ASTextNode()
    valueTextNode = ASTextNode()
    super.init()
  }
}
