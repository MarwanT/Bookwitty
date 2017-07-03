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
  fileprivate let imageNode: ASNetworkImageNode
  fileprivate let textNode: ASEditableTextNode
  fileprivate let overlayNode: ASControlNode
  
  var configuration = Configuration()
  
  weak var delegate: WriteCommentNodeDelegate?
  
  override init() {
    imageNode = ASNetworkImageNode()
    textNode = ASEditableTextNode()
    overlayNode = ASControlNode()
    super.init()
    setupNode()
  }
  
  private func setupNode() {
    automaticallyManagesSubnodes = true
    
    imageNode.defaultImage = ThemeManager.shared.currentTheme.penNamePlaceholder
    imageNode.isLayerBacked = true
  
    overlayNode.addTarget(self, action: #selector(didTapNode(_:)), forControlEvents: .touchUpInside)
    
    placeholder = Strings.what_are_your_thoughts()
    textNode.style.flexGrow = 1.0
    textNode.textContainerInset = configuration.textContainerInset
  }
  
  override func didLoad() {
    textNode.textView.isEditable = false
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    textNode.borderColor = configuration.textNodeBorderColor.cgColor
    textNode.borderWidth = configuration.textNodeBorderWidth
    
    textNode.style.minHeight = ASDimensionMake(configuration.textNodeMinimumHeight)
    
    imageNode.style.preferredSize = configuration.imageSize
    let imageInsetsSpec = ASInsetLayoutSpec(insets: configuration.imageNodeInsets, child: imageNode)
    let contentSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 0, justifyContent: .start, alignItems: .start, children: [imageInsetsSpec, textNode])
    let contentInsetsSpec = ASInsetLayoutSpec(insets: configuration.externalInsets, child: contentSpec)
    return ASOverlayLayoutSpec(child: contentInsetsSpec, overlay: overlayNode)
  }
  
  // MARK: Actions
  func didTapNode(_ sender: Any) {
    delegate?.writeCommentNodeDidTap(self)
  }
  
  // MARK: Data Setters
  var imageURL: URL?  {
    didSet {
      imageNode.url = imageURL
      imageNode.setNeedsLayout()
    }
  }
  
  var text: String? {
    didSet {
      textNode.attributedText = AttributedStringBuilder(fontDynamicType: .body)
        .append(text: text ?? "", color: configuration.defaultTextColor).attributedString
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

extension WriteCommentNode {
  struct Configuration {
    private static var subnodesSpace = ThemeManager.shared.currentTheme.cardInternalMargin()
    fileprivate var textContainerInset = UIEdgeInsetsMake(
      ThemeManager.shared.currentTheme.cardInternalMargin(),
      ThemeManager.shared.currentTheme.cardInternalMargin(),
      ThemeManager.shared.currentTheme.cardInternalMargin(),
      ThemeManager.shared.currentTheme.cardInternalMargin())
    
    var externalInsets = UIEdgeInsets(
      top: ThemeManager.shared.currentTheme.generalExternalMargin(),
      left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: ThemeManager.shared.currentTheme.generalExternalMargin(),
      right: ThemeManager.shared.currentTheme.generalExternalMargin())
    var imageNodeInsets = UIEdgeInsetsMake(0, 0, 0, Configuration.subnodesSpace)
    var imageSize: CGSize = CGSize(width: 45.0, height: 45.0)
    var defaultTextColor = ThemeManager.shared.currentTheme.defaultTextColor()
    var placeholderTextColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    var textNodeBorderColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    var textNodeBorderWidth: CGFloat = 0.5
    var textNodeMinimumHeight: CGFloat = 100
  }
}
