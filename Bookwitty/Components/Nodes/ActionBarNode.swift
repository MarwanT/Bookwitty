//
//  ActionBarNode.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/10/24.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

protocol ActionBarNodeDelegate: class {
  func actionBar(node: ActionBarNode, actionButtonTouchUpInside button: ButtonWithLoader)
  func actionBar(node: ActionBarNode, secondaryButtonTouchUpInside button: ASButtonNode)
  func actionBar(node: ActionBarNode, moreButtonTouchUpInside button: ASButtonNode)
}

class ActionBarNode: ASCellNode {
  enum Action {
    case wit
    case follow
  }

  let actionButton = ButtonWithLoader()
  let actionLabel = ASTextNode()
  let secondaryButton = ASButtonNode()
  let moreButton = ASButtonNode()

  var actionLabelText: String? {
    didSet {
      if let actionLabelText = actionLabelText {
        actionLabel.attributedText = AttributedStringBuilder(fontDynamicType: FontDynamicType.caption1)
          .append(text: actionLabelText, color: ThemeManager.shared.currentTheme.defaultButtonColor()).attributedString
      } else {
        actionLabel.attributedText = nil
      }
    }
  }

  var configuration = Configuration() {
    didSet {
      setNeedsLayout()
    }
  }

  var action: Action = .follow {
    didSet {
      self.styleActionButton()
    }
  }

  var actionButtonSelected: Bool = false {
    didSet {
      actionButton.state = self.actionButtonSelected ? .selected : .normal
      actionButton.setNeedsLayout()
    }
  }
  
  weak var delegate: ActionBarNodeDelegate? = nil

  override init() {
    super.init()
    initializeComponents()
    self.applyTheme()
  }

  fileprivate func initializeComponents() {
    automaticallyManagesSubnodes = true

    let imageTintColor: UIColor = ThemeManager.shared.currentTheme.colorNumber15()

    actionLabel.style.maxWidth = ASDimensionMake(configuration.labelWidth)
    actionLabel.maximumNumberOfLines = 1
    actionLabel.truncationMode = NSLineBreakMode.byTruncatingTail

    secondaryButton.imageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(imageTintColor)
    secondaryButton.setImage(#imageLiteral(resourceName: "threeDots"), for: .normal)
    secondaryButton.style.preferredSize = configuration.iconSize

    secondaryButton.addTarget(self, action: #selector(self.editButtonTouchUpInside(_:)), forControlEvents: .touchUpInside)

    moreButton.imageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(imageTintColor)
    moreButton.setImage(#imageLiteral(resourceName: "threeDots"), for: .normal)
    moreButton.style.preferredSize = configuration.iconSize

    moreButton.addTarget(self, action: #selector(self.moreButtonTouchUpInside(_:)), forControlEvents: .touchUpInside)

    actionButton.delegate = self
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    var leftNodes: [ASLayoutElement] = [actionButton]
    if actionLabelText?.characters.count ?? 0 > 0 {
      leftNodes.append(actionLabel)
    }
    let leftStackLayoutSpec = ASStackLayoutSpec(direction: .horizontal, spacing: configuration.internalSpacing, justifyContent: .start, alignItems: .center, children: leftNodes)
    leftStackLayoutSpec.style.flexGrow = 1.0

    let rightNodes: [ASLayoutElement] = [secondaryButton, moreButton]
    let rightStackLayoutSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 0.0, justifyContent: .end, alignItems: .stretch, children: rightNodes)
    rightStackLayoutSpec.style.flexGrow = 1.0

    let toolbarNodes: [ASLayoutElement] = [leftStackLayoutSpec, rightStackLayoutSpec]
    let toolbarStackLayoutSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 0.0, justifyContent: .spaceBetween, alignItems: .center, children: toolbarNodes)
    toolbarStackLayoutSpec.style.flexShrink = 1.0

    let insetLayoutSpec = ASInsetLayoutSpec(insets: configuration.insets, child: toolbarStackLayoutSpec)
    insetLayoutSpec.style.flexGrow = 1.0
    insetLayoutSpec.style.flexShrink = 1.0

    let verticalLayoutSpec = ASStackLayoutSpec(direction: .vertical, spacing: 0.0, justifyContent: .center, alignItems: .stretch, children: [SeparatorNode(), insetLayoutSpec])
    verticalLayoutSpec.style.height = ASDimensionMake(configuration.height)
    verticalLayoutSpec.style.flexShrink = 1.0
    return verticalLayoutSpec
  }
}

extension ActionBarNode: Themeable {
  func applyTheme() {
    backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
    self.styleActionButton()
  }

  fileprivate func styleActionButton() {
    actionButton.style.height = ASDimensionMake(configuration.buttonSize.height)

    let buttonFont = FontDynamicType.subheadline.font
    let buttonColor = ThemeManager.shared.currentTheme.defaultButtonColor()
    let backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()

    actionButton.setupSelectionButton(defaultBackgroundColor: backgroundColor,
                                      selectedBackgroundColor: buttonColor,
                                      borderStroke: true,
                                      borderColor: buttonColor,
                                      borderWidth: 2.0,
                                      cornerRadius: 2.0)

    switch action {
    case .follow:
      actionButton.setTitle(title: Strings.follow(), with: buttonFont, with: buttonColor, for: .normal)
      actionButton.setTitle(title: Strings.following(), with: buttonFont, with: backgroundColor, for: .selected)
    case .wit:
      actionButton.style.preferredSize.width = 75.0
      actionButton.setTitle(title: Strings.wit_it(), with: buttonFont, with: buttonColor, for: .normal)
      actionButton.setTitle(title: Strings.witted(), with: buttonFont, with: backgroundColor, for: .selected)
    }
  }
}

//MARK: - Actions
extension ActionBarNode {
  @objc fileprivate func editButtonTouchUpInside(_ sender: ASButtonNode) {
    delegate?.actionBar(node: self, secondaryButtonTouchUpInside: sender)
  }

  @objc fileprivate func moreButtonTouchUpInside(_ sender: ASButtonNode) {
    delegate?.actionBar(node: self, moreButtonTouchUpInside: sender)
  }
}

//MARK: - ButtonWithLoaderDelegate implementation
extension ActionBarNode: ButtonWithLoaderDelegate {
  func buttonTouchUpInside(buttonWithLoader: ButtonWithLoader) {
    guard UserManager.shared.isSignedIn else {
      //If user is not signed In post notification and do not fall through
      let callToAction: CallToAction
      switch self.action {
      case .follow:
        callToAction = .follow
      case .wit:
        callToAction = .wit
      }
      NotificationCenter.default.post( name: AppNotification.callToAction, object: callToAction)
      return
    }

    delegate?.actionBar(node: self, actionButtonTouchUpInside: buttonWithLoader)
  }
}

extension ActionBarNode {
  struct Configuration {
    var internalSpacing = ThemeManager.shared.currentTheme.contentSpacing() / 4.0
    var insets: UIEdgeInsets {
      return UIEdgeInsets(top: internalSpacing - 1.0, left: 2 * internalSpacing, bottom: internalSpacing - 1.0, right: 2 * internalSpacing)
    }

    var edgeInsets: UIEdgeInsets {
      return UIEdgeInsets(top: 0.0, left: 2 * internalSpacing, bottom: 0.0, right: 2 * internalSpacing)
    }

    var height: CGFloat = 50.0
    var labelWidth: CGFloat = 60.0
    var buttonSize: CGSize = CGSize(width: 36.0, height: 36.0)
    var iconSize: CGSize = CGSize(width: 40.0, height: 40.0)
  }
}
