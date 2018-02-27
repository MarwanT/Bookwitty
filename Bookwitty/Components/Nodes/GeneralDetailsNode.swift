//
//  BookDetailsAboutNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/6/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit
import DTCoreText

protocol GeneralDetailsNodeDelegate: class {
  func generalDetailsNodeDidTapViewDescription(node: GeneralDetailsNode)
}

class GeneralDetailsNode: ASCellNode {
  fileprivate let headerNode: SectionTitleHeaderNode
  fileprivate let descriptionTextNode: DTAttributedLabelNode
  fileprivate let viewDescription: DisclosureNode
  fileprivate let topSeparator: ASDisplayNode
  fileprivate let bottomSeparator: ASDisplayNode
  
  weak var delegate: GeneralDetailsNodeDelegate?
  
  var configuration = Configuration()
  
  private var dispayMode: DisplayMode = .compact
  private(set) var about: String?
  private(set) var section: String?

  init(externalInsets: UIEdgeInsets = UIEdgeInsets.zero) {
    configuration.externalEdgeInsets = externalInsets
    headerNode = SectionTitleHeaderNode()
    descriptionTextNode = DTAttributedLabelNode()
    viewDescription = DisclosureNode()
    topSeparator = ASDisplayNode()
    bottomSeparator = ASDisplayNode()
    super.init()
    initializeNode()
  }
  
  func initializeNode() {
    automaticallyManagesSubnodes = true
    
    headerNode.setTitle(title: section, verticalBarColor: configuration.headerVerticalBarColor, horizontalBarColor: configuration.headerHorizontalBarColor)

    descriptionTextNode.delegate = self
    descriptionTextNode.width = UIScreen.main.bounds.width - (configuration.descriptionTextEdgeInsets.left + configuration.descriptionTextEdgeInsets.right)
    
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

  func setText(aboutText text: String?, sectionTitle section: String = Strings.about_this_book(), displayMode mode: DisplayMode = .compact) {
    self.dispayMode = mode
    self.about = text
    self.section = section

    descriptionTextNode.maxNumberOfLines = dispayMode == .compact ? Int(configuration.compactMaximumNumberOfLines) : 100
    descriptionTextNode.htmlString(text: text, fontDynamicType: FontDynamicType.body)
    headerNode.setTitle(title: section, verticalBarColor: configuration.headerVerticalBarColor, horizontalBarColor: configuration.headerHorizontalBarColor)
    setNeedsLayout()
  }
}

extension GeneralDetailsNode {
  struct Configuration {
    fileprivate let defaultTextColor = ThemeManager.shared.currentTheme.defaultTextColor()
    fileprivate let headerVerticalBarColor = ThemeManager.shared.currentTheme.colorNumber6()
    fileprivate let headerHorizontalBarColor = ThemeManager.shared.currentTheme.colorNumber5()
    fileprivate let compactMaximumNumberOfLines: UInt = 6
    fileprivate var externalEdgeInsets = UIEdgeInsets.zero
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


extension GeneralDetailsNode: DisclosureNodeDelegate {
  func disclosureNodeDidTap(disclosureNode: DisclosureNode, selected: Bool) {
    delegate?.generalDetailsNodeDidTapViewDescription(node: self)
  }
}

extension GeneralDetailsNode: DTAttributedTextContentNodeDelegate {
  func attributedTextContentNode(node: ASCellNode, button: DTLinkButton, didTapOnLink link: URL) {
    WebViewController.present(url: link)
  }

  func attributedTextContentNodeNeedsLayout(node: ASCellNode) {
    self.setNeedsLayout()
  }
}
