//
//  CommentNode.swift
//  Bookwitty
//
//  Created by Marwan  on 5/29/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

protocol CommentNodeDelegate: class {
  func commentNode(_ node: CommentNode, didRequestAction action: CardActionBarNode.Action, forSender sender: ASButtonNode, didFinishAction: ((Bool) -> ())?)
}

class CommentNode: ASCellNode {
  fileprivate let imageNode: ASNetworkImageNode
  fileprivate let fullNameNode: ASTextNode
  fileprivate let dateNode: ASTextNode
  fileprivate let messageNode: ASTextNode
  fileprivate let actionBar: CardActionBarNode
  
  var mode = Mode.primary {
    didSet {
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
    messageNode = ASTextNode()
    actionBar = CardActionBarNode()
    super.init()
    setupNode()
  }
  
  private func setupNode() {
    automaticallyManagesSubnodes = true
    
    imageNode.style.preferredSize = configuration.imageSize
    imageNode.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(
      configuration.imageBorderWidth, configuration.imageBorderColor)
    imageNode.defaultImage = ThemeManager.shared.currentTheme.penNamePlaceholder
    
    actionBar.setup(forFollowingMode: false)
    actionBar.configuration.externalHorizontalMargin = 0
    actionBar.hideDim = false
    actionBar.hideReplyButton = false
    actionBar.hideShareButton = true
    actionBar.delegate = self
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    
    var infoStackElements = [ASLayoutElement]()
    
    // layout the header elements: Image - Name - Date
    let titleDateSpec = ASStackLayoutSpec(direction: .vertical, spacing: configuration.titleDateVerticalSpace, justifyContent: .start, alignItems: .start, children: [fullNameNode, dateNode])
    let imageNodeInsetSpec = ASInsetLayoutSpec(insets: configuration.imageNodeInsets, child: imageNode)
    let headerSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 0, justifyContent: .start, alignItems: .center, children: [imageNodeInsetSpec, titleDateSpec])
    infoStackElements.append(headerSpec)
    
    // layout the body elements: Comment Message, Action Buttons
    var bodyStackElements = [ASLayoutElement]()
    let actionBarTopSeparatorInsetSpec = ASInsetLayoutSpec(insets: configuration.separatorInsets, child: separator())
    bodyStackElements.append(contentsOf: [messageNode, actionBarTopSeparatorInsetSpec, actionBar])
    if !configuration.hideBottomActionBarSeparator {
      bodyStackElements.append(separator())
    }
    let bodySpec = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .start, alignItems: .stretch, children: bodyStackElements)
    let bodyInsetSpec = ASInsetLayoutSpec(insets: bodyInsets, child: bodySpec)
    infoStackElements.append(bodyInsetSpec)
    
    let infoStackSpec = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .start, alignItems: .stretch, children: infoStackElements)
    
    return infoStackSpec
  }
  
  var bodyInsets: UIEdgeInsets {
    let bodyLeftMargin: CGFloat
    switch mode {
    case .primary:
      bodyLeftMargin = configuration.imageSize.width + configuration.imageNodeInsets.right + configuration.imageNodeInsets.left
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
        .append(text: date?.formatted() ?? "", color: configuration.defaultTextColor).attributedString
      setNeedsLayout()
    }
  }
  
  var message: String? {
    didSet {
      messageNode.attributedText = AttributedStringBuilder(fontDynamicType: .body)
        .append(text: message ?? "", color: configuration.defaultTextColor).attributedString
      setNeedsLayout()
    }
  }
  
  func setWitValue(witted: Bool, wits: Int) {
    actionBar.setWitButton(witted: witted, wits: wits)
  }
  
  func setDimValue(dimmed: Bool, dims: Int) {
    actionBar.setDimValue(dimmed: dimmed, dims: dims)
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
    var separatorInsets = UIEdgeInsetsMake(10, 0, 0, 0)
    var bodyInsetTop: CGFloat = Configuration.subnodesSpace - 5
    var titleDateVerticalSpace: CGFloat = 5
    var hideBottomActionBarSeparator = false
  }
}

// MARK: Modes declaration
extension CommentNode {
  enum Mode {
    case primary
    case secondary
  }
}

// MARK: Modes declaration
extension CommentNode: CardActionBarNodeDelegate {
  func cardActionBarNode(cardActionBar: CardActionBarNode, didRequestAction action: CardActionBarNode.Action, forSender sender: ASButtonNode, didFinishAction: ((Bool) -> ())?) {
    delegate?.commentNode(self, didRequestAction: action, forSender: sender, didFinishAction: didFinishAction)
  }
}
