//
//  RelatedBooksMinimalCellNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/14/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class RelatedBooksMinimalCellNode: ASCellNode {
  fileprivate let cellSize = CGSize.init(width: 90.0, height: 264.0)

  override init() {
    super.init()
    initializeNode()
  }

  func initializeNode() {
    style.preferredSize = cellSize
  }

}
