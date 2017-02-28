//
//  TopicViewController.swift
//  Bookwitty
//
//  Created by charles on 2/28/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class TopicViewController: ASViewController<ASDisplayNode> {

  let displayNode: ASDisplayNode
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init() {
    displayNode = ASDisplayNode()
    super.init(node: displayNode)
  }
}
