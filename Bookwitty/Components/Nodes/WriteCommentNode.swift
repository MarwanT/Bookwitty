//
//  WriteCommentNode.swift
//  Bookwitty
//
//  Created by Marwan  on 6/1/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

protocol WriteCommentNodeDelegate: class {
  func writeCommentNodeDidTap(_ writeCommentNode: WriteCommentNode)
}

class WriteCommentNode: ASCellNode {
  fileprivate let topSeparator: ASDisplayNode
  fileprivate let imageNode: ASNetworkImageNode
  fileprivate let textNode: ASEditableTextNode
  fileprivate let overlayNode: ASControlNode
  
  var configuration = Configuration()
  
  weak var delegate: WriteCommentNodeDelegate?
  
  override init() {
    topSeparator = ASDisplayNode()
    imageNode = ASNetworkImageNode()
    textNode = ASEditableTextNode()
    overlayNode = ASControlNode()
    super.init()
    initialize()
    applyTheme()
  }
  
  private func initialize() {
    automaticallyManagesSubnodes = true
    
    topSeparator.style.height = ASDimensionMake(1)
    topSeparator.backgroundColor = configuration.separatorColor
    
    imageNode.defaultImage = ThemeManager.shared.currentTheme.penNamePlaceholder
    imageNode.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(0.0, nil)
    imageNode.isLayerBacked = true
  
    overlayNode.addTarget(self, action: #selector(didTapNode(_:)), forControlEvents: .touchUpInside)
    
    placeholder = Strings.what_are_your_thoughts()
    textNode.style.flexGrow = 1.0
  }
  
  override func didLoad() {
    textNode.textView.isEditable = false
  }
  
  // MARK: LAYOUT
  //=============
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    textNode.borderColor = configuration.borderColor.cgColor
    textNode.borderWidth = configuration.borderWidth
    
    textNode.style.minHeight = ASDimensionMake(configuration.textFieldHeight)
    textNode.textContainerInset = configuration.textFieldContentInset
    
    imageNode.style.preferredSize = configuration.imageSize
    let textInsetsSpec = ASInsetLayoutSpec(insets: configuration.textFieldInsets, child: textNode)
    let contentSpec = ASStackLayoutSpec(
      direction: .horizontal, spacing: 0, justifyContent: .start,
      alignItems: configuration.alignItems, children: [imageNode, textInsetsSpec])
    let contentInsetsSpec = ASInsetLayoutSpec(insets: configuration.externalInsets, child: contentSpec)
    return ASOverlayLayoutSpec(child: contentInsetsSpec, overlay: overlayNode)
  }
  
  // MARK: ACTIONS
  //==============
  func didTapNode(_ sender: Any) {
    delegate?.writeCommentNodeDidTap(self)
  }
  
  // MARK: APIs
  //===========
  var imageURL: URL?  {
    didSet {
      imageNode.url = imageURL
      imageNode.setNeedsLayout()
    }
  }
  
  var text: String? {
    didSet {
      textNode.attributedText = AttributedStringBuilder(fontDynamicType: .body)
        .append(text: text ?? "", color: configuration.textColor).attributedString
      setNeedsLayout()
    }
  }
  
  var placeholder: String? {
    didSet {
      textNode.attributedPlaceholderText = AttributedStringBuilder(fontDynamicType: .caption1)
        .append(text: placeholder ?? "", color: configuration.placeholderTextColor).attributedString
      setNeedsLayout()
    }
  }
}

// MARK: - THEMEABLE PROTOCOL
                                    //*******\\
extension WriteCommentNode: Themeable {
  func applyTheme() {
    
  }
}

// MARK: - CONFIGURATION
                                    //*******\\
extension WriteCommentNode {
  struct Configuration {
    private let theme = ThemeManager.shared.currentTheme
    var separatorColor: UIColor
    var borderColor: UIColor
    var placeholderTextColor: UIColor
    var textColor: UIColor
    var borderWidth: CGFloat
    var textFieldHeight: CGFloat
    var placeholderText: String
    var displayTopSeparator: Bool
    var externalInsets: UIEdgeInsets
    var internalInsets: UIEdgeInsets
    var textFieldInsets: UIEdgeInsets
    var textFieldContentInset: UIEdgeInsets
    var imageSize: CGSize
    var alignItems: ASStackLayoutAlignItems
    
    init() {
      separatorColor = theme.defaultSeparatorColor()
      borderColor = theme.defaultSeparatorColor()
      borderWidth = 1
      placeholderText = Strings.what_are_your_thoughts()
      displayTopSeparator = false
      imageSize = CGSize(width: 45.0, height: 45.0)
      textFieldHeight = 45.0
      textColor = theme.defaultTextColor()
      placeholderTextColor = theme.defaultSeparatorColor()
      alignItems = .stretch
      externalInsets = UIEdgeInsets(
        top: theme.cardInternalMargin(),
        left: theme.cardInternalMargin(),
        bottom: theme.cardInternalMargin(),
        right: theme.cardInternalMargin())
      internalInsets = UIEdgeInsets(
        top: 0, left: theme.cardInternalMargin(), bottom: 0, right: 0)
      textFieldInsets = UIEdgeInsets(
        top: theme.cardInternalMargin(),
        left: theme.cardInternalMargin(),
        bottom: theme.cardInternalMargin(),
        right: theme.cardInternalMargin())
      textFieldContentInset = UIEdgeInsets(
        top: theme.cardInternalMargin(),
        left: theme.cardInternalMargin(),
        bottom: theme.cardInternalMargin(),
        right: theme.cardInternalMargin())
    }
  }
}
