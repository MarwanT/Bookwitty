//
//  BaseCardPostNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/12/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol CardViewModelProtocol: class {
  var resource: ModelCommonProperties? { get set }
}

extension CardViewModelProtocol {
  var resource: ModelCommonProperties? {
    return nil
  }
}

protocol BaseCardPostNodeContentProvider {
  var shouldShowInfoNode: Bool { get }
  var shouldShowActionInfoNode: Bool { get }
  var shouldShowActionBarNode: Bool { get }
  var contentShouldExtendBorders: Bool { get }
  var contentNode: ASDisplayNode { get }

  func updateMode(fullMode: Bool)
}

extension BaseCardPostNode: CardActionBarNodeDelegate {
  func cardActionBarNode(cardActionBar: CardActionBarNode, didRequestAction action: CardActionBarNode.Action, forSender sender: ASButtonNode, didFinishAction: ((_ success: Bool) -> ())?) {
    delegate?.cardActionBarNode(card: self, cardActionBar: cardActionBar, didRequestAction: action, forSender: sender, didFinishAction: didFinishAction)
  }
}

extension BaseCardPostNode: CardPostInfoNodeDelegate {
  func cardInfoNode(cardPostInfoNode: CardPostInfoNode, didRequestAction action: CardPostInfoNode.Action, forSender sender: Any) {
    delegate?.cardInfoNode(card: self, cardPostInfoNode: cardPostInfoNode, didRequestAction: action, forSender: sender)
  }
}

protocol BaseCardPostNodeDelegate: class {
  func cardActionBarNode(card: BaseCardPostNode, cardActionBar: CardActionBarNode, didRequestAction action: CardActionBarNode.Action, forSender sender: ASButtonNode, didFinishAction: ((_ success: Bool) -> ())?)
  func cardInfoNode(card: BaseCardPostNode, cardPostInfoNode: CardPostInfoNode, didRequestAction action: CardPostInfoNode.Action, forSender sender: Any)
}

class BaseCardPostNode: ASCellNode, NodeTapProtocol {

  var baseViewModel: CardViewModelProtocol? {
    return nil
  }

  fileprivate let externalMargin = ThemeManager.shared.currentTheme.cardExternalMargin()
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let witItButtonMargin = ThemeManager.shared.currentTheme.witItButtonMargin()
  fileprivate let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()

  fileprivate let infoNode: CardPostInfoNode
  fileprivate let actionInfoNode: ASTextNode
  fileprivate let actionBarNode: CardActionBarNode
  fileprivate let backgroundNode: ASDisplayNode
  fileprivate let separatorNode: ASDisplayNode
  fileprivate let commentsSummaryNode: ASTextNode

  fileprivate var shouldShowCommentSummaryNode: Bool {
    return !articleCommentsSummary.isEmptyOrNil()
  }

  weak var tapDelegate: ItemNodeTapDelegate?
  weak var delegate: BaseCardPostNodeDelegate?
  var forceHideInfoNode: Bool = false
  var postInfoData: CardPostInfoNodeData? {
    didSet {
      infoNode.data = postInfoData
      forceHideInfoNode = postInfoData == nil
      setNeedsLayout()
    }
  }

  var actionInfoValue: String? {
    didSet {
      if let actionInfoValue = actionInfoValue {
        actionInfoNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption2)
          .append(text: actionInfoValue, color: ThemeManager.shared.currentTheme.defaultTextColor()).attributedString
      } else {
        actionInfoNode.attributedText = nil
      }

      actionInfoNode.setNeedsLayout()
    }
  }

  var articleCommentsSummary: String? {
    didSet {
      if let articleCommentsSummary = articleCommentsSummary {
        commentsSummaryNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption2)
          .append(text: articleCommentsSummary, color: ThemeManager.shared.currentTheme.colorNumber15()).attributedString
      }
    }
  }

  override init() {
    infoNode = CardPostInfoNode()
    actionInfoNode = ASTextNode()
    actionBarNode = CardActionBarNode()
    backgroundNode = ASDisplayNode()
    separatorNode = ASDisplayNode()
    commentsSummaryNode = ASTextNode()
    super.init()
    setupCellNode()
  }

  override func didLoad() {
    super.didLoad()
    if tapDelegate != nil {
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapOnView(_:)))
      view.addGestureRecognizer(tapGesture)
    }

    actionInfoNode.addTarget(self, action: #selector(actionInfoNodeTouchUpInside(_:)), forControlEvents: .touchUpInside)
  }

  func didTapOnView(_ sender: Any?) {
    tapDelegate?.didTapOn(node: self)
  }


  func setup(forFollowingMode followingMode: Bool) {
    self.actionBarNode.setup(forFollowingMode: followingMode)
  }

  func setFollowingValue(following: Bool) {
    actionBarNode.setFollowingValue(following: following)
  }

  func setWitValue(witted: Bool) {
    actionBarNode.setWitButton(witted: witted)
  }

  func setTopComment(comment: Comment?) {

  }

  private func setupCellNode() {
    actionBarNode.delegate = self
    infoNode.delegate = self
    manageNodes()
    setupCardTheme()
    
    separatorNode.style.height = ASDimensionMake(1)
    separatorNode.style.flexGrow = 1
  }

  private func manageNodes() {
    guard subnodes.count == 0 else { return }
    automaticallyManagesSubnodes = true
    
    separatorNode.isLayerBacked = true
    backgroundNode.isLayerBacked = true
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
    backgroundNode.backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
    //Separator
    separatorNode.backgroundColor  = ThemeManager.shared.currentTheme.colorNumber18()
  }
}

//MARK: - Layout Sizing
extension BaseCardPostNode {  

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let backgroundInset = externalInset()
    let defaultInset = internalInset()

    let infoNodeInset = ASInsetLayoutSpec(insets: infoInset(), child: infoNode)
    let actionInfoNodeInset = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: defaultInset.left, bottom: defaultInset.bottom, right: defaultInset.right), child: actionInfoNode)
    let actionBarNodeInset = ASInsetLayoutSpec(insets: actionBarInset(), child: actionBarNode)
    let backgroundNodeInset = ASInsetLayoutSpec(insets: backgroundInset, child: backgroundNode)
    let separatorNodeInset = ASInsetLayoutSpec(insets: separatorInset(), child: separatorNode)

    let contentSideInsets = contentShouldExtendBorders ? 0 : defaultInset.left
    let contentTopInset = (shouldShowInfoNode && !forceHideInfoNode) ? 0 : defaultInset.top
    let contentInset = ASInsetLayoutSpec(insets: UIEdgeInsets(top: contentTopInset, left: contentSideInsets, bottom: 0, right: contentSideInsets), child: contentNode)

    let commentSummaryInset: ASLayoutElement = shouldShowCommentSummaryNode ? commentSummaryLayoutSpecs() : spacer(height: internalMargin)

    let verticalStack = ASStackLayoutSpec.vertical()
    verticalStack.justifyContent = .center
    verticalStack.alignItems = .stretch
    verticalStack.children = (shouldShowInfoNode && !forceHideInfoNode)
      ? [infoNodeInset, contentInset, commentSummaryInset]
      : [contentInset, commentSummaryInset]

    if shouldShowActionInfoNode {
      verticalStack.children?.append(actionInfoNodeInset)
    }

    if shouldShowActionBarNode {
      verticalStack.children?.append(separatorNodeInset)
      verticalStack.children?.append(actionBarNodeInset)
    } else {
      verticalStack.children?.append(ASLayoutSpec.spacer(height: actionBarInset().bottom))
    }

    //Note: If we used children or background properties instead of init -> Order would be important,
    //insetForVerticalLayout must be added before backgroundNode
    let layoutSpec = ASBackgroundLayoutSpec(child: verticalStack, background: backgroundNodeInset)

    return layoutSpec
  }

  private func commentSummaryLayoutSpecs() -> ASStackLayoutSpec {
    let contentSideInsets = internalInset().left
    let commentSummarySideSpace = shouldShowCommentSummaryNode ? contentSideInsets : 0
    let commentSummaryInset = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: commentSummarySideSpace, bottom: 0, right: commentSummarySideSpace), child: commentsSummaryNode)

    let commentSummaryVerticalStack = ASStackLayoutSpec(direction: .vertical,
                                                        spacing: 0,
                                                        justifyContent: .start,
                                                        alignItems: .stretch,
                                                        children: [spacer(height: contentSpacing), commentSummaryInset, spacer(height: contentSpacing)])
    return commentSummaryVerticalStack
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
    return UIEdgeInsets(top: externalInset.top,
                        left: externalInset.left,
                        bottom: 0,
                        right: externalInset.right)
  }

  private func actionBarInset() -> UIEdgeInsets {
    let externalInset = self.externalInset()
    return UIEdgeInsets(top: 0,
                        left: externalInset.left,
                        bottom: externalInset.bottom ,
                        right: externalInset.right)
  }

  private func separatorInset() -> UIEdgeInsets {
    let externalInset = self.externalInset()
    return UIEdgeInsets(top: 0,
                        left: externalInset.left + internalMargin,
                        bottom: 0,
                        right: externalInset.right + internalMargin)
  }

  private func spacer(height: CGFloat = 0, width: CGFloat = 0) -> ASLayoutSpec {
    return ASLayoutSpec().styled { (style) in
      style.height = ASDimensionMake(height)
      style.width = ASDimensionMake(width)
    }
  }
}

//MARK: - Actions
extension BaseCardPostNode {
  @objc
  fileprivate func actionInfoNodeTouchUpInside(_ sender: ASTextNode) {
    delegate?.cardInfoNode(card: self, cardPostInfoNode: infoNode, didRequestAction: .actionInfo, forSender: sender)
  }
}

//MARK: - Default Content Card Setup
extension BaseCardPostNode: BaseCardPostNodeContentProvider {
  internal var shouldShowInfoNode: Bool {
    return true
  }

  internal var shouldShowActionInfoNode: Bool {
    return self.actionInfoValue != nil
  }
  
  internal var shouldShowActionBarNode: Bool {
    return true
  }

  internal var contentShouldExtendBorders: Bool {
    return false
  }

  internal var contentNode: ASDisplayNode {
    return ASDisplayNode()
  }

  func updateMode(fullMode: Bool) {
    //Override in child
  }
}
