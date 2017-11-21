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
  func commentNodeShouldUpdateLayout(_ node: CommentNode)
}

class CommentNode: ASCellNode {
  fileprivate let imageNode: ASNetworkImageNode
  fileprivate let fullNameNode: ASTextNode
  fileprivate let dateNode: ASTextNode
  fileprivate let messageNode: DynamicCommentMessageNode
  
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
    super.init()
    setupNode()
  }
  
  private func setupNode() {
    automaticallyManagesSubnodes = true
    
    imageNode.style.preferredSize = configuration.imageSize
    imageNode.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(
      configuration.imageBorderWidth, configuration.imageBorderColor)
    imageNode.defaultImage = ThemeManager.shared.currentTheme.penNamePlaceholder
    
    messageNode.delegate = self
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    var infoStackElements = [ASLayoutElement]()
    
    // layout the header elements: Image - Name - Date
    let titleDateSpec = ASStackLayoutSpec(direction: .vertical, spacing: configuration.titleDateVerticalSpace, justifyContent: .start, alignItems: .start, children: [fullNameNode, dateNode])
    let imageNodeInsetSpec = ASInsetLayoutSpec(insets: configuration.imageNodeInsets, child: imageNode)
    let headerSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 0, justifyContent: .start, alignItems: .center, children: [imageNodeInsetSpec, titleDateSpec])
    infoStackElements.append(headerSpec)
    
    // layout the body elements: Comment Message, Action Buttons
    let bodyInsetSpec = ASInsetLayoutSpec(insets: bodyInsets, child: messageNode)
    infoStackElements.append(bodyInsetSpec)
    
    let infoStackSpec = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .start, alignItems: .stretch, children: infoStackElements)
    
    return infoStackSpec
  }
  
  var bodyInsets: UIEdgeInsets {
    let bodyLeftMargin: CGFloat
    switch mode {
    case .normal:
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
        .append(text: date?.relativelyFormatted() ?? "", color: configuration.defaultTextColor).attributedString
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
    messageNode.numberOfWits = numberOfWits
  }
  
  fileprivate func refreshMessageNodeForMode() {
    messageNode.mode = mode == .minimal ? .minimal : .collapsed
  }
}

// MARK: Configuration declaration
extension CommentNode {
  struct Configuration {
    private static var subnodesSpace = ThemeManager.shared.currentTheme.cardInternalMargin()
    var nameColor: UIColor = ThemeManager.shared.currentTheme.colorNumber19()
    var defaultTextColor: UIColor = ThemeManager.shared.currentTheme.defaultTextColor()
    var imageSize: CGSize = CGSize(width: 45.0, height: 45.0)
    var imageBorderWidth: CGFloat = 0.0
    var imageBorderColor: UIColor? = nil
    var imageNodeInsets = UIEdgeInsetsMake(0, 0, 0, Configuration.subnodesSpace)
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

// MARK: Dynamic Comment Message Node Delegate
extension CommentNode: DynamicCommentMessageNodeDelegate {
  func dynamicCommentMessageNodeDidTapMoreButton(_ node: DynamicCommentMessageNode) {
    node.toggleMode()
    delegate?.commentNodeShouldUpdateLayout(self)
  }
  
  func dynamicCommentMessageNodeDidTapWitsButton(_ node: DynamicCommentMessageNode) {
    // TODO: open the list of witters
  }
}
