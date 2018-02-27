//
//  CompactPenNameNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/23/18.
//  Copyright © 2018 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol CompactPenNameNodeDelegate: class {
  func penName(node: CompactPenNameNode, actionPenNameFollowTouchUpInside button: Any?)
  func penName(node: CompactPenNameNode, requestToViewImage image: UIImage, from imageNode: ASNetworkImageNode)
}

class CompactPenNameNode: ASCellNode {
  private let cellHeight: CGFloat = 64.0
  private let imageSize: CGSize = CGSize(width: 64.0, height: 64.0)
  private let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  private let nameNode: ASTextNode
  private let dateNode: ASTextNode
  private let imageNode: ASNetworkImageNode

  weak var delegate: CompactPenNameNodeDelegate?

  var penName: String? {
    didSet {
      if let penName = penName {
        nameNode.attributedText = AttributedStringBuilder(fontDynamicType: .subheadline)
          .append(text: penName, color: ThemeManager.shared.currentTheme.colorNumber19()).attributedString
        setNeedsLayout()
      }
    }
  }

  var date: String? {
    didSet {
      if let date = date {
        dateNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption1)
          .append(text: date, color: ThemeManager.shared.currentTheme.defaultGrayedTextColor()).attributedString
        setNeedsLayout()
      }
    }
  }

  var imageUrl: String? {
    didSet {
      if let imageUrl = imageUrl {
        imageNode.url = URL(string: imageUrl)
        setNeedsLayout()
      }
    }
  }

  override init() {
    imageNode = ASNetworkImageNode()
    nameNode = ASTextNode()
    dateNode = ASTextNode()
    super.init()
    automaticallyManagesSubnodes = true
    setup()
  }

  private func setup() {
    //Style
    backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
    style.height = ASDimensionMake(cellHeight)
    style.width = ASDimensionMake(UIScreen.main.bounds.width)

    imageNode.style.preferredSize = imageSize
    imageNode.defaultImage = ThemeManager.shared.currentTheme.penNamePlaceholder
    imageNode.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(0.0, nil)
    imageNode.animatedImageRunLoopMode = RunLoopMode.defaultRunLoopMode.rawValue
    imageNode.animatedImagePaused = true

    nameNode.maximumNumberOfLines = 2
    nameNode.truncationMode = NSLineBreakMode.byTruncatingTail

    dateNode.maximumNumberOfLines = 1
    dateNode.truncationMode = NSLineBreakMode.byTruncatingTail

    //Actions
    nameNode.addTarget(self, action: #selector(actionPenNameFollowTouchUpInside(_:)), forControlEvents: ASControlNodeEvent.touchUpInside)
    imageNode.addTarget(self, action: #selector(imageNodeTouchUpInside(sender:)), forControlEvents: ASControlNodeEvent.touchUpInside)
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let rightVerticalStack = ASStackLayoutSpec(direction: .vertical,
                                          spacing: internalMargin/3,
                                          justifyContent: .center,
                                          alignItems: .stretch,
                                          children: [nameNode, dateNode])
    rightVerticalStack.style.flexShrink = 1.0
    rightVerticalStack.style.flexGrow = 1.0

    let leftVerticalStack = ASStackLayoutSpec(direction: .vertical,
                                          spacing: 0,
                                          justifyContent: .center,
                                          alignItems: .stretch,
                                          children: [imageNode])

    let horizontalStackSpec = ASStackLayoutSpec(direction: .horizontal,
                                                spacing: internalMargin,
                                                justifyContent: .spaceBetween,
                                                alignItems: .stretch,
                                                children: [leftVerticalStack, rightVerticalStack])

    return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: internalMargin, bottom: 0, right: internalMargin), child:  horizontalStackSpec)
  }
}

//Actions
extension CompactPenNameNode {
  func actionPenNameFollowTouchUpInside(_ sender: Any?) {
    delegate?.penName(node: self, actionPenNameFollowTouchUpInside: sender)
  }
}

extension CompactPenNameNode: ASNetworkImageNodeDelegate {
  @objc
  fileprivate func imageNodeTouchUpInside(sender: ASNetworkImageNode) {
    guard let image = sender.image else {
      delegate?.penName(node: self, actionPenNameFollowTouchUpInside: sender)
      return
    }

    delegate?.penName(node: self, requestToViewImage: image, from: sender)
  }
}
