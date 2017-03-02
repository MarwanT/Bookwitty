//
//  ContributorsNode.swift
//  Bookwitty
//
//  Created by charles on 3/2/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ContributorsNode: ASDisplayNode {
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let imageSize: CGSize = CGSize(width: 45.0, height: 45.0)
  fileprivate let imageBorderWidth: CGFloat = 0.0
  fileprivate let imgaeBorderColor: UIColor? = nil

  private var statsNode: ASTextNode
  private var imagesNodes: [ASNetworkImageNode]

  override init() {
    statsNode = ASTextNode()
    imagesNodes = []
    super.init()
    automaticallyManagesSubnodes = true
    setupNode()
  }
  private func setupNode() {
    statsNode.maximumNumberOfLines = 1
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    var nodesArray: [ASLayoutElement] = []


    let canFitImageCount: Int = Int(ceil((constrainedSize.max.width - (statsNode.calculatedSize.width + internalMargin + 1.0)) / (imageSize.width + 5.0)))


    while imagesNodes.count > canFitImageCount {
      _ = imagesNodes.popLast()
    }

    let imagesStackSpec = ASStackLayoutSpec(direction: .horizontal,
                                                         spacing: 5,
                                                         justifyContent: .end,
                                                         alignItems: .center,
                                                         children: imagesNodes)


    nodesArray.append(imagesStackSpec)

    nodesArray.append(spacer(flexGrow: 1.0))
    nodesArray.append(spacer(width: internalMargin))

    nodesArray.append(statsNode)

    let horizontalSpec = ASStackLayoutSpec(direction: .horizontal,
                                                         spacing: 0,
                                                         justifyContent: .end,
                                                         alignItems: .center,
                                                         children: nodesArray)

    let insetSpec = ASInsetLayoutSpec(insets: sideInset(), child: horizontalSpec)
    return insetSpec
  }
}

//Helpers
extension ContributorsNode {
  fileprivate func sideInset() -> UIEdgeInsets {
    return UIEdgeInsets(top: 0,
                        left: internalMargin,
                        bottom: 0,
                        right: internalMargin)
  }

  fileprivate func spacer(flexGrow: CGFloat = 0.0, height: CGFloat = 0.0, width: CGFloat = 0.0) -> ASLayoutSpec {
    return ASLayoutSpec().styled { (style) in
      style.height = ASDimensionMake(height)
      style.width = ASDimensionMake(width)
      style.flexGrow = flexGrow
    }
  }

  fileprivate func isValid(_ value: String?) -> Bool {
    return !value.isEmptyOrNil()
  }
}
