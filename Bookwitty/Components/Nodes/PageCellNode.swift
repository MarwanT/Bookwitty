//
//  PageCellNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 5/15/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class PageCellNode: ASCellNode {

  override init() {
    super.init()
    automaticallyManagesSubnodes = true
    setupNode()
  }

  private func setupNode() {
    //TODO: Setup the node
  }

}

// MARK: - Layout
extension PageCellNode {
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    //TODO: Implement layout
    return ASLayoutSpec()
  }
}
