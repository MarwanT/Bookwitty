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

  private var imageListNodes: [ReadingListBookNode] = []

  var maxItems: Int = 1
  var imageNodeSize: CGSize = defaultImageNodeSize
  var isImageCollectionLoaded: Bool = false
  private var imageCollection: [String]?

  override init() {
    super.init()
    automaticallyManagesSubnodes = true
    maxItems = calculateMaxItems()
  }

  func reload() {
    guard let imageCollection = imageCollection,
      (imageCollection.count > 0 && imageListNodes.count > 0) else {
      return
    }

    let tillIndex = (maxItems > imageCollection.count) ? imageCollection.count : maxItems
    for index in 0 ..< tillIndex {
      if imageListNodes[index].imageUrl.isEmptyOrNil() {
        imageListNodes[index].imageUrl = imageCollection[index]
      }
    }
  }

  func updateCollection(images collection: [String]?, shouldLoadImages: Bool) {
    guard let imageCollection = collection,
      imageCollection.count > 0 else {
        isImageCollectionLoaded = false
        return
    }
    //Update Local collection
    self.imageCollection = collection

    //Load/Reload Images Into nodes
    if shouldLoadImages {
      prepareImages(for: imageCollection.count)
      if !isImageCollectionLoaded {
        isImageCollectionLoaded = true
        reload()
      }
    }
  }

  func prepareImages(for count: Int) {
    guard imageListNodes.count == 0 && count > 0 else {
      return
    }
    let tillIndex = (maxItems > count) ? count : maxItems

    for _ in 0 ..< tillIndex {
      let imageNode = ReadingListBookNode(imageNodeSize: imageNodeSize)
      imageListNodes.append(imageNode)
      addSubnode(imageNode)
    }
  }

  private func calculateMaxItems() -> Int {
    let screenWidth = UIScreen.main.bounds.width
    return  Int(screenWidth / (imageNodeSize.width + internalMargin)) + 2
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

