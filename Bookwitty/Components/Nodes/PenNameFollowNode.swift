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
  func penName(node: PenNameFollowNode, actionButtonTouchUpInside button: ButtonWithLoader)
  func penName(node: PenNameFollowNode, actionPenNameFollowTouchUpInside button: Any?)
  func penName(node: PenNameFollowNode, requestToViewImage image: UIImage, from imageNode: ASNetworkImageNode)

}

class PenNameFollowNode: ASCellNode {
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()
  fileprivate let imageSize: CGSize = CGSize(width: 45.0, height: 45.0)
  fileprivate let largeImageSize: CGSize = CGSize(width: 60.0, height: 60.0)
  fileprivate let buttonSize: CGSize = CGSize(width: 36.0, height: 36.0)
  fileprivate let iconSize: CGSize = CGSize(width: 40.0, height: 40.0)

  private var imageNode: ASNetworkImageNode
  private var nameNode: ASTextNode
  private var biographyNode: ASTextNode
  private var actionButton: ButtonWithLoader
  private var moreButton: ASButtonNode
  private let separatorNode: ASDisplayNode
  private var enlarged: Bool = false
  fileprivate var largePadding: Bool = false

  weak var delegate: PenNameFollowNodeDelegate?

  private override init() {
    imageNode = ASNetworkImageNode()
    nameNode = ASTextNode()
    biographyNode = ASTextNode()
    actionButton = ButtonWithLoader()
    moreButton = ASButtonNode()
    separatorNode = ASDisplayNode()
    super.init()
    addSubnode(imageNode)
    addSubnode(nameNode)
    addSubnode(biographyNode)
    addSubnode(actionButton)
    addSubnode(moreButton)
    addSubnode(separatorNode)
  }

  convenience init(enlarged: Bool = false, largePadding: Bool = false) {
    self.init()
    self.enlarged = enlarged
    self.largePadding = largePadding
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
      actionButton.state = self.following ? .selected : .normal
    }
  }

  var showBottomSeparator: Bool = false
  var disabled: Bool = false

  private func setupNode() {
    backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()

    imageNode.defaultImage = ThemeManager.shared.currentTheme.penNamePlaceholder
    imageNode.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(0.0, nil)
    imageNode.animatedImageRunLoopMode = RunLoopMode.defaultRunLoopMode.rawValue
    imageNode.animatedImagePaused = true

    nameNode.maximumNumberOfLines = 1
    biographyNode.maximumNumberOfLines = enlarged ? 5 : 3

    nameNode.truncationMode = NSLineBreakMode.byTruncatingTail
    biographyNode.truncationMode = NSLineBreakMode.byTruncatingTail

    let buttonFont = FontDynamicType.subheadline.font
    let textColor = ThemeManager.shared.currentTheme.defaultButtonColor()
    let selectedTextColor = ThemeManager.shared.currentTheme.colorNumber23()

    actionButton.setupSelectionButton(defaultBackgroundColor: ThemeManager.shared.currentTheme.defaultBackgroundColor(),
                                      selectedBackgroundColor: ThemeManager.shared.currentTheme.defaultButtonColor(),
                                      borderStroke: true,
                                      borderColor: ThemeManager.shared.currentTheme.defaultButtonColor(),
                                      borderWidth: 2.0,
                                      cornerRadius: 2.0)
    actionButton.setTitle(title: Strings.follow(), with: buttonFont, with: textColor, for: .normal)
    actionButton.setTitle(title: Strings.following(), with: buttonFont, with: selectedTextColor, for: .selected)
    actionButton.state = self.following ? .selected : .normal
    actionButton.style.height = ASDimensionMake(buttonSize.height)
    actionButton.delegate = self

    moreButton.imageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(ThemeManager.shared.currentTheme.colorNumber15())
    moreButton.setImage(#imageLiteral(resourceName: "threeDots"), for: .normal)
    moreButton.style.preferredSize = iconSize

    imageNode.style.preferredSize = enlarged ? largeImageSize : imageSize

    nameNode.addTarget(self, action: #selector(actionPenNameFollowTouchUpInside(_:)), forControlEvents: ASControlNodeEvent.touchUpInside)
    imageNode.addTarget(self, action: #selector(imageNodeTouchUpInside(sender:)), forControlEvents: ASControlNodeEvent.touchUpInside)
    biographyNode.addTarget(self, action: #selector(actionPenNameFollowTouchUpInside(_:)), forControlEvents: ASControlNodeEvent.touchUpInside)
    moreButton.addTarget(self, action: #selector(moreButtonTouchUpInside(_:)), forControlEvents: ASControlNodeEvent.touchUpInside)

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

    if !disabled {
      infoNodes.append(spacer(flexGrow: 1.0))
      infoNodes.append(actionButton)
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
    nodesArray.append(moreButton)

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
  func actionPenNameFollowTouchUpInside(_ sender: Any?) {
    delegate?.penName(node: self, actionPenNameFollowTouchUpInside: sender)
  }

  func moreButtonTouchUpInside(_ sender: ASButtonNode?) {
    
  }
}

// MARK: - ButtonWithLoader Delegate Implementation
extension PenNameFollowNode: ButtonWithLoaderDelegate {
  func buttonTouchUpInside(buttonWithLoader: ButtonWithLoader) {
    guard UserManager.shared.isSignedIn else {
      //If user is not signed In post notification and do not fall through
      NotificationCenter.default.post( name: AppNotification.callToAction, object: CallToAction.follow)
      return
    }

    delegate?.penName(node: self, actionButtonTouchUpInside: buttonWithLoader)
  }
}

//Helpers
extension PenNameFollowNode {
  fileprivate func edgeInset() -> UIEdgeInsets {
    return UIEdgeInsets(top: largePadding ? contentSpacing : internalMargin,
                        left: internalMargin,
                        bottom: largePadding ? contentSpacing : internalMargin,
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


extension PenNameFollowNode: ASNetworkImageNodeDelegate {
  @objc
  fileprivate func imageNodeTouchUpInside(sender: ASNetworkImageNode) {
    guard let image = sender.image else {
      delegate?.penName(node: self, actionPenNameFollowTouchUpInside: sender)
      return
    }

    delegate?.penName(node: self, requestToViewImage: image, from: sender)
  }
}

