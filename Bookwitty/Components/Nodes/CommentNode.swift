//
//  CommentNode.swift
//  Bookwitty
//
//  Created by Marwan  on 5/29/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit
import DTCoreText

protocol CommentNodeDelegate: class {
  func commentNode(_ node: CommentNode, didRequestAction action: CardActionBarNode.Action, forSender sender: ASButtonNode, didFinishAction: ((Bool) -> ())?)
  func commentNodeUpdateLayout(_ node: CommentNode, forExpandedState state: DynamicCommentMessageNode.DynamicMode)
}

class CommentNode: ASCellNode {
  fileprivate let imageNode: ASNetworkImageNode
  fileprivate let fullNameNode: ASTextNode
  fileprivate let dateNode: ASTextNode
  fileprivate let messageNode: DynamicCommentMessageNode
  fileprivate let replyButton: ASButtonNode
  fileprivate let witButton: ASWitButton
  fileprivate let moreButton: ASButtonNode
  
  var mode = DisplayMode.normal {
    didSet {
      refreshMessageNodeForMode()
      setNeedsLayout()
    }
  }
  
  var configuration = Configuration() {
    didSet {
      setNeedsLayout()
    }
  }
  
  weak var delegate: CommentNodeDelegate?
  
  override init() {
    imageNode = ASNetworkImageNode()
    fullNameNode = ASTextNode()
    dateNode = ASTextNode()
    messageNode = DynamicCommentMessageNode()
    replyButton = ASButtonNode()
    witButton = ASWitButton()
    moreButton = ASButtonNode()
    super.init()
    setupNode()
    applyTheme()
  }
  
  private func setupNode() {
    automaticallyManagesSubnodes = true
    
    imageNode.style.preferredSize = configuration.imageSize
    imageNode.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(
      configuration.imageBorderWidth, configuration.imageBorderColor)
    imageNode.defaultImage = ThemeManager.shared.currentTheme.penNamePlaceholder
    
    messageNode.delegate = self
    
    replyButton.addTarget(
      self, action: #selector(replyButtonTouchUpInside(_:)),
      forControlEvents: .touchUpInside)
    replyButtonTitle = Strings.reply().capitalized
    
    witButton.delegate = self
    witButton.configuration.height = 27.0
    witButton.configuration.font = FontDynamicType.footnote.font
    
    let iconTintColor: UIColor = ThemeManager.shared.currentTheme.colorNumber15()
    moreButton.imageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(iconTintColor)
    moreButton.style.preferredSize = configuration.iconSize
    moreButton.setImage(#imageLiteral(resourceName: "threeDots"), for: .normal)
    moreButton.addTarget(
      self, action: #selector(moreButtonTouchUpInside(_:)),
      forControlEvents: .touchUpInside)
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    var infoStackElements = [ASLayoutElement]()
    
    // layout the header elements: Image - Name - Date - Actions
    var headerStackElements = [ASLayoutElement]()
    
    let titleDateSpec = ASStackLayoutSpec(
      direction: .vertical, spacing: configuration.titleDateVerticalSpace,
      justifyContent: .start, alignItems: .start, children: [fullNameNode, dateNode])
    let titleDateInsetSpec = ASInsetLayoutSpec(insets: configuration.titleDateInsets, child: titleDateSpec)
    titleDateInsetSpec.style.flexShrink = 1.0
    titleDateInsetSpec.style.flexGrow = 1.0
    
    let imageNodeInsetSpec = ASInsetLayoutSpec(
      insets: configuration.imageNodeInsets, child: imageNode)
    let leftSideHeaderSpec = ASStackLayoutSpec(
      direction: .horizontal, spacing: 0, justifyContent: .start,
      alignItems: .start, children: [
        imageNodeInsetSpec,
        titleDateInsetSpec,
      ])
    leftSideHeaderSpec.style.flexGrow = 1.0
    leftSideHeaderSpec.style.flexShrink = 1.0
    headerStackElements.append(leftSideHeaderSpec)
    
    // Add Actions if needed
    if mode != .minimal {
      let actionsSpec = ASStackLayoutSpec(
        direction: .horizontal, spacing: 0, justifyContent: .end,
        alignItems: .start, children: [witButton, ASLayoutSpec.spacer(width: 5), moreButton])
      let actionSpecInsets = ASInsetLayoutSpec(
        insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -10), child: actionsSpec)
      headerStackElements.append(ASLayoutSpec.spacer(width: 5))
      headerStackElements.append(actionSpecInsets)
    }
   
    let headerSpec = ASStackLayoutSpec(
      direction: .horizontal, spacing: 0, justifyContent: .start,
      alignItems: .start, children: headerStackElements)
    infoStackElements.append(headerSpec)
    
    // layout the body elements: Comment Message, Reply Button
    var bodyElements: [ASLayoutElement] = [messageNode]
    if mode == .normal, messageNode.mode == .extended {
      bodyElements.append(replyButton)
    }
    let bodyStack = ASStackLayoutSpec(
      direction: .vertical, spacing: 0, justifyContent: .start,
      alignItems: .start, children: bodyElements)
    let bodyInsetSpec = ASInsetLayoutSpec(insets: bodyInsets, child: bodyStack)
    infoStackElements.append(bodyInsetSpec)
    
    // Set The Main Stack Spec
    let infoStackSpec = ASStackLayoutSpec(
      direction: .vertical, spacing: 0, justifyContent: .start,
      alignItems: .stretch, children: infoStackElements)
    
    return infoStackSpec
  }
  
  var bodyInsets: UIEdgeInsets {
    let bodyLeftMargin: CGFloat
    switch mode {
    case .normal, .minimal:
      bodyLeftMargin = configuration.imageReservedHorizontalSpace
    default:
      bodyLeftMargin = 0
    }
    return UIEdgeInsets(top: configuration.bodyInsetTop, left: bodyLeftMargin, bottom: 0, right: 0)
  }
  
  private func separator() -> ASDisplayNode {
    let separator = ASDisplayNode()
    separator.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    separator.style.height = ASDimensionMake(1)
    return separator
  }
  
  // MARK: Data Setters
  fileprivate var replyButtonTitle: String? {
    didSet {
      replyButton.setTitle(
        replyButtonTitle ?? "", with: FontDynamicType.subheadline.font,
        with: configuration.replyButtonTextColor, for: UIControlState.normal)
      setNeedsLayout()
    }
  }
  
  var imageURL: URL?  {
    didSet {
      imageNode.url = imageURL
      imageNode.setNeedsLayout()
    }
  }
  
  var fullName: String? {
    didSet {
      fullNameNode.attributedText = AttributedStringBuilder(fontDynamicType: .footnote)
        .append(text: fullName ?? "", color: configuration.nameColor).attributedString
      fullNameNode.setNeedsLayout()
      setNeedsLayout()
    }
  }
  
  var date: Date? {
    didSet {
      dateNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption2)
        .append(text: date?.relativelyFormatted() ?? "", color: configuration.dateColor).attributedString
      setNeedsLayout()
    }
  }
  
  var message: String? {
    didSet {
      messageNode.htmlString(text: message, fontDynamicType: FontDynamicType.body)
      messageNode.setNeedsLayout()
    }
  }
  
  func setWitValue(witted: Bool, numberOfWits: Int?) {
    witButton.witted = witted
    messageNode.numberOfWits = numberOfWits
  }
  
  fileprivate func refreshMessageNodeForMode() {
    messageNode.mode = mode == .minimal ? .minimal : .collapsed
  }
  
  // MARK: ACTIONS
  //==============
  func replyButtonTouchUpInside(_ sender: ASButtonNode) {
    delegate?.commentNode(
      self, didRequestAction: CardActionBarNode.Action.reply,
      forSender: sender, didFinishAction: nil)
  }
  
  func moreButtonTouchUpInside(_ sender: ASButtonNode) {
    delegate?.commentNode(
      self, didRequestAction: CardActionBarNode.Action.more,
      forSender: sender, didFinishAction: nil)
  }
}

// MARK: Configuration declaration
extension CommentNode {
  struct Configuration {
    private static var subnodesSpace = ThemeManager.shared.currentTheme.cardInternalMargin()
    var nameColor: UIColor = ThemeManager.shared.currentTheme.defaultTextColor()
    var defaultTextColor: UIColor = ThemeManager.shared.currentTheme.defaultTextColor()
    var dateColor: UIColor = ThemeManager.shared.currentTheme.colorNumber15()
    var replyButtonTextColor: UIColor = ThemeManager.shared.currentTheme.defaultButtonColor()
    var imageSize: CGSize = CGSize(width: 45.0, height: 45.0)
    var iconSize: CGSize = CGSize(width: 40.0, height: 27.0)
    var imageBorderWidth: CGFloat = 0.0
    var imageBorderColor: UIColor? = nil
    var imageNodeInsets = UIEdgeInsetsMake(0, 0, 0, Configuration.subnodesSpace)
    var titleDateInsets = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
    var bodyInsetTop: CGFloat = Configuration.subnodesSpace - 5
    var titleDateVerticalSpace: CGFloat = 5
    var imageReservedHorizontalSpace: CGFloat {
      return imageSize.width + imageNodeInsets.right + imageNodeInsets.left
    }
  }
}

// MARK: Modes declaration
extension CommentNode {
  enum DisplayMode {
    case normal
    case reply
    case minimal
  }
}

// MARK: Wit Button
extension CommentNode: ASWitButtonDelegate {
  func witButtonTapped(_ witButton: ASWitButton, witted: Bool, reactionBlock: @escaping (Bool) -> Void, completionBlock: @escaping (Bool) -> Void) {
    reactionBlock(true)
    delegate?.commentNode(
      self,
      didRequestAction: witted ? CardActionBarNode.Action.unwit : CardActionBarNode.Action.wit,
      forSender: witButton,
      didFinishAction: completionBlock)
  }
}

// MARK: Dynamic Comment Message Node Delegate
extension CommentNode: DynamicCommentMessageNodeDelegate {
  func dynamicCommentMessageNodeDidTapMoreButton(_ node: DynamicCommentMessageNode) {
    node.toggleMode()
    delegate?.commentNodeUpdateLayout(self, forExpandedState: node.mode)
  }
  
  func dynamicCommentMessageNodeDidTapWitsButton(_ node: DynamicCommentMessageNode) {
    // TODO: open the list of witters
  }
}

// MARK: Theme
extension CommentNode: Themeable {
  func applyTheme() {
    let theme = ThemeManager.shared.currentTheme
    theme.styleFlat(button: replyButton)
  }
}
