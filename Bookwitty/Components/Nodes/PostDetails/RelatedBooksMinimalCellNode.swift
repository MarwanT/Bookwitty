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
  static let cellHeight: CGFloat = 300.0
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()
  fileprivate let cellSize = CGSize(width: 100.0, height: RelatedBooksMinimalCellNode.cellHeight)
  fileprivate let imageSize = CGSize(width: 100.0, height: 150.0)

  fileprivate let imageNode: ASNetworkImageNode
  fileprivate let titleNode: ASTextNode
  fileprivate let subTitleNode: ASTextNode
  fileprivate let priceNode: ASTextNode

  var url: String? {
    didSet {
      if let url = url {
        imageNode.url = URL(string: url)
      }
    }
  }
  var title: String? {
    didSet {
      if let title = title {
        titleNode.attributedText = AttributedStringBuilder(fontDynamicType: .title4)
          .append(text: title).attributedString
        setNeedsLayout()
      }
    }
  }
  var subTitle: String? {
    didSet {
      if let subTitle = subTitle {
        subTitleNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption1)
          .append(text: subTitle).attributedString
        setNeedsLayout()
      }
    }
  }
  var price: String? {
    didSet {
      if let price = price {
        priceNode.attributedText = AttributedStringBuilder(fontDynamicType: .footnote)
          .append(text: price, color: ThemeManager.shared.currentTheme.defaultEcommerceButtonColor()).attributedString
        setNeedsLayout()
      }
    }
  }

  override init() {
    imageNode = ASNetworkImageNode()
    titleNode = ASTextNode()
    subTitleNode = ASTextNode()
    priceNode = ASTextNode()
    super.init()
    automaticallyManagesSubnodes = true
    initializeNode()
  }

  func initializeNode() {
    style.preferredSize = cellSize
    imageNode.style.preferredSize = imageSize
    imageNode.animatedImagePaused = true

    titleNode.maximumNumberOfLines = 4
    subTitleNode.maximumNumberOfLines = 1
    priceNode.maximumNumberOfLines = 1

    titleNode.truncationMode = NSLineBreakMode.byTruncatingTail
    subTitleNode.truncationMode = NSLineBreakMode.byTruncatingTail
    priceNode.truncationMode = NSLineBreakMode.byTruncatingTail
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    var addSpacer: Bool = false
    var vStackChildren: [ASLayoutElement] = []
    vStackChildren.append(imageNode)

    vStackChildren.append(ASLayoutSpec.spacer(height: 3))
    vStackChildren.append(titleNode)

    addSpacer = !title.isEmptyOrNil()

    if !subTitle.isEmptyOrNil() {
      if addSpacer {
        addSpacer = false
        vStackChildren.append(ASLayoutSpec.spacer(height: 3))
      }
      vStackChildren.append(subTitleNode)
    }

    if addSpacer {
      addSpacer = false
      vStackChildren.append(ASLayoutSpec.spacer(height: 3))
    }
    addSpacer = !subTitle.isEmptyOrNil()

    if !price.isEmptyOrNil() {
      if addSpacer {
        addSpacer = false
        vStackChildren.append(ASLayoutSpec.spacer(height: 3))
      }
      vStackChildren.append(priceNode)
    }

    let vStack = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .start, alignItems: .stretch, children: vStackChildren)
    return vStack
  }

}
