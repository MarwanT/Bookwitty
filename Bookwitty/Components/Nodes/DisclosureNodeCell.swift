//
//  DisclosureNodeCell.swift
//  Bookwitty
//
//  Created by Marwan  on 3/7/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

import AsyncDisplayKit

class DisclosureNodeCell: ASCellNode {
  private let titleTextNode: ASTextNode
  private let imageNode: ASImageNode
  
  var configuration = Configuration() {
    didSet {
      refreshNodeStyling()
    }
  }
  
  override init() {
    imageNode = ASImageNode()
    titleTextNode = ASTextNode()
    super.init()
    initializeNode()
    refreshNodeStyling()
  }
  
  private func initializeNode() {
    automaticallyManagesSubnodes = true
    style.height = ASDimensionMake(Configuration.nodeHeight)
    imageNode.image = #imageLiteral(resourceName: "rightArrow")
    separatorInset = configuration.separatorInsets
    selectedBackgroundView = configuration.backgroundSelectionView
  }
  
  // MARK: Helpers
  private func refreshNodeStyling() {
    let currentText = text
    text = currentText
    imageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(configuration.style.tintColor)
    setNeedsLayout()
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    style.width = ASDimensionMake(constrainedSize.max.width)
    
    let horizontalStack = ASStackLayoutSpec(
      direction: .horizontal,
      spacing: 0,
      justifyContent: .start,
      alignItems: .center,
      children: [titleTextNode, spacer(flexGrow: 1.0), imageNode])
    horizontalStack.style.width = ASDimensionMake(constrainedSize.max.width)
    let insetSpec = ASInsetLayoutSpec(
      insets: configuration.nodeEdgeInsets,
      child: horizontalStack)
    let centerSpec = ASCenterLayoutSpec(
      horizontalPosition: .start,
      verticalPosition: .center,
      sizingOption: ASRelativeLayoutSpecSizingOption.minimumHeight,
      child: insetSpec)
    
    var layoutElements: ASLayoutSpec = centerSpec
    
    if configuration.addInternalBottomSeparator {
      let separatorInsetsSpec = ASInsetLayoutSpec(insets: configuration.separatorInsets, child: separator())
      let verticalStack = ASStackLayoutSpec(
        direction: .vertical,
        spacing: 0,
        justifyContent: .start,
        alignItems: .stretch,
        children: [spacer(flexGrow: 1.0), separatorInsetsSpec])
      let backgroundSpec = ASBackgroundLayoutSpec(
        child: centerSpec, background: verticalStack)
      layoutElements = backgroundSpec
    }

    return layoutElements
  }
  
  // MARK: Helpers
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
  
  var text: String? {
    didSet {
      titleTextNode.attributedText = AttributedStringBuilder(fontDynamicType: configuration.style.fontType)
        .append(text: text ?? "", color: configuration.style.tintColor).attributedString
      setNeedsLayout()
    }
  }
}

extension DisclosureNodeCell {
  enum Style {
    case normal
    case highlighted
    
    var fontType: FontDynamicType {
      switch self {
      case .normal:
        return .caption2
      case .highlighted:
        return .footnote
      }
    }
    
    var tintColor: UIColor {
      switch self {
      case .normal:
        return ThemeManager.shared.currentTheme.defaultTextColor()
      case .highlighted:
        return ThemeManager.shared.currentTheme.colorNumber19()
      }
    }
  }
  
  struct Configuration {
    static var nodeHeight: CGFloat = 45.0
    var nodeEdgeInsets = UIEdgeInsets(
      top: 0, left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: 0, right: 0)
    var style: Style = .normal
    var addInternalBottomSeparator: Bool = false
    var separatorInsets = UIEdgeInsets.zero
    fileprivate var backgroundSelectionView: UIView {
      let backView = UIView(frame: CGRect.zero)
      backView.backgroundColor = ThemeManager.shared.currentTheme.defaultSelectionColor()
      return backView
    }
  }
}
