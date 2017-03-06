//
//  DisclosureNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/6/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class DisclosureNode: ASControlNode {
  private let titleTextNode: ASTextNode
  private let imageNode: ASImageNode
  
  var configuration = Configuration() 
  var nodeSelected: Bool = false 
  
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
    addTarget(self, action: #selector(nodeTouchUpInside(_:)), forControlEvents: ASControlNodeEvent.touchUpInside)
  }
  
  // MARK: Actions
  func nodeTouchUpInside(_ sender: Any?) {
    nodeSelected = !nodeSelected
  }
  
  // MARK: Helpers
  private func refreshNodeStyling() {
    let currentText = text
    text = currentText
    backgroundColor = configuration.normalBackgroundColor
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
    
    return centerSpec
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
  
  func refreshBackground(completion: @escaping () -> Void) {
    let animationDuration: TimeInterval = 0.17
    
    let currentBackgroundColor: UIColor
    switch nodeSelected {
    case true:
      currentBackgroundColor = configuration.selectedBackgroundColor
    case false:
      currentBackgroundColor = configuration.normalBackgroundColor
    }
    
    UIView.animate(
      withDuration: animationDuration,
      animations: {
        self.backgroundColor = currentBackgroundColor
    }, completion: { (_) in
      completion()
    })
  }
  
  var text: String? {
    didSet {
      titleTextNode.attributedText = AttributedStringBuilder(fontDynamicType: configuration.style.fontType)
        .append(text: text ?? "", color: configuration.style.tintColor).attributedString
      setNeedsLayout()
    }
  }
}

extension DisclosureNode {
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
    
    var normalBackgroundColor: UIColor = ThemeManager.shared.currentTheme.colorNumber23()
    var selectedBackgroundColor: UIColor = ThemeManager.shared.currentTheme.defaultSelectionColor()
    var isAutoDeselectable: Bool = true
    var style: Style = .normal
  }
}
