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
  fileprivate let contentNode: ASDisplayNode
  fileprivate let imageNode: ASNetworkImageNode
  fileprivate let textNode: ASEditableTextNode
  fileprivate let overlayNode: ASControlNode
  
  private(set) var mode: DisplayMode = .normal
  
  var configuration = Configuration()
  
  weak var delegate: WriteCommentNodeDelegate?
  
  override init() {
    topSeparator = ASDisplayNode()
    contentNode = ASDisplayNode()
    imageNode = ASNetworkImageNode()
    textNode = ASEditableTextNode()
    overlayNode = ASControlNode()
    super.init()
    initialize()
    applyTheme()
  }
  
  func initialize(with mode: DisplayMode) {
    self.mode = mode
    setNeedsLayout()
  }
  
  private func initialize() {
    automaticallyManagesSubnodes = true
    
    contentNode.automaticallyManagesSubnodes = true
    contentNode.style.flexGrow = 1.0
    
    topSeparator.style.height = ASDimensionMake(1)
    topSeparator.backgroundColor = configuration.separatorColor
    
    imageNode.defaultImage = ThemeManager.shared.currentTheme.penNamePlaceholder
    imageNode.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(0.0, nil)
    imageNode.isLayerBacked = true
  
    overlayNode.addTarget(self, action: #selector(didTapNode(_:)), forControlEvents: .touchUpInside)
    
    placeholder = Strings.what_are_your_thoughts()
  }
  
  override func didLoad() {
    textNode.textView.isEditable = false
  }
  
  // MARK: LAYOUT
  //=============
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    // Set The content border if needed
    switch mode {
    case .normal:
      contentNode.borderWidth = 0
      contentNode.borderColor = nil
    case .bordered:
      contentNode.borderWidth = configuration.borderWidth
      contentNode.borderColor = configuration.borderColor.cgColor
      contentNode.cornerRadius = configuration.borderRadius
    }
    
    // Set image node size
    imageNode.style.preferredSize = configuration.imageSize
    
    // Set the text node content insets
    textNode.textContainerInset = configuration.textFieldContentInset
    
    // Layout the image and text nodes in the content node
    contentNode.layoutSpecBlock = { (node: ASDisplayNode, constrainedSize: ASSizeRange) -> ASLayoutSpec in
      let textInsetsSpec = ASInsetLayoutSpec(
        insets: self.configuration.textFieldInsets, child: self.textNode)
      let mainStack = ASStackLayoutSpec(
        direction: .horizontal, spacing: 0, justifyContent: .start,
        alignItems: .center, children: [self.imageNode, textInsetsSpec])
      let mainStackInsetsSpec = ASInsetLayoutSpec(
        insets: self.configuration.internalInsets, child: mainStack)
      return mainStackInsetsSpec
    }
    
    // Add insets to the content
    let contentInsets = ASInsetLayoutSpec(insets: configuration.externalInsets, child: contentNode)
    
    // Overlay all the subnodes with a touch capacitive node
    let overlaySpec = ASOverlayLayoutSpec(child: contentInsets, overlay: overlayNode)
    
    // Add the separator if configured
    let rootLayoutSpec: ASLayoutSpec
    if configuration.displayTopSeparator {
      rootLayoutSpec = ASStackLayoutSpec(
        direction: .vertical, spacing: 0, justifyContent: .start,
        alignItems: .stretch, children: [topSeparator, overlaySpec])
    } else {
      rootLayoutSpec = overlaySpec
    }
    
    // Ready!
    return rootLayoutSpec
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
      textNode.attributedText = AttributedStringBuilder(fontDynamicType: FontDynamicType.Reference.type4)
        .append(text: text ?? "", color: configuration.textColor).attributedString
      setNeedsLayout()
    }
  }
  
  var placeholder: String? {
    didSet {
      textNode.attributedPlaceholderText = AttributedStringBuilder(fontDynamicType: FontDynamicType.Reference.type17)
        .append(text: placeholder ?? "", color: configuration.placeholderTextColor).attributedString
      setNeedsLayout()
    }
  }
  
  /// Calculate the height based on the image height
  /// TODO: Calculate the max height by basing the calculation on the text node height
  var minCalculatedHeight: CGFloat {
    var calculatedHeight = configuration.imageSize.height + configuration.internalInsets.top + configuration.internalInsets.bottom + configuration.externalInsets.top + configuration.externalInsets.bottom
    if configuration.displayTopSeparator {
      calculatedHeight += 1
    }
    return calculatedHeight
  }
}

// MARK: - THEMEABLE PROTOCOL
                                    //*******\\
extension WriteCommentNode: Themeable {
  func applyTheme() {
    
  }
}

// MARK: - DISPLAY MODE
                                    //*******\\
extension WriteCommentNode {
  enum DisplayMode {
    case normal
    case bordered
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
    var placeholderText: String
    var displayTopSeparator: Bool
    var externalInsets: UIEdgeInsets
    var internalInsets: UIEdgeInsets
    var textFieldInsets: UIEdgeInsets
    var textFieldContentInset: UIEdgeInsets
    var imageSize: CGSize
    var borderRadius: CGFloat
    
    init() {
      separatorColor = theme.defaultSeparatorColor()
      borderColor = theme.defaultSeparatorColor()
      borderWidth = 1
      placeholderText = Strings.what_are_your_thoughts()
      displayTopSeparator = false
      imageSize = CGSize(width: 45.0, height: 45.0)
      textColor = theme.defaultTextColor()
      placeholderTextColor = theme.defaultGrayedTextColor()
      borderRadius = theme.defaultCornerRadius()
      externalInsets = UIEdgeInsets(
        top: theme.cardExternalMargin(),
        left: theme.cardExternalMargin(),
        bottom: theme.cardExternalMargin(),
        right: theme.cardExternalMargin())
      internalInsets = UIEdgeInsets(
        top: 8, left: 8, bottom: 8, right: 8)
      textFieldInsets = UIEdgeInsets(
        top: 0, left: 8, bottom: 0, right: 0)
      textFieldContentInset = UIEdgeInsets.zero
    }
  }
}
