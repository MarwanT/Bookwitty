//
//  BookDetailsAboutNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/6/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

protocol BookDetailsAboutNodeDelegate {
  func aboutNodeDidTapViewDescription(aboutNode: BookDetailsAboutNode)
}

class BookDetailsAboutNode: ASCellNode {
  fileprivate let headerNode: SectionTitleHeaderNode
  fileprivate let descriptionTextNode: ASTextNode
  fileprivate let viewDescription: DisclosureNode
  fileprivate let topSeparator: ASDisplayNode
  fileprivate let bottomSeparator: ASDisplayNode
  
  var delegate: BookDetailsAboutNodeDelegate?
  
  var configuration = Configuration()
  
  var dispayMode: DisplayMode = .compact
  
  override init() {
    headerNode = SectionTitleHeaderNode()
    descriptionTextNode = ASTextNode()
    viewDescription = DisclosureNode()
    topSeparator = ASDisplayNode()
    bottomSeparator = ASDisplayNode()
    super.init()
    initializeNode()
  }
  
  func initializeNode() {
    automaticallyManagesSubnodes = true
    
    headerNode.setTitle(title: Strings.about_this_book(), verticalBarColor: configuration.headerVerticalBarColor, horizontalBarColor: configuration.headerHorizontalBarColor)
    descriptionTextNode.maximumNumberOfLines = configuration.compactMaximumNumberOfLines
    viewDescription.configuration.style = .highlighted
    viewDescription.text = Strings.view_whole_description()
    viewDescription.delegate = self
    
    topSeparator.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    bottomSeparator.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    topSeparator.style.height = ASDimensionMake(1)
    bottomSeparator.style.height = ASDimensionMake(1)
    
    style.width = ASDimensionMake(UIScreen.main.bounds.width)
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    style.flexGrow = 1.0
    style.flexShrink = 1.0
    
    descriptionTextNode.maximumNumberOfLines = dispayMode == .compact ? configuration.compactMaximumNumberOfLines : 0
    
    var layoutElements = [ASLayoutElement]()
    layoutElements.append(headerNode)
    
    let descriptionInsets = ASInsetLayoutSpec(
      insets: configuration.descriptionTextEdgeInsets,
      child: descriptionTextNode)
    layoutElements.append(descriptionInsets)
    
    switch dispayMode {
    case .compact:
      let topSeparatorInsets = ASInsetLayoutSpec(
        insets: configuration.topSeparatorEdgeInsets,
        child: topSeparator)
      layoutElements.append(topSeparatorInsets)
      layoutElements.append(viewDescription)
      layoutElements.append(bottomSeparator)
    case .expanded:
      break
    }
    
    let horizontalStack = ASStackLayoutSpec(
      direction: .vertical,
      spacing: 0,
      justifyContent: .start,
      alignItems: .stretch,
      children: layoutElements)
    let nodeInsets = ASInsetLayoutSpec(
      insets: configuration.externalEdgeInsets,
      child: horizontalStack)
    
    return nodeInsets
  }
  
  var about: String? {
    didSet {
      descriptionTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .body)
        .append(text: about ?? "", color: configuration.defaultTextColor).attributedString
      setNeedsLayout()
    }
  }
}

extension BookDetailsAboutNode {
  struct Configuration {
    fileprivate let defaultTextColor = ThemeManager.shared.currentTheme.defaultTextColor()
    fileprivate let headerVerticalBarColor = ThemeManager.shared.currentTheme.colorNumber6()
    fileprivate let headerHorizontalBarColor = ThemeManager.shared.currentTheme.colorNumber5()
    fileprivate let compactMaximumNumberOfLines: UInt = 6
    fileprivate let externalEdgeInsets = UIEdgeInsets(
      top: ThemeManager.shared.currentTheme.generalExternalMargin(),
      left: 0, bottom: 0, right: 0)
    fileprivate let descriptionTextEdgeInsets = UIEdgeInsets(
      top: ThemeManager.shared.currentTheme.generalExternalMargin(),
      left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: ThemeManager.shared.currentTheme.generalExternalMargin(), right: ThemeManager.shared.currentTheme.generalExternalMargin())
    fileprivate let topSeparatorEdgeInsets = UIEdgeInsets(
      top: 0, left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: 0, right: 0)
  }
  
  enum DisplayMode {
    case compact
    case expanded
  }
}


extension BookDetailsAboutNode: DisclosureNodeDelegate {
  func disclosureNodeDidTap(disclosureNode: DisclosureNode, selected: Bool) {
    delegate?.aboutNodeDidTapViewDescription(aboutNode: self)
  }
}
