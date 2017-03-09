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
    super.init(node: node)
    self.title = title
  }
}
