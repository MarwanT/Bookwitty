//
//  JoinUsNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/22/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class JoinUsNode: ASDisplayNode {
  fileprivate let imageColoredBackgroundNode: ASDisplayNode
  fileprivate let imageWhiteBackgroundNode: ASDisplayNode
  fileprivate let imageNode: ASImageNode
  fileprivate let titleTextNode: ASTextNode
  fileprivate let descriptionTextNode: ASTextNode
  fileprivate let getStartedButtonNode: ASButtonNode
  fileprivate let alreadyHaveAnAccountTextNode: ASTextNode
  fileprivate let contentBackgroundNode: ASDisplayNode
  
  var configuration = Configuration()
  
  override init() {
    imageColoredBackgroundNode = ASDisplayNode()
    imageWhiteBackgroundNode = ASDisplayNode()
    imageNode = ASImageNode()
    titleTextNode = ASTextNode()
    descriptionTextNode = ASTextNode()
    getStartedButtonNode = ASButtonNode()
    alreadyHaveAnAccountTextNode = ASTextNode()
    contentBackgroundNode = ASDisplayNode()
    super.init()
    initializeComponent()
    applyTheme()
  }
  
  private func initializeComponent() {
    automaticallyManagesSubnodes = true
    backgroundColor = configuration.backgroundColor
    imageColoredBackgroundNode.backgroundColor = configuration.backgroundColor
    
    titleText = Strings.join_us_to_personalize_feed_title()
    descriptionText = Strings.join_us_to_personalize_feed_description()
    getStartedButtonTitle = Strings.get_started()
    alreadyHaveAnAccountAttributedString = AttributedStringBuilder(fontDynamicType: FontDynamicType.footnote).append(text: "\(Strings.already_have_an_account())\n", color: configuration.textColor).append(text: Strings.sign_in(), fontDynamicType: FontDynamicType.footnote, color: configuration.signInTextColor).applyParagraphStyling(alignment: NSTextAlignment.center).attributedString
    
    imageNode.image = #imageLiteral(resourceName: "illustrationOstrich")
    imageNode.contentMode = UIViewContentMode.scaleAspectFit
    imageWhiteBackgroundNode.backgroundColor = UIColor.white
    
    getStartedButtonNode.contentEdgeInsets = configuration.buttonContentEdgeInsets
    
    contentBackgroundNode.backgroundColor = UIColor.white
    
    getStartedButtonNode.addTarget(self, action:
      #selector(self.getStartedTouchUpInside(_:)), forControlEvents: ASControlNodeEvent.touchUpInside)
    alreadyHaveAnAccountTextNode.addTarget(self, action:
      #selector(self.alreadyHaveAnAccountTouchUpInside(_:)), forControlEvents: ASControlNodeEvent.touchUpInside)
    
    imageColoredBackgroundNode.isLayerBacked = true
    imageWhiteBackgroundNode.isLayerBacked = true
    imageNode.isLayerBacked = true
    titleTextNode.isLayerBacked = true
    descriptionTextNode.isLayerBacked = true
    contentBackgroundNode.isLayerBacked = true
  }
  
  var imageBottomWhiteHeightDimension: CGFloat {
    return 55.5
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    // TOP PART OF THE NODE
    //----------------------
    let imageBackgroundForegroundInset = ASInsetLayoutSpec(
      insets: UIEdgeInsets(top: CGFloat.infinity, left: 0, bottom: 0, right: 0),
      child: imageWhiteBackgroundNode)
    imageWhiteBackgroundNode.style.height = ASDimensionMake("\(imageBottomWhiteHeightDimension)%")
    let imageBackgroundOverlaySpec = ASOverlayLayoutSpec(
      child: imageColoredBackgroundNode,
      overlay: imageBackgroundForegroundInset)
    
    let imageSpec = ASBackgroundLayoutSpec(child: imageNode, background: imageBackgroundOverlaySpec)
    imageSpec.style.maxHeight = ASDimensionMake(constrainedSize.max.height/2)
    imageSpec.style.flexShrink = 1.0
    
    
    // BOTTOM HALF OF THE NODE
    //-------------------------
    
    let contentStackSpec = ASStackLayoutSpec(
      direction: .vertical, spacing: 0,
      justifyContent: .center,
      alignItems: .center,
      children: [
        titleTextNode,
        ASLayoutSpec.spacer(height: 5),
        descriptionTextNode,
        ASLayoutSpec.spacer(height: 30),
        getStartedButtonNode,
        ASLayoutSpec.spacer(height: 30),
        alreadyHaveAnAccountTextNode
      ])
    contentStackSpec.style.minHeight = ASDimensionMake(constrainedSize.max.height/2)
    let externalContentInsetSpec = ASInsetLayoutSpec(
      insets: configuration.externalEdgeInsets,
      child: contentStackSpec)
    externalContentInsetSpec.style.flexGrow = 1.0
    
    
    // Build the base vertical Layout
    //--------------------------------
    let verticalStack = ASStackLayoutSpec(
      direction: .vertical,
      spacing: 0,
      justifyContent: ASStackLayoutJustifyContent.start,
      alignItems: .stretch,
      children: [imageSpec, externalContentInsetSpec])
    verticalStack.style.height = ASDimensionMake(constrainedSize.max.height)
    let verticalStackBackgroundSpec = ASBackgroundLayoutSpec(
      child: verticalStack, background: contentBackgroundNode)
    return verticalStackBackgroundSpec
  }
  
  var titleText: String? {
    didSet {
      titleTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .headline)
        .append(text: titleText ?? "", color: configuration.textColor).applyParagraphStyling(alignment: NSTextAlignment.center).attributedString
      setNeedsLayout()
    }
  }
  var descriptionText: String? {
    didSet {
      descriptionTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .subheadline)
        .append(text: descriptionText ?? "", color: configuration.textColor).applyParagraphStyling(alignment: NSTextAlignment.center).attributedString
      setNeedsLayout()
    }
  }
  var getStartedButtonTitle: String? {
    didSet {
      getStartedButtonNode.setTitle(getStartedButtonTitle ?? "", with: FontDynamicType.subheadline.font, with: configuration.buttonTextColor, for: UIControlState.normal)
      setNeedsLayout()
    }
  }
  var alreadyHaveAnAccountAttributedString: NSAttributedString? {
    didSet {
      alreadyHaveAnAccountTextNode.attributedText = alreadyHaveAnAccountAttributedString
      setNeedsLayout()
    }
  }
}

// MARK: - Actions
extension JoinUsNode {
  func getStartedTouchUpInside(_ sender: Any) {
    NotificationCenter.default.post(
      name: AppNotification.shouldDisplayRegistration, object: nil)
  }
  
  func alreadyHaveAnAccountTouchUpInside(_ sender: Any) {
    NotificationCenter.default.post(
      name: AppNotification.shouldDisplaySignIn, object: nil)
  }
}

// MARK: - Themeable
extension JoinUsNode: Themeable {
  func applyTheme() {
    ThemeManager.shared.currentTheme.stylePrimaryButton(button: getStartedButtonNode)
  }
}

// MARK: - Declaration
extension JoinUsNode {
  struct Configuration {
    let textColor = ThemeManager.shared.currentTheme.defaultTextColor()
    let buttonTextColor = ThemeManager.shared.currentTheme.colorNumber23()
    let backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
    let linkTextColor = ThemeManager.shared.currentTheme.colorNumber16()
    let signInTextColor = ThemeManager.shared.currentTheme.colorNumber19()
    let externalEdgeInsets = UIEdgeInsets(
      top: ThemeManager.shared.currentTheme.generalExternalMargin(),
      left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: ThemeManager.shared.currentTheme.generalExternalMargin(),
      right: ThemeManager.shared.currentTheme.generalExternalMargin())
    let buttonContentEdgeInsets = UIEdgeInsets(
      top: 0, left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: 0, right: ThemeManager.shared.currentTheme.generalExternalMargin())
  }
}
