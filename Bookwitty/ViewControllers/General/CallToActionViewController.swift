//
//  CallToActionViewController.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2018/04/03.
//  Copyright © 2018 Keeward. All rights reserved.
//

import AsyncDisplayKit
import GoogleSignIn

class CallToActionViewController: ASViewController<ASDisplayNode> {

  fileprivate let controllerNode = ASDisplayNode()

  fileprivate let backgroundNode = ASControlNode()
  fileprivate let alertNode = ASDisplayNode()

  fileprivate var iconNode = ASImageNode()

  fileprivate var textNode: ASDisplayNode!
  fileprivate var googleButtonNode: ASControlNode!
  fileprivate var facebookButtonNode: ASControlNode!
  fileprivate var emailButtonNode: ASControlNode!
  fileprivate var registerNode: ASControlNode!
  fileprivate var closeNode: ASControlNode!

  var configuration = Configuration() {
    didSet {
      self.node.setNeedsLayout()
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init() {
    super.init(node: controllerNode)

    iconNode.style.preferredSize = configuration.iconSize
    iconNode.image = #imageLiteral(resourceName: "bookwittyClear")

    textNode = createTextNode()
    registerNode = createActionNode(with: Strings.create_your_account(), fontType: .caption1)
    closeNode = createActionNode(with: Strings.close(), fontType: .caption2)

    let theme = ThemeManager.shared.currentTheme
    let buttonTextColor = theme.colorNumber2()
    let iconTintColor = theme.colorNumber2()
    let buttonIconSize = configuration.buttonIconSize

    googleButtonNode = createButtonNode(text: Strings.continue_google(), textColor: buttonTextColor, backgroundColor: theme.defaultButtonColor(), icon:#imageLiteral(resourceName: "google"), iconSize: buttonIconSize, iconTintColor: iconTintColor)
    facebookButtonNode = createButtonNode(text: Strings.continue_facebook(), textColor: buttonTextColor, backgroundColor: theme.colorNumber17(), icon:#imageLiteral(resourceName: "facebook"), iconSize: buttonIconSize, iconTintColor: iconTintColor)
    emailButtonNode = createButtonNode(text: Strings.continue_email(), textColor: buttonTextColor, backgroundColor: theme.colorNumber13(), icon: #imageLiteral(resourceName: "email"), iconSize: buttonIconSize, iconTintColor: iconTintColor)

    controllerNode.automaticallyManagesSubnodes = true
    controllerNode.layoutSpecBlock = { (node: ASDisplayNode, constrainedSize: ASSizeRange) -> ASLayoutSpec in
      self.backgroundNode.style.maxSize = constrainedSize.max
      self.backgroundNode.backgroundColor = UIColor.black.withAlphaComponent(0.5)
      let backgroundNodeLayoutSpec = ASWrapperLayoutSpec(layoutElement: self.backgroundNode)

      self.alertNode.backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()

      let vInset: CGFloat = constrainedSize.max.height / 8.0
      let hInset = (1.0 / 5.0 * constrainedSize.max.width) / 2.0
      let alertInsets = UIEdgeInsets(top: vInset, left: hInset, bottom: vInset, right: hInset)

      let insetLayoutSpec = ASInsetLayoutSpec(insets: alertInsets, child: self.alertNode)

      let loginStackSpec = ASStackLayoutSpec(direction: .vertical,
                                             spacing: self.configuration.margin,
                                             justifyContent: .center,
                                             alignItems: .stretch,
                                             children: [self.googleButtonNode, self.facebookButtonNode, self.emailButtonNode])

      loginStackSpec.style.flexShrink = 1.0

      let iconCenterLayoutSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: self.iconNode)

      var children: [ASLayoutElement] = []
      children.append(iconCenterLayoutSpec)
      children.append(self.textNode)
      children.append(loginStackSpec)
      children.append(self.registerNode)
      children.append(self.closeNode)

      let verticalStackSpec = ASStackLayoutSpec(direction: .vertical,
                                                spacing: self.configuration.margin,
                                                justifyContent: .spaceAround,
                                                alignItems: .stretch,
                                                children: children)

      let componentsInsetLayoutSpec = ASInsetLayoutSpec(insets: alertInsets, child: verticalStackSpec)
      let componentsInset = UIEdgeInsets(top: self.configuration.vInset, left: self.configuration.margin, bottom: self.configuration.margin, right: self.configuration.margin)
      let componentsInnerInsetLayoutSpec = ASInsetLayoutSpec(insets: componentsInset, child: componentsInsetLayoutSpec)

      let foregroundNodeLayoutSpec = ASOverlayLayoutSpec(child: insetLayoutSpec, overlay: componentsInnerInsetLayoutSpec)
      let backgroundLayoutSpec = ASBackgroundLayoutSpec(child: foregroundNodeLayoutSpec, background: backgroundNodeLayoutSpec)
      return backgroundLayoutSpec
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    GIDSignIn.sharedInstance().uiDelegate = self

    backgroundNode.addTarget(self, action: #selector(self.closeNodeTouchUpInside(_:)), forControlEvents: .touchUpInside)

    googleButtonNode.addTarget(self, action: #selector(self.continueWithGoogleTouchUpInside(_:)), forControlEvents: .touchUpInside)
    facebookButtonNode.addTarget(self, action: #selector(self.continueWithFacebookTouchUpInside(_:)), forControlEvents: .touchUpInside)
    emailButtonNode.addTarget(self, action: #selector(self.continueWithEmailTouchUpInside(_:)), forControlEvents: .touchUpInside)

    registerNode.addTarget(self, action: #selector(self.registerNodeTouchUpInside(_:)), forControlEvents: .touchUpInside)
    closeNode.addTarget(self, action: #selector(self.closeNodeTouchUpInside(_:)), forControlEvents: .touchUpInside)
  }

  fileprivate func createTextNode() -> ASDisplayNode? {
    let node = ASDisplayNode()
    node.automaticallyManagesSubnodes = true

    node.layoutSpecBlock = { (node: ASDisplayNode, constrainedSize: ASSizeRange) -> ASLayoutSpec in
      let textNode = ASTextNode()
      let text = "Please sign-in to continue"
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

  fileprivate func createActionNode(with text: String, fontType: FontDynamicType) -> ASControlNode {
    let node = ASControlNode()
    node.automaticallyManagesSubnodes = true

    node.layoutSpecBlock = { (node: ASDisplayNode, constrainedSize: ASSizeRange) -> ASLayoutSpec in
      let textNode = ASTextNode()
      textNode.attributedText = AttributedStringBuilder(fontDynamicType: fontType)
        .append(text: text, color: ThemeManager.shared.currentTheme.defaultButtonColor())
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
}

//MARK: - Actions
extension CallToActionViewController {
  @objc fileprivate func continueWithGoogleTouchUpInside(_ sender: ASControlNode) {
    GIDSignIn.sharedInstance().signIn()
  }

  @objc fileprivate func continueWithFacebookTouchUpInside(_ sender: ASControlNode) {
    //TODO: Empty Implementation
  }

  @objc fileprivate func continueWithEmailTouchUpInside(_ sender: ASControlNode) {
    self.dismiss(animated: true) {
      NotificationCenter.default.post(
        name: AppNotification.shouldDisplaySignIn, object: nil)
    }
  }

  @objc fileprivate func registerNodeTouchUpInside(_ sender: ASControlNode) {
    //TODO: Empty Implementation
  }

  @objc fileprivate func closeNodeTouchUpInside(_ sender: ASControlNode) {
    self.dismiss(animated: true, completion: nil)
  }
}

extension CallToActionViewController {
  struct Configuration {
    let backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
    let margin: CGFloat = ThemeManager.shared.currentTheme.cardInternalMargin()
    let iconSize: CGSize = CGSize(width: 50.0, height: 50.0)
    let buttonIconSize: CGSize = CGSize(width: 20.0, height: 20.0)
    let buttonIconTintColor = ThemeManager.shared.currentTheme.colorNumber2()
    let vInset: CGFloat = 50.0
  }
}

//MARK: - GIDSignInUIDelegate Implementation
extension CallToActionViewController: GIDSignInUIDelegate {
  // Stop the UIActivityIndicatorView animation that was started when the user
  // pressed the Sign In button
  func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
    //TODO: Show loader if needed
  }

  // Present a view that prompts the user to sign in with Google
  func sign(_ signIn: GIDSignIn!,
            present viewController: UIViewController!) {
    present(viewController, animated: true, completion: nil)
  }

  // Dismiss the "Sign in with Google" view
  func sign(_ signIn: GIDSignIn!,
            dismiss viewController: UIViewController!) {
    viewController.dismiss(animated: true, completion: nil)
  }
}

