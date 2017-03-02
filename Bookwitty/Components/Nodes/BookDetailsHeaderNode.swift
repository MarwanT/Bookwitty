//
//  BookDetailsHeaderNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/1/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class BookDetailsHeaderNode: ASDisplayNode {
  fileprivate var imageNode: ASNetworkImageNode
  fileprivate var titleNode: ASTextNode
  fileprivate var authorNode: ASTextNode
  
  override init() {
    imageNode = ASNetworkImageNode()
    titleNode = ASTextNode()
    authorNode = ASTextNode()
    super.init()
  }
}
