//
//  BaseCardPostNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/12/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class BaseCardPostNode: ASCellNode {

  private(set) var infoNode: CardPostInfoNode
  private(set) var actionBarNode: CardActionBarNode
  private(set) var backgroundNode: ASDisplayNode

  override init() {
    infoNode = CardPostInfoNode()
    actionBarNode = CardActionBarNode(delegate: nil)
    backgroundNode = ASDisplayNode()
    super.init()
    setupCellNode()
  }

  private func setupCellNode() {
    manageNodes()
    setupCardTheme()
  }

  private func manageNodes() {
    guard subnodes.count == 0 else { return }

    //Order is important: backgroundNode must be the first
    if(shouldShowInfoNode) {
      addSubnodes(arrayOfNodes: [backgroundNode, infoNode, contentNode, actionBarNode])
    } else {
      addSubnodes(arrayOfNodes: [backgroundNode, contentNode, actionBarNode])
    }
  }

  private func addSubnodes(arrayOfNodes: [ASDisplayNode]) {
    arrayOfNodes.forEach { (node) in
      addSubnode(node)
    }
  }

  private func setupCardTheme() {
    //TODO: develop logic
  }
}
