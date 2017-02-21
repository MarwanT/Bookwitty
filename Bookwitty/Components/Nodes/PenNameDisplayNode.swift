//
//  PenNameDisplayNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/20/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class PenNameDisplayNode: ASControlNode {
  private let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  private let downArrowImageSize: CGSize = CGSize(width: 45, height: 45)

  private let penNameTextNode: ASTextNode
  private let separatorNode: ASDisplayNode
  private let downArrowImageNode: ASImageNode

  private var nodeHeight: CGFloat

  var delegate: PenNameDisplayNodeDelegate?
  var shouldExpand: Bool = true {
    didSet {
    }
  }
  var penNameSummary: String? {
    didSet {
    }
  }

  private override init() {
    penNameTextNode = ASTextNode()
    separatorNode = ASDisplayNode()
    downArrowImageNode = ASImageNode()
    nodeHeight = 45.0 // Temporary value
    super.init()
    automaticallyManagesSubnodes = true
  }

  convenience init(withCellHeight cellHeight: CGFloat) {
    self.init()
    nodeHeight = cellHeight
    setupNodes()
  }

  func setupNodes() {
  }
}
