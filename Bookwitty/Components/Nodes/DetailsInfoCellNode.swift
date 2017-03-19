//
//  DetailsInfoCellNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/7/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class DetailsInfoCellNode: ASCellNode {
  fileprivate var keyTextNode: ASTextNode
  fileprivate var valueTextNode: ASTextNode
  
  var configuration = Configuration() {
    didSet {
      setNeedsLayout()
    }
  }
  
  override init() {
    keyTextNode = ASTextNode()
    valueTextNode = ASTextNode()
    super.init()
    automaticallyManagesSubnodes = true
    style.minHeight = ASDimensionMake(Configuration.minimumHeight)
    separatorInset = configuration.separatorInsets
    selectedBackgroundView = configuration.backgroundSelectionView
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    valueTextNode.style.flexShrink = 1.0
    
    let keyNodeInsets = ASInsetLayoutSpec(
      insets: configuration.keyNodeEdgeInsets,
      child: keyTextNode)
    
    let horizontalStacklayoutElements: [ASLayoutElement] = [
      keyNodeInsets,
      spacer(flexGrow: 1.0),
      valueTextNode
    ]
    
    let horizontalStack = ASStackLayoutSpec(
      direction: .horizontal,
      spacing: 0,
      justifyContent: .start,
      alignItems: .center,
      children: horizontalStacklayoutElements)
    horizontalStack.style.width = ASDimensionMake(constrainedSize.max.width)
    let horizontalStackInsets = ASInsetLayoutSpec(
      insets: configuration.horizontalStackEdgeInsets,
      child: horizontalStack)
    
    var layoutElements: ASLayoutSpec = horizontalStackInsets
    
    if configuration.addInternalBottomSeparator {
      let separatorInsetsSpec = ASInsetLayoutSpec(insets: configuration.separatorInsets, child: separator())
      let verticalStack = ASStackLayoutSpec(
        direction: .vertical,
        spacing: 0,
        justifyContent: .start,
        alignItems: .stretch,
        children: [spacer(flexGrow: 1.0), separatorInsetsSpec])
      let backgroundSpec = ASBackgroundLayoutSpec(
        child: horizontalStackInsets, background: verticalStack)
      layoutElements = backgroundSpec
    }
    
    return layoutElements
  }
  
  var key: String? {
    didSet {
      keyTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption1)
        .append(text: key ?? "", color: configuration.defaultTextColor).attributedString
      setNeedsLayout()
    }
  }
  
  var value: String? {
    didSet {
      valueTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption2)
        .append(text: value ?? "", color: configuration.defaultTextColor).applyParagraphStyling(alignment: NSTextAlignment.right).attributedString
      setNeedsLayout()
    }
  }
  
  private func spacer(flexGrow: CGFloat = 0.0, height: CGFloat = 0.0, width: CGFloat = 0.0) -> ASLayoutSpec {
    return ASLayoutSpec().styled { (style) in
      style.height = ASDimensionMake(height)
      style.width = ASDimensionMake(width)
      style.flexGrow = flexGrow
      style.flexShrink = flexGrow
    }
  }
  
  private func separator() -> ASDisplayNode {
    let separator = ASDisplayNode()
    separator.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    separator.style.height = ASDimensionMake(1)
    return separator
  }
}

extension DetailsInfoCellNode {
  struct Configuration {
    static let minimumHeight: CGFloat = 45
    let defaultTextColor = ThemeManager.shared.currentTheme.defaultTextColor()
    let horizontalStackEdgeInsets = UIEdgeInsets(
      top: 10, left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: 10, right: ThemeManager.shared.currentTheme.generalExternalMargin())
    let keyNodeEdgeInsets = UIEdgeInsets(
      top: 0, left: 0, bottom: 0,
      right: (ThemeManager.shared.currentTheme.generalExternalMargin() * 2))
    let separatorInsets = UIEdgeInsets(
      top: 0, left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: 0, right: 0)
    var addInternalBottomSeparator: Bool = false
    fileprivate var backgroundSelectionView: UIView {
      let backView = UIView(frame: CGRect.zero)
      backView.backgroundColor = ThemeManager.shared.currentTheme.defaultSelectionColor()
      return backView
    }
  }
}
