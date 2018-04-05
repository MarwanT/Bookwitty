//
//  CallToActionViewController.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2018/04/03.
//  Copyright © 2018 Keeward. All rights reserved.
//

import AsyncDisplayKit

class CallToActionViewController: ASViewController<ASDisplayNode> {

  fileprivate let controllerNode = ASDisplayNode()

  fileprivate let backgroundNode = ASDisplayNode()
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
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
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
