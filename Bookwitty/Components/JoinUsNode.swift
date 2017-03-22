//
//  JoinUsNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/22/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class JoinUsNode: ASDisplayNode {
  fileprivate let titleTextNode: ASTextNode
  fileprivate let descriptionTextNode: ASTextNode
  fileprivate let getStartedButtonNode: ASButtonNode
  fileprivate let alreadyHaveAnAccountTextNode: ASTextNode
  
  var configuration = Configuration()
  
  override init() {
    titleTextNode = ASTextNode()
    descriptionTextNode = ASTextNode()
    getStartedButtonNode = ASButtonNode()
    alreadyHaveAnAccountTextNode = ASTextNode()
    super.init()
    initializeComponent()
    applyTheme()
  }
  
  private func initializeComponent() {
    automaticallyManagesSubnodes = true
    backgroundColor = configuration.backgroundColor
    
    titleText = "Personalize your feed"
    descriptionText = "View articles reading lists and book recommendations in your feed based on your interests."
    getStartedButtonTitle = "Get started"
    alreadyHaveAnAccountAttributedString = AttributedStringBuilder(fontDynamicType: FontDynamicType.caption1).append(text: "Already have an account?\n", color: configuration.textColor).append(text: "Sign In", fontDynamicType: FontDynamicType.footnote, color: configuration.signInTextColor).applyParagraphStyling(alignment: NSTextAlignment.center).attributedString
    
    getStartedButtonNode.addTarget(self, action:
      #selector(self.getStartedTouchUpInside(_:)), forControlEvents: ASControlNodeEvent.touchUpInside)
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let stackSpec = ASStackLayoutSpec(
      direction: .vertical, spacing: 0,
      justifyContent: .center,
      alignItems: .stretch,
      children: [
        titleTextNode,
        ASLayoutSpec.spacer(height: 15),
        descriptionTextNode,
        ASLayoutSpec.spacer(height: 50),
        getStartedButtonNode,
        ASLayoutSpec.spacer(height: 50),
        alreadyHaveAnAccountTextNode
      ])
    let externalInsetSpec = ASInsetLayoutSpec(
      insets: configuration.externalEdgeInsets,
      child: stackSpec)
    return externalInsetSpec
  }
  
  var titleText: String? {
    didSet {
      titleTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .title1)
        .append(text: titleText ?? "", color: configuration.textColor).applyParagraphStyling(alignment: NSTextAlignment.center).attributedString
      setNeedsLayout()
    }
  }
  var descriptionText: String? {
    didSet {
      descriptionTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .callout)
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
}

extension JoinUsNode: Themeable {
  func applyTheme() {
    ThemeManager.shared.currentTheme.styleECommercePrimaryButton(button: getStartedButtonNode)
  }
}

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
  }
}
