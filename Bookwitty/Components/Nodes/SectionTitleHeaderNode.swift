//
//  SectionTitleHeaderNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/5/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class SectionTitleHeaderNode: ASDisplayNode {
  fileprivate let verticalBarNode: ASDisplayNode
  fileprivate let horizontalBarNode: ASDisplayNode
  fileprivate let titleNode: ASTextNode
  
  override init() {
    verticalBarNode = ASDisplayNode()
    horizontalBarNode = ASDisplayNode()
    titleNode = ASTextNode()
    super.init()
  }
}
