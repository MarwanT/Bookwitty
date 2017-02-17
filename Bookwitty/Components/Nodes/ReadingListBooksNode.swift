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
      if let imageCollection = imageCollection, (imageCollection.count > 0) {
        createImageNodes(imageCollection: imageCollection)
      }
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

  private func createImageNodes(imageCollection: [String]) {
    let tillIndex = (maxItems > imageCollection.count) ? imageCollection.count : maxItems

    for index in 0 ..< tillIndex {
      let url = imageCollection[index]
      let imageNode = ReadingListBookNode(imageNodeSize: imageNodeSize)
      imageNode.imageUrl = url
      imageListNodes.append(imageNode)
      addSubnode(imageNode)
    }
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let horizontalStack = ASStackLayoutSpec(direction: .horizontal,
                                          spacing: internalMargin/2,
                                          justifyContent: .center,
                                          alignItems: .center,
                                          children: imageListNodes)
    horizontalStack.style.height = ASDimensionMake(imageNodeSize.height)
    return horizontalStack
  }
}

