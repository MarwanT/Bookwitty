//
//  TagCardPostCellNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/28/18.
//  Copyright © 2018 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class TagCardPostCellNode: BaseCardPostNode {
  let node: ASDisplayNode
  var showsInfoNode: Bool = false
  override var shouldShowInfoNode: Bool { return showsInfoNode }
  override var contentShouldExtendBorders: Bool { return false }
  override var contentNode: ASDisplayNode { return node }

  //TODO: define the view model
  override var baseViewModel: CardViewModelProtocol? {
    //TODO: return view model
    return nil
  }

  override init() {
    node = ASDisplayNode()
    //TODO: Initialize View model
    super.init()
    shouldHandleTopComments = true
    //TODO: Set View model delegate
  }

  convenience init(shouldShowInfoNode: Bool) {
    self.init()
    showsInfoNode = shouldShowInfoNode
  }
}
