//
//  GenericNodeViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 3/9/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class GenericNodeViewController: ASViewController<ASDisplayNode> {
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  init(node: ASDisplayNode, title: String? = nil) {
    let baseNode = GenericNodeViewController.encapsulateWithScrollNodeIfNeeded(node: node)
    super.init(node: baseNode)
    self.title = title
  }
  
  private static func encapsulateWithScrollNodeIfNeeded(node: ASDisplayNode) -> ASDisplayNode {
    guard !(node.view is UIScrollView) else {
      return node
    }
    
    let scrollNode = ASScrollNode()
    scrollNode.automaticallyManagesSubnodes = true
    scrollNode.automaticallyManagesContentSize = true
    scrollNode.layoutSpecBlock = { displayNode, constrainedSize in
      let stack = ASStackLayoutSpec(
        direction: .vertical,
        spacing: 0,
        justifyContent: .start,
        alignItems: .stretch,
        children: [node])
      return stack
    }
    return scrollNode
  }
}
