//
//  OnBoardingItemHeaderNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/6/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class OnBoardingItemHeaderNode: ASDisplayNode {
  fileprivate let internalMargin: CGFloat = ThemeManager.shared.currentTheme.cardInternalMargin()
  static let nodeHeight: CGFloat = 45.0

  let loaderNode: LoaderNode

  private let titleTextNode: ASTextNode
  private let rotatingImageNode: RotatingImageNode
  private let separator: ASDisplayNode
  var text: String? {
    didSet {
      if let text = text {
        titleTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption1)
          .append(text: text, color: ThemeManager.shared.currentTheme.defaultTextColor()).attributedString
      }
    }
  }
  var isLoading: Bool = false {
    didSet {
      loaderNode.updateLoaderVisibility(show: isLoading)
      rotatingImageNode.isHidden = isLoading
    }
  }

  override init() {
    rotatingImageNode = RotatingImageNode(image: #imageLiteral(resourceName: "downArrow"), size: CGSize(width: 45.0, height: 45.0), direction: .right)
    titleTextNode = ASTextNode()
    separator = ASDisplayNode()
    loaderNode = LoaderNode()
    super.init()
    automaticallyManagesSubnodes = true

    rotatingImageNode.updateDirection(direction: RotatingImageNode.Direction.right, animated: false)

    titleTextNode.style.maxHeight = ASDimensionMake(OnBoardingItemHeaderNode.nodeHeight)
    separator.style.height = ASDimensionMake(1.0)
    separator.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()

    style.height = ASDimensionMake(OnBoardingItemHeaderNode.nodeHeight)
    backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
  }

  func updateArrowDirection(direction: RotatingImageNode.Direction, animated: Bool = true) {
    rotatingImageNode.updateDirection(direction: direction, animated: animated)
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    separator.style.width = ASDimensionMake(constrainedSize.max.width)
    let loadingSpec = ASOverlayLayoutSpec(child: loaderNode, overlay: rotatingImageNode)

    let hStack = ASStackLayoutSpec(direction: .horizontal, spacing: 0, justifyContent: .start,
                                   alignItems: .center, children: [titleTextNode, ASLayoutSpec.spacer(flexGrow: 1.0), loadingSpec])
    let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: internalMargin, bottom: 0, right: 0), child: hStack)
    let centerSpec = ASCenterLayoutSpec(centeringOptions: ASCenterLayoutSpecCenteringOptions.Y, sizingOptions: ASCenterLayoutSpecSizingOptions.minimumX, child: insetSpec)
    centerSpec.style.height = ASDimensionMake(OnBoardingItemHeaderNode.nodeHeight - 1.0)

    let vStack = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .spaceBetween,
                                   alignItems: .stretch, children: [centerSpec, separator])
    
    return vStack
  }
}
