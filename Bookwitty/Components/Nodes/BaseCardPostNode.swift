//
//  BaseCardPostNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/12/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol BaseCardPostNodeContentProvider {
  var shouldShowInfoNode: Bool { get }
  var contentShouldExtendBorders: Bool { get }
  var contentNode: ASDisplayNode { get }
}

class BaseCardPostNode: ASCellNode {

  let externalMargin = ThemeManager.shared.currentTheme.cardExternalMargin()
  let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  let witItButtonMargin = ThemeManager.shared.currentTheme.witItButtonMargin()

  private(set) var infoNode: CardPostInfoNode
  private(set) var actionBarNode: CardActionBarNode
  private(set) var backgroundNode: ASDisplayNode

  var postInfoData: CardPostInfoNodeData? {
    didSet {
      infoNode.data = postInfoData
    }
  }

  override init() {
    infoNode = CardPostInfoNode()
    actionBarNode = CardActionBarNode(delegate: nil)
    backgroundNode = ASDisplayNode()
    super.init()
    setupCellNode()
  }

  private func setupCellNode() {
    manageNodes()
    setupCardTheme()
  }

  private func manageNodes() {
    guard subnodes.count == 0 else { return }

    //Order is important: backgroundNode must be the first
    if(shouldShowInfoNode) {
      addSubnodes(arrayOfNodes: [backgroundNode, infoNode, contentNode, actionBarNode])
    } else {
      addSubnodes(arrayOfNodes: [backgroundNode, contentNode, actionBarNode])
    }
  }

  private func addSubnodes(arrayOfNodes: [ASDisplayNode]) {
    arrayOfNodes.forEach { (node) in
      addSubnode(node)
    }
  }

  private func setupCardTheme() {
    backgroundNode.clipsToBounds = true
    backgroundNode.borderWidth = 1.0
    backgroundNode.borderColor = ThemeManager.shared.currentTheme.colorNumber18().cgColor
    backgroundNode.cornerRadius = 4.0
    backgroundNode.backgroundColor = ThemeManager.shared.currentTheme.colorNumber23()
  }
}

//MARK: - Layout Sizing
extension BaseCardPostNode {

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let backgroundInset = externalInset()
    let defaultInset = internalInset()

    let infoNodeInset = ASInsetLayoutSpec(insets: infoInset(), child: infoNode)
    let actionBarNodeInset = ASInsetLayoutSpec(insets: actionBarInset(), child: actionBarNode)
    let backgroundNodeInset = ASInsetLayoutSpec(insets: backgroundInset, child: backgroundNode)

    let contentSideInsets = contentShouldExtendBorders ? 0 : defaultInset.left
    let contentTopInset = shouldShowInfoNode ? 0 : defaultInset.top
    let contentInset = ASInsetLayoutSpec(insets: UIEdgeInsets(top: contentTopInset, left: contentSideInsets, bottom: 0, right: contentSideInsets), child: contentNode)

    let verticalStack = ASStackLayoutSpec.vertical()
    verticalStack.justifyContent = .center
    verticalStack.alignItems = .stretch
    verticalStack.children = shouldShowInfoNode
      ? [infoNodeInset, contentInset, actionBarNodeInset]
      : [contentInset, actionBarNodeInset]

    //Note: If we used children or background properties instead of init -> Order would be important,
    //insetForVerticalLayout must be added before backgroundNode
    let layoutSpec = ASBackgroundLayoutSpec(child: verticalStack, background: backgroundNodeInset)

    return layoutSpec
  }

  /**
   * Note:
   *  Top and Bottom margins are divided by 2 since cards are stacked after each other vertically.
   *  This means that one card's bottom is the other one's top.
   *  So to overcome margin space stacking:
   *    1. We made each card have only half the margin it needs to the top and bottom
   *  This leaves only the First [index = 0] cell missing half top margin
   *  And the last cell [index = last] missing half the bottom margin
   *    2. We use UICollectionViewFlowLayout sectionInset (top: externalMargin/2, left: 0, bottom: externalMargin/2, right: 0)
   *  This in turn will add space before the first card and after the last card.
   */
  private func externalInset() -> UIEdgeInsets {
    return UIEdgeInsets(top: externalMargin/2, left: externalMargin, bottom: externalMargin/2, right: externalMargin)
  }

  /**
   * Note:
   *  According to the Design specs: Card Spacing internal margin is not applied to the bottom inset
   */
  private func internalInset() -> UIEdgeInsets {
    let externalInset = self.externalInset()
    return UIEdgeInsets(top: externalInset.top + internalMargin,
                        left: externalInset.left + internalMargin,
                        bottom: externalInset.bottom ,
                        right: externalInset.right + internalMargin)
  }

  private func infoInset() -> UIEdgeInsets {
    let externalInset = self.externalInset()
    return UIEdgeInsets(top: externalInset.top + internalMargin,
                        left: externalInset.left + internalMargin,
                        bottom: internalMargin,
                        right: externalInset.right + internalMargin)
  }

  private func actionBarInset() -> UIEdgeInsets {
    let externalInset = self.externalInset()
    return UIEdgeInsets(top: witItButtonMargin,
                        left: externalInset.left + internalMargin,
                        bottom: externalInset.bottom + witItButtonMargin,
                        right: externalInset.right + internalMargin)
  }
}

//MARK: - Default Content Card Setup
extension BaseCardPostNode: BaseCardPostNodeContentProvider {
  internal var shouldShowInfoNode: Bool {
    return true
  }

  internal var contentShouldExtendBorders: Bool {
    return false
  }

  internal var contentNode: ASDisplayNode {
    return ASDisplayNode()
  }
}
