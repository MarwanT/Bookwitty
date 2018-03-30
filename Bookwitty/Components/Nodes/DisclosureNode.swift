//
//  DisclosureNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/6/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

protocol DisclosureNodeDelegate: class {
  func disclosureNodeDidTap(disclosureNode: DisclosureNode, selected: Bool)
}

class DisclosureNode: ASControlNode {
  private let titleTextNode: ASTextNode
  private let imageNode: ASImageNode
  
  var nodeSelected: Bool = false {
    didSet {
      transitionLayout(withAnimation: true, shouldMeasureAsync: false, measurementCompletion: nil)
    }
  }
  
  var configuration = Configuration() {
    didSet {
      refreshNodeStyling()
    }
  }
  
  weak var delegate: DisclosureNodeDelegate?
  
  override init() {
    imageNode = ASImageNode()
    titleTextNode = ASTextNode()
    super.init()
    initializeNode()
    refreshNodeStyling()
  }
  
  override func animateLayoutTransition(_ context: ASContextTransitioning) {
    refreshBackground {
      context.completeTransition(true)
      if self.nodeSelected && self.configuration.isAutoDeselectable {
        self.nodeSelected = false
      }
    }
  }
  
  private func initializeNode() {
    automaticallyManagesSubnodes = true
    style.height = ASDimensionMake(Configuration.nodeHeight)
    imageNode.image = #imageLiteral(resourceName: "rightArrow")
    imageNode.contentMode = UIViewContentMode.scaleAspectFit
    imageNode.style.preferredSize = CGSize(width: 10, height: 14)
    addTarget(self, action: #selector(nodeTouchUpInside(_:)), forControlEvents: ASControlNodeEvent.touchUpInside)
  }
  
  // MARK: Actions
  func nodeTouchUpInside(_ sender: Any?) {
    nodeSelected = !nodeSelected
    delegate?.disclosureNodeDidTap(disclosureNode: self, selected: nodeSelected)
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
    
    let textInsetSpec = ASInsetLayoutSpec(
      insets: configuration.textEdgeInsets, child: titleTextNode)
    textInsetSpec.style.flexGrow = 1.0
    textInsetSpec.style.flexShrink = 1.0
    
    let imageInsetSpec = ASInsetLayoutSpec(
      insets: configuration.imageNodeInsets, child: imageNode)
    
    let horizontalStack = ASStackLayoutSpec(
      direction: .horizontal,
      spacing: 0,
      justifyContent: .spaceBetween,
      alignItems: .center,
      children: [textInsetSpec, imageInsetSpec])
    let insetSpec = ASInsetLayoutSpec(
      insets: configuration.nodeEdgeInsets,
      child: horizontalStack)
    
    return insetSpec
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
    static var nodeHeight: CGFloat = 48.0
    var nodeEdgeInsets = UIEdgeInsets(
      top: 0, left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: 0, right: 0)
    var textEdgeInsets = UIEdgeInsets(
      top: 0, left: 0,
      bottom: 0, right: 0)
    var imageNodeInsets = UIEdgeInsets(
      top: 0, left: 10, bottom: 0,
      right: ThemeManager.shared.currentTheme.generalExternalMargin())
    var normalBackgroundColor: UIColor = ThemeManager.shared.currentTheme.colorNumber23()
    var selectedBackgroundColor: UIColor = ThemeManager.shared.currentTheme.defaultSelectionColor()
    var isAutoDeselectable: Bool = true
    var style: Style = .normal
  }
}
