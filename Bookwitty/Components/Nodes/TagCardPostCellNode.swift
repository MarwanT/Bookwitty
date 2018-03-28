//
//  TagCardPostCellNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/28/18.
//  Copyright © 2018 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class TagCardPostCellNode: BaseCardPostNode {
  let node: TagCardPostContentNode
  var showsInfoNode: Bool = false
  override var shouldShowInfoNode: Bool { return showsInfoNode }
  override var contentShouldExtendBorders: Bool { return false }
  override var contentNode: ASDisplayNode { return node }

  //TODO: define the view model
  override var baseViewModel: CardViewModelProtocol? {
    //TODO: return view model
    return nil
  }

  override init() {
    node = TagCardPostContentNode()
    //TODO: Initialize View model
    super.init()
    shouldHandleTopComments = true
    //TODO: Set View model delegate
  }

  convenience init(shouldShowInfoNode: Bool) {
    self.init()
    showsInfoNode = shouldShowInfoNode
  }
}

class TagCardPostContentNode: ASDisplayNode {
  private let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  private let headerHeight: CGFloat = 70.0
  private let profileImageSize: CGSize = CGSize(width: 70.0, height: 70.0)

  private var iconImageNode: ASImageNode
  private var titleTextNode: ASTextNode
  private var followersTextNode: ASTextNode

  var title: String? {
    didSet {
      if let title = title {
        titleTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .title2)
          .append(text: title, color: ThemeManager.shared.currentTheme.defaultTextColor()).attributedString
      } else {
        titleTextNode.attributedText = nil
      }
      titleTextNode.setNeedsLayout()
    }
  }

  var followersCount: String? {
    didSet {
      if let followersCount = followersCount, let number: Int = Int(followersCount) {
        followersTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .footnote)
          .append(text: Strings.followers(number: number), fontDynamicType: .caption2)
          .attributedString
      } else {
        followersTextNode.attributedText = nil
      }
      followersTextNode.setNeedsLayout()
    }
  }

  override init() {
    iconImageNode = ASImageNode()
    titleTextNode = ASTextNode()
    followersTextNode = ASTextNode()
    super.init()
    automaticallyManagesSubnodes = true
    setupNodes()
  }

  func setupNodes() {
    titleTextNode.maximumNumberOfLines = 1
    followersTextNode.maximumNumberOfLines = 1

    titleTextNode.truncationMode = NSLineBreakMode.byTruncatingTail
    followersTextNode.truncationMode = NSLineBreakMode.byTruncatingTail

    let profileBorderWidth: CGFloat = 0.0
    let profileBorderColor: UIColor? = nil
    iconImageNode.style.preferredSize = profileImageSize
    iconImageNode.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(profileBorderWidth, profileBorderColor)
    iconImageNode.image = #imageLiteral(resourceName: "tag")
  }

  private func isValid(_ value: String?) -> Bool {
    return !value.isEmptyOrNil()
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    var verticalChildNodes: [ASLayoutElement] = []
    verticalChildNodes.append(titleTextNode)
    if (isValid(followersCount)) {
      verticalChildNodes.append(ASLayoutSpec.spacer(height: 5.0))
      verticalChildNodes.append(followersTextNode)
    }

    let verticalChildStack = ASStackLayoutSpec(direction: .vertical,
                                               spacing: 0,
                                               justifyContent: .center,
                                               alignItems: .start,
                                               children: verticalChildNodes)
    verticalChildStack.style.height = ASDimensionMake(headerHeight)
    verticalChildStack.style.flexShrink = 1.0

    let horizontalStackSpec = ASStackLayoutSpec(direction: .horizontal,
                                                spacing: internalMargin,
                                                justifyContent: .start,
                                                alignItems: .stretch,
                                                children: [iconImageNode, verticalChildStack])

    let verticalParentNodes: [ASLayoutElement] = [horizontalStackSpec]

    let verticalParentStackSpec = ASStackLayoutSpec(direction: .vertical,
                                                    spacing: internalMargin,
                                                    justifyContent: .start,
                                                    alignItems: .stretch,
                                                    children: verticalParentNodes)

    return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: verticalParentStackSpec)
  }
}
