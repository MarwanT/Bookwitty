//
//  ReadingListCardPostCellNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/15/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class ReadingListCardPostCellNode: BaseCardPostNode {
  let node: ReadingListCardContentNode
  override var shouldShowInfoNode: Bool { return true }
  override var contentShouldExtendBorders: Bool { return true }
  override var contentNode: ASDisplayNode { return node }

  override init() {
    node = ReadingListCardContentNode()
    super.init()
  }
}

class ReadingListCardContentNode: ASDisplayNode {
  private var titleNode: ASTextNode
  private var topicStatsNode: ASTextNode
  private var descriptionNode: ASTextNode

  override init() {
    titleNode = ASTextNode()
    topicStatsNode = ASTextNode()
    descriptionNode = ASTextNode()
    super.init()
    addSubnode(titleNode)
    addSubnode(topicStatsNode)
    addSubnode(descriptionNode)
    setupNode()
  }

  func setupNode() {
    titleNode.maximumNumberOfLines = 3
    descriptionNode.maximumNumberOfLines = 3
    topicStatsNode.maximumNumberOfLines = 1
  }

}
