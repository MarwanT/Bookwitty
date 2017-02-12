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
    //TODO: develop logic
  }

  private func addSubnodes(arrayOfNodes: [ASDisplayNode]) {
    //TODO: develop logic
  }

  private func setupCardTheme() {
    //TODO: develop logic
  }
}
