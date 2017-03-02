//
//  BookDetailsFormatNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/2/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class BookDetailsFormatNode: ASControlNode {
  fileprivate let textNode: ASTextNode
  
  
  override init() {
    textNode = ASTextNode()
    super.init()
  }
}
