//
//  OnBoardingControllerNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/3/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol OnBoardingControllerDataSource {
  func numberOfSections(in collectionNode: ASCollectionNode) -> Int
  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int
  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock
  func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode, at indexPath: IndexPath)
}

protocol OnBoardingControllerDelegate {
  func continueButtonTouchUpInside(_ sender: Any?)
}

class OnBoardingControllerNode: ASDisplayNode {
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let externalMargin = ThemeManager.shared.currentTheme.cardExternalMargin()
  fileprivate let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()
  fileprivate let headerHeight: CGFloat = 45.0

  let titleTextNode: ASTextNode
  let separatorNode: ASDisplayNode
  let collectionNode: ASCollectionNode
  let continueButton: ASButtonNode
  let flowLayout: UICollectionViewFlowLayout

  var delegate: OnBoardingControllerDelegate?
  var dataSource: OnBoardingControllerDataSource!

  override init() {
    titleTextNode = ASTextNode()
    flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    flowLayout.minimumInteritemSpacing  = 0
    flowLayout.minimumLineSpacing       = 0

    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    separatorNode = ASDisplayNode()
    continueButton = ASButtonNode()
    super.init()
    automaticallyManagesSubnodes = true

    style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 0.0)

    collectionNode.delegate = self
    collectionNode.dataSource = self
    collectionNode.style.flexGrow = 1.0
    collectionNode.style.flexShrink = 1.0
    collectionNode.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()

    titleTextNode.style.maxHeight = ASDimensionMake(headerHeight)
    titleTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption1)
      .append(text: Strings.onboarding_view_header_title(), color: ThemeManager.shared.currentTheme.defaultTextColor()).attributedString

    separatorNode.style.height = ASDimensionMake(1.0)
    separatorNode.backgroundColor  = ThemeManager.shared.currentTheme.colorNumber18()
    separatorNode.isLayerBacked = true

    ThemeManager.shared.currentTheme.styleSecondaryButton(button: continueButton)
    continueButton.setTitle(Strings.continue(), with: FontDynamicType.subheadline.font, with: ThemeManager.shared.currentTheme.defaultButtonColor(), for: UIControlState.normal)
    continueButton.setTitle(Strings.continue(), with: FontDynamicType.subheadline.font, with: ThemeManager.shared.currentTheme.defaultButtonHighlightedColor(), for: UIControlState.highlighted)
    continueButton.style.height = ASDimensionMake(44.0)
    continueButton.addTarget(self, action: #selector(continueButtonTouchUpInside), forControlEvents: ASControlNodeEvent.touchUpInside)
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let titleCenterSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: ASCenterLayoutSpecSizingOptions(rawValue: 0), child: titleTextNode)
    let titleInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: internalMargin, left: internalMargin, bottom: internalMargin, right: internalMargin), child: titleCenterSpec)

    let buttonInset = ASInsetLayoutSpec(insets: UIEdgeInsets(top: externalMargin, left: internalMargin, bottom: externalMargin, right: internalMargin), child: continueButton)

    let vStack = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .start,
                                   alignItems: .stretch, children: [titleInsetSpec, separatorNode, collectionNode,  buttonInset])
    return vStack
  }

  func continueButtonTouchUpInside(sender: Any?) {
    delegate?.continueButtonTouchUpInside(sender)
  }
}

extension OnBoardingControllerNode {
  func reloadCollection() {
    collectionNode.reloadData()
  }
}

extension OnBoardingControllerNode: ASCollectionDelegate, ASCollectionDataSource {
  func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return dataSource.numberOfSections(in: collectionNode)
  }

  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    return dataSource.collectionNode(collectionNode, numberOfItemsInSection: section)
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    return dataSource.collectionNode(collectionNode, nodeBlockForItemAt: indexPath)
  }

  func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
    guard let indexPath = collectionNode.indexPath(for: node) else {
      return
    }
    dataSource.collectionNode(collectionNode, willDisplayItemWith: node, at: indexPath)
  }

  public func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
    return ASSizeRange(
      min: CGSize(width: collectionNode.frame.width, height: 0.0),
      max: CGSize(width: collectionNode.frame.width, height: .infinity)
    )
  }

  func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
    if let cell = collectionNode.nodeForItem(at: indexPath) as? OnBoardingCellNode {
      cell.updateViewState(state: cell.showAll ? OnBoardingCellNode.State.collapsed : OnBoardingCellNode.State.expanded)
    }
  }
}
