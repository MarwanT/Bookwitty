//
//  ReadingListBooksNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/16/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class ReadingListBooksNode: ASDisplayNode {
  private static let defaultImageNodeSize: CGSize = CGSize(width: 60.0, height: 100.0)

  private let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  private var maxItems: Int = 1
  private var imageListNodes: [ReadingListBookNode] = []

  var imageNodeSize: CGSize = defaultImageNodeSize
  var imageCollection: [String]? {
    didSet {
      guard (imageListNodes.count == 0) else { return }
      //TODO: Create Image Nodes and add them as subnodes to this node
    }
  }

  override init() {
    super.init()
    maxItems = calculateMaxItems()
  }

  private func calculateMaxItems() -> Int {
    let screenWidth = UIScreen.main.bounds.width
    return  Int(screenWidth / (imageNodeSize.width + internalMargin)) + 2
  }
}

