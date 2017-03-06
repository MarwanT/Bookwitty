//
//  DisclosureNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/6/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class DisclosureNode: ASControlNode {
  private let titleTextNode: ASTextNode
  private let imageNode: ASImageNode
  
  override init() {
    imageNode = ASImageNode()
    titleTextNode = ASTextNode()
    super.init()
  }
}
