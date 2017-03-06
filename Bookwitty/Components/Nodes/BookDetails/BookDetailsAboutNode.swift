//
//  BookDetailsAboutNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/6/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class BookDetailsAboutNode: ASDisplayNode {
  fileprivate let headerNode: SectionTitleHeaderNode
  fileprivate let descriptionTextNode: ASTextNode
  fileprivate let viewDescription: DisclosureNode
  fileprivate let topSeparator: ASDisplayNode
  fileprivate let bottomSeparator: ASDisplayNode
  
  
  override init() {
    headerNode = SectionTitleHeaderNode()
    descriptionTextNode = ASTextNode()
    viewDescription = DisclosureNode()
    topSeparator = ASDisplayNode()
    bottomSeparator = ASDisplayNode()
    super.init()
  }
}
