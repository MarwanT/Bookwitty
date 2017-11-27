//
//  GetStarted.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/11/22.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class GetStarted: ASDisplayNode {

  fileprivate let backgroundNode = ASDisplayNode()
  fileprivate var textNode: ASDisplayNode?
  fileprivate var registerNode: ASControlNode!

  var configuration = Configuration() {
    didSet {
      setNeedsLayout()
    }
  }

  var getStartedText: String? {
    didSet {
      textNode = createTextNode()
      setNeedsLayout()
    }
  }
  
  override init() {
    super.init()
    initializeComponents()
    applyTheme()
  }

  fileprivate func initializeComponents() {
    automaticallyManagesSubnodes = true
    textNode = createTextNode()
    registerNode = createRegisterNode()

    registerNode.addTarget(self, action: #selector(self.registerNodeTouchUpInside(_:)), forControlEvents: .touchUpInside)
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let wrapperSpec = ASWrapperLayoutSpec(layoutElement: backgroundNode)
    wrapperSpec.style.preferredSize = constrainedSize.max
    wrapperSpec.style.flexGrow = 1.0

    let buttonTextColor = ThemeManager.shared.currentTheme.colorNumber2()
    let buttonBackgroundColor = ThemeManager.shared.currentTheme.defaultButtonColor()
    let iconTintColor = ThemeManager.shared.currentTheme.colorNumber2()
    let iconSize = configuration.iconSize

    let googleButtonNode = createButtonNode(text: Strings.continue_google(), textColor: buttonTextColor, backgroundColor: buttonBackgroundColor, icon: #imageLiteral(resourceName: "comment"), iconSize: iconSize, iconTintColor: iconTintColor)
    let faecbookButtonNode = createButtonNode(text: Strings.continue_facebook(), textColor: buttonTextColor, backgroundColor: buttonBackgroundColor, icon: #imageLiteral(resourceName: "comment"), iconSize: iconSize, iconTintColor: iconTintColor)
    let emailButtonNode = createButtonNode(text: Strings.continue_email(), textColor: buttonTextColor, backgroundColor: buttonBackgroundColor, icon: #imageLiteral(resourceName: "comment"), iconSize: iconSize, iconTintColor: iconTintColor)

    googleButtonNode.addTarget(self, action: #selector(self.continueWithGoogleTouchUpInside(_:)), forControlEvents: .touchUpInside)
    faecbookButtonNode.addTarget(self, action: #selector(self.continueWithFacebookTouchUpInside(_:)), forControlEvents: .touchUpInside)
    emailButtonNode.addTarget(self, action: #selector(self.continueWithEmailTouchUpInside(_:)), forControlEvents: .touchUpInside)

    let loginStackSpec = ASStackLayoutSpec(direction: .vertical,
                                          spacing: configuration.margin,
                                          justifyContent: .center,
                                          alignItems: .stretch,
                                          children: [googleButtonNode, faecbookButtonNode, emailButtonNode])

    var children: [ASLayoutElement] = []
    if let textNode = textNode {
      children.append(textNode)
    }

    children.append(loginStackSpec)
    children.append(registerNode)

    let verticalStackSpec = ASStackLayoutSpec(direction: .vertical,
                                              spacing: 4 * configuration.margin,
                                              justifyContent: .start,
                                              alignItems: .stretch,
                                              children: children)

    let vInset: CGFloat = configuration.vInset
    let hInset = (1.0 / 3.0 * constrainedSize.max.width) / 2.0
    let insets = UIEdgeInsets(top: vInset, left: hInset, bottom: vInset, right: hInset)
    let insetLayoutSpec = ASInsetLayoutSpec(insets: insets, child: verticalStackSpec)

    let backgroundLayoutSpec = ASBackgroundLayoutSpec(child: insetLayoutSpec, background: wrapperSpec)
    backgroundLayoutSpec.style.maxHeight = ASDimension(unit: .points, value: constrainedSize.max.height)
    return backgroundLayoutSpec
  }

  fileprivate func createTextNode() -> ASDisplayNode? {
    guard let text = getStartedText else {
      return nil
    }

    let node = ASDisplayNode()
    node.automaticallyManagesSubnodes = true

    node.layoutSpecBlock = { (node: ASDisplayNode, constrainedSize: ASSizeRange) -> ASLayoutSpec in
      let textNode = ASTextNode()
      textNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption1)
        .append(text: text, color: ThemeManager.shared.currentTheme.defaultTextColor())
        .applyParagraphStyling(alignment: .center)
        .attributedString

      textNode.style.flexGrow = 1.0

      let centerSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: textNode)
      return centerSpec
    }
    return node
  }

  fileprivate func createButtonNode(text: String, textColor: UIColor, backgroundColor: UIColor, icon: UIImage, iconSize: CGSize, iconTintColor: UIColor) -> ASControlNode {
    let node = ASControlNode()
    node.automaticallyManagesSubnodes = true
    node.backgroundColor = backgroundColor
    node.style.height = ASDimension(unit: .points, value: 50.0)
    node.style.flexGrow = 1.0

    node.cornerRadius = 2.0

    node.layoutSpecBlock = { (node: ASDisplayNode, constrainedSize: ASSizeRange) -> ASLayoutSpec in
      let textNode = ASTextNode()
      textNode.attributedText = AttributedStringBuilder(fontDynamicType: .footnote)
        .append(text: text, color: textColor)
        .attributedString

      textNode.style.flexGrow = 1.0

      let iconNode = ASImageNode()
      iconNode.image = icon
      iconNode.style.preferredSize = iconSize
      iconNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(iconTintColor)

      let horizontalStack = ASStackLayoutSpec(direction: .horizontal,
                                              spacing: 0.0,
                                              justifyContent: .center,
                                              alignItems: .center,
                                              children: [iconNode, textNode])
      
      let margin = UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
      let insetLayoutSpec = ASInsetLayoutSpec(insets: margin, child: horizontalStack)
      return insetLayoutSpec
    }
    return node
  }

  fileprivate func createRegisterNode() -> ASControlNode {
    let node = ASControlNode()
    node.automaticallyManagesSubnodes = true

    node.layoutSpecBlock = { (node: ASDisplayNode, constrainedSize: ASSizeRange) -> ASLayoutSpec in
      let textNode = ASTextNode()
      textNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption1)
        .append(text: Strings.create_your_account(), color: ThemeManager.shared.currentTheme.defaultButtonColor())
        .applyParagraphStyling(alignment: .center)
        .attributedString

      textNode.style.flexGrow = 1.0

      let centerSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: textNode)
      return centerSpec
    }
    return node
  }
}

//MARK: - Themeable Implementation
extension GetStarted: Themeable {
  func applyTheme() {
    backgroundNode.backgroundColor = configuration.backgroundColor
  }
}

//MARK: - Configuration Declaration
extension GetStarted {
  struct Configuration {
    let backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
    let margin: CGFloat = ThemeManager.shared.currentTheme.cardInternalMargin()
    let iconSize: CGSize = CGSize(width: 40.0, height: 40.0)
    let iconTintColor = ThemeManager.shared.currentTheme.colorNumber2()
    let vInset: CGFloat = 50.0
  }
}

//MARK: - Actions
extension GetStarted {
  @objc fileprivate func continueWithGoogleTouchUpInside(_ sender: ASControlNode) {
    //TODO: Empty Implementation
  }

  @objc fileprivate func continueWithFacebookTouchUpInside(_ sender: ASControlNode) {
    //TODO: Empty Implementation
  }

  @objc fileprivate func continueWithEmailTouchUpInside(_ sender: ASControlNode) {
    NotificationCenter.default.post(
      name: AppNotification.shouldDisplaySignIn, object: nil)
  }

  @objc fileprivate func registerNodeTouchUpInside(_ sender: ASControlNode) {
    NotificationCenter.default.post(
      name: AppNotification.shouldDisplayRegistration, object: nil)
  }
}
