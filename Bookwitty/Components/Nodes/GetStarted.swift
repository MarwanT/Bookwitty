//
//  GetStarted.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/11/22.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit
import GoogleSignIn

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
  
  lazy var genericViewController: UIViewController = self.viewController(title: Strings.account())
  
  override init() {
    super.init()
    GIDSignIn.sharedInstance().uiDelegate = self
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

    let theme = ThemeManager.shared.currentTheme
    let buttonTextColor = theme.colorNumber2()
    let buttonBackgroundColor = theme.defaultButtonColor()
    let iconTintColor = theme.colorNumber2()
    let iconSize = configuration.iconSize

    let googleButtonNode = createButtonNode(text: Strings.continue_google(), textColor: buttonTextColor, backgroundColor: buttonBackgroundColor, icon:#imageLiteral(resourceName: "google"), iconSize: iconSize, iconTintColor: iconTintColor)
    let faecbookButtonNode = createButtonNode(text: Strings.continue_facebook(), textColor: buttonTextColor, backgroundColor: theme.colorNumber17(), icon:#imageLiteral(resourceName: "facebook"), iconSize: iconSize, iconTintColor: iconTintColor)
    let emailButtonNode = createButtonNode(text: Strings.continue_email(), textColor: buttonTextColor, backgroundColor: theme.colorNumber13(), icon: #imageLiteral(resourceName: "email"), iconSize: iconSize, iconTintColor: iconTintColor)

    googleButtonNode.addTarget(self, action: #selector(self.continueWithGoogleTouchUpInside(_:)), forControlEvents: .touchUpInside)
    faecbookButtonNode.addTarget(self, action: #selector(self.continueWithFacebookTouchUpInside(_:)), forControlEvents: .touchUpInside)
    emailButtonNode.addTarget(self, action: #selector(self.continueWithEmailTouchUpInside(_:)), forControlEvents: .touchUpInside)

    let loginStackSpec = ASStackLayoutSpec(direction: .vertical,
                                          spacing: configuration.margin,
                                          justifyContent: .center,
                                          alignItems: .stretch,
                                          children: [googleButtonNode, faecbookButtonNode, emailButtonNode])

    loginStackSpec.style.flexShrink = 1.0

    var children: [ASLayoutElement] = []
    if let textNode = textNode {
      children.append(textNode)
    }

    children.append(loginStackSpec)
    children.append(registerNode)

    let verticalStackSpec = ASStackLayoutSpec(direction: .vertical,
                                              spacing: configuration.margin,
                                              justifyContent: .spaceAround,
                                              alignItems: .stretch,
                                              children: children)

    verticalStackSpec.style.flexShrink = 1.0

    let vInset: CGFloat = configuration.vInset
    let hInset = (1.0 / 4.0 * constrainedSize.max.width) / 2.0
    let insets = UIEdgeInsets(top: vInset, left: hInset, bottom: vInset, right: hInset)
    let insetLayoutSpec = ASInsetLayoutSpec(insets: insets, child: verticalStackSpec)

    insetLayoutSpec.style.flexShrink = 1.0

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
    node.style.flexShrink = 1.0

    node.cornerRadius = 2.0

    node.layoutSpecBlock = { (node: ASDisplayNode, constrainedSize: ASSizeRange) -> ASLayoutSpec in
      let textNode = ASTextNode()
      textNode.attributedText = AttributedStringBuilder(fontDynamicType: .footnote)
        .append(text: text, color: textColor)
        .attributedString

      textNode.style.flexGrow = 1.0

      let iconNode = ASImageNode()
      iconNode.image = icon
      iconNode.contentMode = UIViewContentMode.scaleAspectFit
      iconNode.style.preferredSize = iconSize
      iconNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(iconTintColor)

      let horizontalStack = ASStackLayoutSpec(direction: .horizontal,
                                              spacing: 0.0,
                                              justifyContent: .center,
                                              alignItems: .center,
                                              children: [iconNode,
                                                         ASLayoutSpec.spacer(width: 10),
                                                         textNode])
      
      let margin = UIEdgeInsets(top: 5.0, left: 20.0, bottom: 5.0, right: 20.0)
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
        .append(text: Strings.create_your_account_using_email(), color: ThemeManager.shared.currentTheme.defaultButtonColor())
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
    let iconSize: CGSize = CGSize(width: 20.0, height: 20.0)
    let iconTintColor = ThemeManager.shared.currentTheme.colorNumber2()
    let vInset: CGFloat = 50.0
  }
}

//MARK: - Actions
extension GetStarted {
  @objc fileprivate func continueWithGoogleTouchUpInside(_ sender: ASControlNode) {
    GIDSignIn.sharedInstance().signIn()
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

extension GetStarted: Localizable {
  func applyLocalization() {
    self.genericViewController.title = Strings.account()
  }
  
  fileprivate func observeLanguageChanges() {
    NotificationCenter.default.addObserver(self, selector: #selector(languageValueChanged(notification:)), name: Localization.Notifications.Name.languageValueChanged, object: nil)
  }
  
  @objc
  fileprivate func languageValueChanged(notification: Notification) {
    applyLocalization()
  }
}

extension GetStarted: GIDSignInUIDelegate {
  // Stop the UIActivityIndicatorView animation that was started when the user
  // pressed the Sign In button
  func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
    //TODO: Show loader if needed
  }

  // Present a view that prompts the user to sign in with Google
  func sign(_ signIn: GIDSignIn!,
            present viewController: UIViewController!) {
    self.genericViewController.present(viewController, animated: true, completion: nil)
  }

  // Dismiss the "Sign in with Google" view
  func sign(_ signIn: GIDSignIn!,
            dismiss viewController: UIViewController!) {
    viewController.dismiss(animated: true, completion: nil)
  }
}
