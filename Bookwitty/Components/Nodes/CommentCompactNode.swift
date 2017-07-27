//
//  CommentCompactNode.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 6/29/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import DTCoreText

protocol CommentCompactNodeDelegate: class {
  func commentCompactNodeDidTap(_ node: CommentCompactNode)
}

class CommentCompactNode: ASCellNode {
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()

  fileprivate let imageNode: ASNetworkImageNode
  fileprivate let messageNode: DTAttributedLabelNode
  fileprivate let overlayNode: ASControlNode

  var delegate: CommentCompactNodeDelegate?

  override init() {
    imageNode = ASNetworkImageNode()
    messageNode = DTAttributedLabelNode()
    overlayNode = ASControlNode()
    super.init()
    setupNode()
  }

  fileprivate func setupNode() {
    automaticallyManagesSubnodes = true

    imageNode.style.preferredSize = CGSize(width: 30.0, height: 30.0)
    imageNode.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(0.0, nil)
    imageNode.defaultImage = ThemeManager.shared.currentTheme.penNamePlaceholder

    messageNode.backgroundColor = UIColor.clear

    messageNode.style.flexGrow = 1.0
    messageNode.style.flexShrink = 1.0

    self.style.preferredSize = CGSize(width: 45.0, height: 45.0)

    messageNode.maxNumberOfLines = 3

    overlayNode.addTarget(self, action: #selector(nodeTouchUpInside(_:)), forControlEvents: .touchUpInside)
  }

  // MARK: Data Setters
  var imageURL: URL?  {
    didSet {
      imageNode.url = imageURL
      imageNode.setNeedsLayout()
    }
  }

  func set(fullName: String?, message: String?) {
    guard let fullName = fullName, let message = message else {
      messageNode.set(attributedString: NSAttributedString(string: ""))
      messageNode.setNeedsLayout()
      return
    }

    let fullNameAttributedString = AttributedStringBuilder(fontDynamicType: .footnote)
      .append(text: fullName, color: ThemeManager.shared.currentTheme.defaultTextColor())
      .append(text: ": ")
      .attributedString

    let commentAttributedString = messageNode.htmlAttributedString(text: message, fontDynamicType: .body, color: ThemeManager.shared.currentTheme.defaultTextColor())
      ?? NSAttributedString(string: message)

    let attributedString: NSMutableAttributedString = NSMutableAttributedString(attributedString: fullNameAttributedString)
    attributedString.append(commentAttributedString)
    messageNode.set(attributedString: attributedString)
    messageNode.setNeedsLayout()
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let imageNodeInsetSpec = ASInsetLayoutSpec(insets: imageInset, child: imageNode)
    let messageNodeInsetSpec = ASInsetLayoutSpec(insets: messageInset, child: messageNode)
    messageNodeInsetSpec.style.flexGrow = 1.0
    messageNodeInsetSpec.style.flexShrink = 1.0
    let horizontalSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 0, justifyContent: .start, alignItems: .center, children: [imageNodeInsetSpec, messageNodeInsetSpec])
    return ASOverlayLayoutSpec(child: horizontalSpec, overlay: overlayNode)
  }

  var imageInset: UIEdgeInsets {
    return UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
  }

  var messageInset: UIEdgeInsets {
    return UIEdgeInsets(top: 0.0, left: 5.0, bottom: 0.0, right: 5.0)
  }
}

// MARK: Actions
extension CommentCompactNode {
  @objc
  fileprivate func nodeTouchUpInside(_ sender: Any) {    
    delegate?.commentCompactNodeDidTap(self)
  }
}
