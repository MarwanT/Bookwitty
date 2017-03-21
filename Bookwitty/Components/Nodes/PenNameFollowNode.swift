//
//  PenNameFollowNode.swift
//  Bookwitty
//
//  Created by charles on 3/6/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

protocol PenNameFollowNodeDelegate: class {
  func penName(node: PenNameFollowNode, actionButtonTouchUpInside button: ASButtonNode)
  func penName(node: PenNameFollowNode, actionPenNameFollowTouchUpInside button: Any?)
}

class PenNameFollowNode: ASCellNode {
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let imageSize: CGSize = CGSize(width: 45.0, height: 45.0)
  fileprivate let largeImageSize: CGSize = CGSize(width: 60.0, height: 60.0)
  fileprivate let buttonSize: CGSize = CGSize(width: 36.0, height: 36.0)

  private var imageNode: ASNetworkImageNode
  private var nameNode: ASTextNode
  private var biographyNode: ASTextNode
  private var actionButton: ASButtonNode
  private let separatorNode: ASDisplayNode
  private var enlarged: Bool = false

  weak var delegate: PenNameFollowNodeDelegate?

  private override init() {
    imageNode = ASNetworkImageNode()
    nameNode = ASTextNode()
    biographyNode = ASTextNode()
    actionButton = ASButtonNode()
    separatorNode = ASDisplayNode()
    super.init()
    addSubnode(imageNode)
    addSubnode(nameNode)
    addSubnode(biographyNode)
    addSubnode(actionButton)
    addSubnode(separatorNode)
  }

  convenience init(enlarged: Bool = false) {
    self.init()
    self.enlarged = enlarged
    setupNode()
  }


  var penName: String? {
    didSet {
      if let penName = penName {
        nameNode.attributedText = AttributedStringBuilder(fontDynamicType: enlarged ? .subheadline : .footnote)
          .append(text: penName, color: ThemeManager.shared.currentTheme.defaultButtonColor()).attributedString
        setNeedsLayout()
      }
    }
  }

  var biography: String? {
    didSet {
      if let biography = biography {
        biographyNode.attributedText = AttributedStringBuilder(fontDynamicType: enlarged ? .caption1 : .caption2)
          .append(text: biography, color: ThemeManager.shared.currentTheme.defaultTextColor()).attributedString
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

  var following: Bool = false {
    didSet {
      actionButton.isSelected = following
    }
  }

  var showBottomSeparator: Bool = false
  var disabled: Bool = false

  private func setupNode() {
    backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()

    imageNode.defaultImage = #imageLiteral(resourceName: "penNamePlaceholder ").imageMaskedAndTinted(with: ThemeManager.shared.currentTheme.colorNumber18())
    imageNode.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(0.0, nil)

    nameNode.maximumNumberOfLines = 1
    biographyNode.maximumNumberOfLines = enlarged ? 5 : 3

    let buttonFont = FontDynamicType.subheadline.font
    let textColor = ThemeManager.shared.currentTheme.defaultButtonColor()
    let selectedTextColor = ThemeManager.shared.currentTheme.colorNumber23()
    let buttonBackgroundImage = UIImage(color: ThemeManager.shared.currentTheme.defaultBackgroundColor())
    let selectedButtonBackgroundImage = UIImage(color: ThemeManager.shared.currentTheme.defaultButtonColor())
    actionButton.titleNode.maximumNumberOfLines = 1
    actionButton.setBackgroundImage(buttonBackgroundImage, for: .normal)
    actionButton.setBackgroundImage(selectedButtonBackgroundImage, for: .selected)
    actionButton.isSelected = self.following

    actionButton.setTitle(Strings.follow(), with: buttonFont, with: textColor, for: .normal)
    actionButton.setTitle(Strings.followed(), with: buttonFont, with: selectedTextColor, for: .selected)
    actionButton.cornerRadius = 2
    actionButton.borderColor = ThemeManager.shared.currentTheme.defaultButtonColor().cgColor
    actionButton.borderWidth = 2
    actionButton.clipsToBounds = true

    imageNode.style.preferredSize = enlarged ? largeImageSize : imageSize
    actionButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    actionButton.style.height = ASDimensionMake(buttonSize.height)
    actionButton.addTarget(self, action: #selector(actionButtonTouchUpInside(_:)), forControlEvents: ASControlNodeEvent.touchUpInside)

    nameNode.addTarget(self, action: #selector(actionPenNameFollowTouchUpInside(_:)), forControlEvents: ASControlNodeEvent.touchUpInside)
    imageNode.addTarget(self, action: #selector(actionPenNameFollowTouchUpInside(_:)), forControlEvents: ASControlNodeEvent.touchUpInside)
    biographyNode.addTarget(self, action: #selector(actionPenNameFollowTouchUpInside(_:)), forControlEvents: ASControlNodeEvent.touchUpInside)

    separatorNode.style.height = ASDimensionMake(1)
    separatorNode.style.flexGrow = 1
    separatorNode.isLayerBacked = true
    separatorNode.backgroundColor  = ThemeManager.shared.currentTheme.colorNumber18()
  }

  func updateMode(disabled: Bool) {
    self.disabled = disabled
    actionButton.isHidden = disabled
    actionButton.isEnabled = !disabled
    setNeedsLayout()
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    var nodesArray: [ASLayoutElement] = []

    nodesArray.append(imageNode)
    nodesArray.append(spacer(width: internalMargin))

    var infoNodes: [ASLayoutElement] = []

    if isValid(penName) {
      infoNodes.append(nameNode)
    }

    if isValid(biography) {
      infoNodes.append(biographyNode)
    }

    let verticalSpec = ASStackLayoutSpec(direction: .vertical,
                                         spacing: internalMargin / 3.0,
                                         justifyContent: .start,
                                         alignItems: .start,
                                         children: infoNodes)
    verticalSpec.style.flexShrink = 1.0

    nodesArray.append(verticalSpec)
    nodesArray.append(spacer(flexGrow: 1.0))
    nodesArray.append(spacer(width: internalMargin / 2.0))
    if !disabled {
      nodesArray.append(actionButton)
    }

    let horizontalSpec = ASStackLayoutSpec(direction: .horizontal,
                                           spacing: 0,
                                           justifyContent: .spaceBetween,
                                           alignItems: .start,
                                           children: nodesArray)

    let insetSpec = ASInsetLayoutSpec(insets: edgeInset(), child: horizontalSpec)
    let separatorNodeInset = ASInsetLayoutSpec(insets: separatorInset(), child: separatorNode)


    let parentVerticalSpec = ASStackLayoutSpec(direction: .vertical,
                                         spacing: 0,
                                         justifyContent: .center,
                                         alignItems: .stretch,
                                         children: showBottomSeparator ? [insetSpec, separatorNodeInset] : [insetSpec])

    return parentVerticalSpec
  }
}

//Actions
extension PenNameFollowNode {
  func actionButtonTouchUpInside(_ sender: ASButtonNode) {
    delegate?.penName(node: self, actionButtonTouchUpInside: sender)
  }

  func actionPenNameFollowTouchUpInside(_ sender: Any?) {
    delegate?.penName(node: self, actionPenNameFollowTouchUpInside: sender)
  }
}


//Helpers
extension PenNameFollowNode {
  fileprivate func edgeInset() -> UIEdgeInsets {
    return UIEdgeInsets(top: internalMargin,
                        left: internalMargin,
                        bottom: internalMargin,
                        right: internalMargin)
  }

  fileprivate func separatorInset() -> UIEdgeInsets {
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
