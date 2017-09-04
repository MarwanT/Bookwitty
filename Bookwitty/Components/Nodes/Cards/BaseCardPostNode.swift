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

extension BaseCardPostNode: CommentCompactNodeDelegate {
  func commentCompactNodeDidTap(_ node: CommentCompactNode) {

    delegate?.cardNode(card: self, didRequestAction: BaseCardPostNode.Action.listComments, from: node)
  }
}

extension BaseCardPostNode: WriteCommentNodeDelegate {
  func writeCommentNodeDidTap(_ writeCommentNode: WriteCommentNode) {

    guard UserManager.shared.isSignedIn else {
      //If user is not signed In post notification and do not fall through
      NotificationCenter.default.post( name: AppNotification.callToAction, object: nil)
      return
    }

    delegate?.cardNode(card: self, didRequestAction: BaseCardPostNode.Action.publishComment, from: writeCommentNode)
  }
}

//MARK: - TagCollectionNodeDelegate implementation
extension BaseCardPostNode: TagCollectionNodeDelegate {
  func tagCollection(node: TagCollectionNode, didSelectItemAt index: Int) {
    delegate?.cardNode(card: self, didSelectTagAt: index)
  }
}

protocol BaseCardPostNodeDelegate: class {
  func cardActionBarNode(card: BaseCardPostNode, cardActionBar: CardActionBarNode, didRequestAction action: CardActionBarNode.Action, forSender sender: ASButtonNode, didFinishAction: ((_ success: Bool) -> ())?)
  func cardInfoNode(card: BaseCardPostNode, cardPostInfoNode: CardPostInfoNode, didRequestAction action: CardPostInfoNode.Action, forSender sender: Any)
  func cardNode(card: BaseCardPostNode, didRequestAction action: BaseCardPostNode.Action, from: ASDisplayNode)
  func cardNode(card: BaseCardPostNode, didSelectTagAt index: Int)
}

class BaseCardPostNode: ASCellNode, NodeTapProtocol {

  enum Action {
    case listComments
    case publishComment
  }

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

  fileprivate let tagCollectionNode: TagCollectionNode

  fileprivate let topCommentNode: CommentCompactNode
  fileprivate let writeCommentNode: WriteCommentNode

  var shouldHandleTopComments: Bool = true {
    didSet {
      actionBarNode.hideCommentButton = !shouldHandleTopComments
    }
  }
  var shouldShowTagsNode: Bool = false

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
          .append(text: actionInfoValue, color: ThemeManager.shared.currentTheme.colorNumber15()).attributedString
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
    topCommentNode = CommentCompactNode()
    writeCommentNode = WriteCommentNode()
    tagCollectionNode = TagCollectionNode()
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

    tagCollectionNode.delegate = self
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

  var topComment: Comment? {
    didSet {
      topCommentNode.set(fullName: topComment?.penName?.name, message: topComment?.body)
      topCommentNode.imageURL = URL(string: topComment?.penName?.avatarUrl ?? "")
      topCommentNode.setNeedsLayout()
    }
  }

  var tags: [String]? {
    didSet {
      tagCollectionNode.set(tags: tags ?? [])
      tagCollectionNode.setNeedsLayout()
    }
  }

  private func setupCellNode() {
    actionBarNode.delegate = self
    infoNode.delegate = self
    topCommentNode.delegate = self
    writeCommentNode.delegate = self
    manageNodes()
    setupCardTheme()
    
    separatorNode.style.height = ASDimensionMake(1)
    separatorNode.style.flexGrow = 1

    writeCommentNode.configuration.imageSize = CGSize(width: 30.0, height: 30.0)
    writeCommentNode.configuration.textContainerInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 5)
    writeCommentNode.configuration.textNodeBorderWidth = 0.0
    writeCommentNode.configuration.placeholderTextColor = ThemeManager.shared.currentTheme.colorNumber15()
    writeCommentNode.style.preferredSize = CGSize(width: 35.0, height: 35.0)
    writeCommentNode.configuration.textNodeMinimumHeight = 30
    writeCommentNode.configuration.externalInsets = UIEdgeInsets.zero
    writeCommentNode.configuration.alignItems = .center
    writeCommentNode.imageURL = URL(string: UserManager.shared.defaultPenName?.avatarUrl ?? "")
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

    let verticalStack = ASStackLayoutSpec.vertical()
    verticalStack.justifyContent = .center
    verticalStack.alignItems = .stretch
    verticalStack.children = []

    if (shouldShowInfoNode && !forceHideInfoNode) {
      verticalStack.children?.append(infoNodeInset)
    }

    verticalStack.children?.append(contentInset)

    if canShowTagsNode && shouldShowTagsNode {
      verticalStack.children?.append(spacer(height: internalMargin / 2.0))
      let tagCollectionNodeInset = ASInsetLayoutSpec(insets: tagsInset(), child: tagCollectionNode)
      verticalStack.children?.append(tagCollectionNodeInset)
    }

    if shouldShowActionInfoNode {
      verticalStack.children?.append(spacer(height: internalMargin / 2.0))
      verticalStack.children?.append(actionInfoNodeInset)
    }

    verticalStack.children?.append(spacer(height: internalMargin / 2.0))

    if shouldShowActionBarNode {
      verticalStack.children?.append(separatorNodeInset)
      verticalStack.children?.append(actionBarNodeInset)
    } else {
      verticalStack.children?.append(ASLayoutSpec.spacer(height: externalInset().bottom))
    }

    if shouldHandleTopComments {
      let commentSeparator = ASDisplayNode()
      commentSeparator.style.height = ASDimensionMake(1)
      commentSeparator.style.flexGrow = 1
      commentSeparator.isLayerBacked = true
      commentSeparator.backgroundColor = ThemeManager.shared.currentTheme.colorNumber18()
      let commentSeparatorNodeInset = ASInsetLayoutSpec(insets: actionBarInset(), child: commentSeparator)
      verticalStack.children?.append(commentSeparatorNodeInset)

      if shouldShowTopCommentNode {
        let topCommentNodeInset = ASInsetLayoutSpec(insets: commentNodeInset(), child: topCommentNode)
        verticalStack.children?.append(topCommentNodeInset)
        verticalStack.children?.append(ASLayoutSpec.spacer(height: externalInset().bottom))
      } else {
        let writeCommentNodeInset = ASInsetLayoutSpec(insets: commentNodeInset(), child: writeCommentNode)
        verticalStack.children?.append(writeCommentNodeInset)
        verticalStack.children?.append(ASLayoutSpec.spacer(height: externalInset().bottom))
      }
    }

    //Note: If we used children or background properties instead of init -> Order would be important,
    //insetForVerticalLayout must be added before backgroundNode
    let layoutSpec = ASBackgroundLayoutSpec(child: verticalStack, background: backgroundNodeInset)

    return layoutSpec
  }


  private func reportedLayoutSpecs() -> ASLayoutSpec {
    let backgroundInset = externalInset()
    let backgroundNodeInset = ASInsetLayoutSpec(insets: backgroundInset, child: backgroundNode)

    let titleNode = ASTextNode()
    titleNode.maximumNumberOfLines = 1
    titleNode.truncationMode = NSLineBreakMode.byTruncatingTail

    let detailsNode = ASTextNode()
    detailsNode.maximumNumberOfLines = 1
    detailsNode.truncationMode = NSLineBreakMode.byTruncatingTail

    let title = "Thank you for your report."
    titleNode.attributedText = AttributedStringBuilder(fontDynamicType: .footnote)
      .append(text: title, color: ThemeManager.shared.currentTheme.colorNumber20()).attributedString

    let details = "You won't see this post in the future."
    detailsNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption2)
      .append(text: details, color: ThemeManager.shared.currentTheme.colorNumber20()).attributedString

    let titleInsetLayoutSpec = ASInsetLayoutSpec(insets: reportTextInset(), child: titleNode)
    let detailsInsetLayoutSpec = ASInsetLayoutSpec(insets: reportTextInset(), child: detailsNode)

    let innerItemsSpacer = spacer(height: internalMargin / 2.0)

    let children: [ASLayoutElement] = [
      titleInsetLayoutSpec, innerItemsSpacer, detailsInsetLayoutSpec
    ]

    let verticalStack = ASStackLayoutSpec(direction: .vertical, spacing: 0.0, justifyContent: .spaceBetween, alignItems: .start, children: children)
    let insetLayoutSpec = ASInsetLayoutSpec(insets: reportInset(), child: verticalStack)

    let layoutSpec = ASBackgroundLayoutSpec(child: insetLayoutSpec, background: backgroundNodeInset)

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

  private func tagsInset() -> UIEdgeInsets {
    let externalInset = self.externalInset()
    return UIEdgeInsets(top: 0,
                        left: externalInset.left,
                        bottom: 0,
                        right: externalInset.right + internalMargin)
  }

  private func actionBarInset() -> UIEdgeInsets {
    let externalInset = self.externalInset()
    return UIEdgeInsets(top: 0,
                        left: externalInset.left,
                        bottom: 0,
                        right: externalInset.right)
  }

  private func commentNodeInset() -> UIEdgeInsets {
    let externalInset = self.internalInset()
    return UIEdgeInsets(top: 5,
                        left: externalInset.left,
                        bottom: 5,
                        right: externalInset.right)
  }

  private func separatorInset() -> UIEdgeInsets {
    let externalInset = self.externalInset()
    return UIEdgeInsets(top: 0,
                        left: externalInset.left + internalMargin,
                        bottom: 0,
                        right: externalInset.right + internalMargin)
  }

  private func reportTextInset() -> UIEdgeInsets {
    return UIEdgeInsets(top:0,
                        left: internalMargin,
                        bottom: 0,
                        right: internalMargin)
  }

  private func reportInset() -> UIEdgeInsets {
    return UIEdgeInsets(top: (externalMargin / 2.0) + internalMargin,
                        left: externalMargin,
                        bottom: (externalMargin / 2.0) + internalMargin,
                        right: externalMargin)
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
  
  internal var canShowTagsNode: Bool {
    return (self.tags?.count ?? 0) > 0
  }

  internal var shouldShowActionBarNode: Bool {
    return true
  }

  internal var shouldShowTopCommentNode: Bool {
    return self.topComment != nil
  }


  internal var contentShouldExtendBorders: Bool {
    return false
  }

  internal var contentNode: ASDisplayNode {
    return ASDisplayNode()
  }

  func updateMode(fullMode: Bool) {
    shouldShowTagsNode = true
  }
}
