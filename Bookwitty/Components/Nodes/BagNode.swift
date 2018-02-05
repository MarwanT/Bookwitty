//
//  BagNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/11/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

protocol BagNodeDelegate: class {
  func bagNodeShopOnline(node: BagNode)
}

class BagNode: ASDisplayNode {
  fileprivate let textNode: ASTextNode
  fileprivate let shopOnlineButton: ASButtonNode
  
  var configuration = Configuration()
  
  weak var delegate: BagNodeDelegate?
  
  override init() {
    textNode = ASTextNode()
    shopOnlineButton = ASButtonNode()
    super.init()
    initializeComponents()
    applyTheme()
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let stackSpecs = ASStackLayoutSpec(
      direction: .vertical,
      spacing: 20,
      justifyContent: .center,
      alignItems: .stretch,
      children: [textNode, shopOnlineButton])
    let insetsSpec = ASInsetLayoutSpec(
      insets: configuration.edgeInsets, child: stackSpecs)
    return insetsSpec
  }
  
  private func initializeComponents() {
    automaticallyManagesSubnodes = true
    text = Strings.shop_in_app_coming_soon_message()
    shopOnlineButtonTitle = Strings.shop_online()
    backgroundColor = configuration.backgroundColor
    shopOnlineButton.addTarget(self, action: #selector(shopOnlineTouchUpInside(_:)), forControlEvents: .touchUpInside)
  }
  
  private var text: String? {
    didSet {
      textNode.attributedText = AttributedStringBuilder(fontDynamicType: .subheadline)
        .append(text: text ?? "", color: configuration.defaultTextColor).applyParagraphStyling(alignment: NSTextAlignment.center).attributedString
      setNeedsLayout()
    }
  }
  
  private var shopOnlineButtonTitle: String? {
    didSet {
      shopOnlineButton.setTitle(shopOnlineButtonTitle ?? "", with: FontDynamicType.subheadline.font, with: configuration.shopOnlineButtonTitleColor, for: UIControlState.normal)
      setNeedsLayout()
    }
  }
}

// MARK: - Actions
extension BagNode {
  func shopOnlineTouchUpInside(_ sender: Any) {
    delegate?.bagNodeShopOnline(node: self)
  }
}

// MARK: - Theme
extension BagNode: Themeable {
  func applyTheme() {
    ThemeManager.shared.currentTheme.styleECommercePrimaryButton(button: shopOnlineButton)
  }
}

// MARK: - Declaration
extension BagNode {
  struct Configuration {
    fileprivate let shopOnlineButtonTitleColor = ThemeManager.shared.currentTheme.colorNumber23()
    fileprivate let defaultTextColor = ThemeManager.shared.currentTheme.defaultTextColor()
    fileprivate let backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
    fileprivate let edgeInsets = UIEdgeInsets(
      top: 0, left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: 0, right: ThemeManager.shared.currentTheme.generalExternalMargin())
  }
}
