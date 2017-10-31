//
//  RichContentBookNode.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/09/28.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

protocol RichContentBookNodeDelegate: NSObjectProtocol {
  func richContentBookDidRequestAddAction(node: RichContentBookNode)
}

class RichContentBookNode: ASCellNode {
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let imageSize: CGSize = CGSize(width: 60.0, height: 90.0)

  private var imageNode: ASNetworkImageNode
  private var titleNode: ASTextNode
  private var authorNode: ASTextNode
  private var addButton: ASButtonNode
  private var separatorNode: ASDisplayNode

  weak var delegate: RichContentBookNodeDelegate?

  override init() {
    imageNode = ASNetworkImageNode()
    titleNode = ASTextNode()
    authorNode = ASTextNode()
    addButton = ASButtonNode()
    separatorNode = ASDisplayNode()
    super.init()
    setupNode()
  }

  fileprivate func setupNode() {
    automaticallyManagesSubnodes = true
    style.minSize = CGSize(width: 0.0, height: imageSize.height + (internalMargin * 2))
    backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()

    imageNode.placeholderColor = ASDisplayNodeDefaultPlaceholderColor()
    imageNode.style.preferredSize = imageSize
    imageNode.contentMode = UIViewContentMode.scaleAspectFit

    titleNode.maximumNumberOfLines = 4
    authorNode.maximumNumberOfLines = 1

    titleNode.truncationMode = NSLineBreakMode.byTruncatingTail
    authorNode.truncationMode = NSLineBreakMode.byTruncatingTail

    let buttonFont = FontDynamicType.subheadline.font

    let buttonBackgroundImage = UIImage(color: ThemeManager.shared.currentTheme.defaultBackgroundColor())
    let textColor = ThemeManager.shared.currentTheme.defaultButtonColor()
    let selectedButtonBackgroundImage = UIImage(color: ThemeManager.shared.currentTheme.defaultButtonColor())

    addButton.setBackgroundImage(buttonBackgroundImage, for: .normal)
    addButton.setBackgroundImage(selectedButtonBackgroundImage, for: .selected)

    addButton.setTitle(Strings.add(), with: buttonFont, with: textColor, for: .normal)

    addButton.titleNode.maximumNumberOfLines = 1
    addButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    addButton.style.height = ASDimensionMake(36.0)
    addButton.style.minWidth = ASDimension(unit: .points, value: 50.0)

    addButton.cornerRadius = 2.0
    addButton.borderColor = ThemeManager.shared.currentTheme.defaultButtonColor().cgColor
    addButton.borderWidth = 2
    addButton.clipsToBounds = true

    addButton.addTarget(self, action: #selector(addButtonTouchUpInside(_:)), forControlEvents: .touchUpInside)

    separatorNode.style.height = ASDimensionMake(1)
    separatorNode.style.flexGrow = 1
    separatorNode.style.flexShrink = 1
    separatorNode.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    var nodesArray: [ASLayoutElement] = []
    nodesArray.append(imageNode)

    let infoArray: [ASLayoutElement] = [titleNode, authorNode]
    let titleAuthorVerticalSpec = ASStackLayoutSpec(direction: .vertical,
                                                    spacing: 0,
                                                    justifyContent: .start,
                                                    alignItems: .start,
                                                    children: infoArray)

    titleAuthorVerticalSpec.style.flexShrink = 1.0
    titleAuthorVerticalSpec.style.flexGrow = 1.0

    nodesArray.append(titleAuthorVerticalSpec)
    nodesArray.append(addButton)
    let horizontalSpec = ASStackLayoutSpec(direction: .horizontal,
                                           spacing: internalMargin,
                                           justifyContent: .start,
                                           alignItems: .center,
                                           children: nodesArray)

    let horizontalInsetSpec = ASInsetLayoutSpec(insets: edgeInset(), child: horizontalSpec)

    let separatorSpaceFromStart = imageSize.width + (internalMargin * 2)
    let separatorHorizontalSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 0, justifyContent: .start, alignItems: .stretch, children:  [spacer(width: separatorSpaceFromStart), separatorNode])
    let verticalSpec = ASStackLayoutSpec(direction: .vertical, spacing: 0.0, justifyContent: .center, alignItems: .stretch, children: [spacer(flexGrow: 1), horizontalInsetSpec, spacer(flexGrow: 1), separatorHorizontalSpec])

    return verticalSpec
  }

  @objc
  fileprivate func addButtonTouchUpInside(_ sender: ASButtonNode?) {
    delegate?.richContentBookDidRequestAddAction(node: self)
  }

  //MARK: - Data handlers
  var title: String? {
    didSet {
      if let title = title {
        titleNode.attributedText = AttributedStringBuilder(fontDynamicType: .title3)
          .append(text: title, color: ThemeManager.shared.currentTheme.defaultTextColor()).attributedString
        setNeedsLayout()
      }
    }
  }

  var author: String? {
    didSet {
      if let author = author {
        authorNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption1)
          .append(text: author, color: ThemeManager.shared.currentTheme.defaultTextColor()).attributedString
        setNeedsLayout()
      }
    }
  }

  var imageUrl: String? {
    didSet {
      if let imageUrl = imageUrl {
        imageNode.url = URL(string: imageUrl)
        setNeedsLayout()
      }
    }
  }
}

//Helpers
extension RichContentBookNode {
  fileprivate func edgeInset() -> UIEdgeInsets {
    return UIEdgeInsets(top: internalMargin,
                        left: internalMargin,
                        bottom: internalMargin,
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
