//
//  PostDetailsNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/9/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import DTCoreText

extension PostDetailsNode: DTAttributedTextContentNodeDelegate {
  func attributedTextContentNodeNeedsLayout(node: ASCellNode) {
    setNeedsLayout()
  }

  func attributedTextContentNode(node: ASCellNode, button: DTLinkButton, didTapOnLink link: URL) {
    WebViewController.present(url: link)
  }
}

extension PostDetailsNode: DisclosureNodeDelegate {
  func disclosureNodeDidTap(disclosureNode: DisclosureNode, selected: Bool) {
    if disclosureNode === postItemsNodeViewAll {
      //Post Items View All
      delegate?.shouldShowPostDetailsAllPosts()
    } else if disclosureNode === relatedBooksViewAllNode {
      //Related Books View All
      delegate?.shouldShowPostDetailsAllRelatedBooks()
    } else if disclosureNode === relatedPostsViewAllNode {
      //Related Posts View All
      delegate?.shouldShowPostDetailsAllRelatedPosts()
    }
  }
}

protocol PostDetailsNodeDelegate: class {
  func bannerTapAction(url: URL?)
  func shouldShowPostDetailsAllPosts()
  func shouldShowPostDetailsAllRelatedBooks()
  func shouldShowPostDetailsAllRelatedPosts()
  func hasRelatedPosts() -> Bool
  func hasRelatedBooks() -> Bool
  func hasContentItems() -> Bool
  func cardActionBarNode(cardActionBar: CardActionBarNode, didRequestAction action: CardActionBarNode.Action, forSender sender: ASButtonNode, didFinishAction: ((_ success: Bool) -> ())?)
  func postDetails(node: PostDetailsNode, requestToViewImage image: UIImage, from imageNode: ASNetworkImageNode)
  func postDetails(node: PostDetailsNode, didRequestActionInfo fromNode: ASTextNode)
  func commentsNode(_ commentsNode: CommentsNode, reactFor action: CommentsNode.Action, didFinishAction: ((_ success: Bool) -> ())?)
  func postDetails(node: PostDetailsNode, didSelectTagAt index: Int)
}

class PostDetailsNode: ASScrollNode {
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()
  fileprivate let horizontalCollectionNodeHeight: CGFloat = RelatedBooksMinimalCellNode.cellHeight


  fileprivate let descriptionNode: DTAttributedTextContentNode
  fileprivate let tagCollectionNode: TagCollectionNode
  fileprivate let separator: SeparatorNode
  fileprivate let conculsionNode: DTAttributedTextContentNode
  fileprivate let postItemsNodeLoader: LoaderNode
  fileprivate let postItemsSeparator: SeparatorNode
  fileprivate let postItemsNodeViewAll: DisclosureNode
  fileprivate let booksHorizontalFlowLayout: UICollectionViewFlowLayout
  fileprivate let sectionTitleHeaderNode: SectionTitleHeaderNode
  fileprivate let relatedBooksViewAllNode: DisclosureNode
  fileprivate let relatedBooksTopSeparator: SeparatorNode
  fileprivate let relatedBooksSeparator: SeparatorNode
  fileprivate let relatedBooksNodeLoader: LoaderNode
  fileprivate let relatedPostsSectionTitleHeaderNode: SectionTitleHeaderNode
  fileprivate let relatedPostsViewAllNode: DisclosureNode
  fileprivate let relatedPostsTopSeparator: SeparatorNode
  fileprivate let relatedPostsBottomSeparator: SeparatorNode
  fileprivate let relatedPostsNodeLoader: LoaderNode
  fileprivate let bannerImageNode: ASImageNode
  let commentsNode: CommentsNode

  let headerNode: PostDetailsHeaderNode
  let postItemsNode: PostDetailsItemNode
  let postCardsNode: PostDetailsItemNode
  let booksHorizontalCollectionNode: ASCollectionNode

  var title: String? {
    didSet {
      headerNode.title = title
    }
  }
  var coverImage: String? {
    didSet {
        headerNode.image = coverImage
    }
  }
  var body: String? {
    didSet {
      if let body = body {
        descriptionNode.htmlString(text: body, fontDynamicType: FontDynamicType.body)
      }
    }
  }
  var date: String? {
    didSet {
      headerNode.date = date
    }
  }
  var penName: PenName? {
    didSet {
      headerNode.penName = penName
    }
  }

  var tags: [String]? {
    didSet {
      tagCollectionNode.set(tags: tags ?? [])
      if isNodeLoaded {
        setNeedsLayout()
      }
    }
  }

  var actionInfoValue: String? {
    didSet {
      headerNode.actionInfoValue = actionInfoValue
    }
  }

  weak var delegate: PostDetailsNodeDelegate?
  var conculsion: String? {
    didSet {
        conculsionNode.htmlString(text: conculsion, fontDynamicType: FontDynamicType.body)
    }
  }
  var showPostsLoader: Bool = false {
    didSet {
      if isNodeLoaded {
        setNeedsLayout()
      }
    }
  }
  var showCommentNode: Bool = true
  var showRelatedPostsLoader: Bool = false {
    didSet {
      if isNodeLoaded {
        setNeedsLayout()
      }
    }
  }
  var showRelatedBooksLoader: Bool = false {
    didSet {
      if isNodeLoaded {
        setNeedsLayout()
      }
    }
  }

  override init(viewBlock: @escaping ASDisplayNodeViewBlock, didLoad didLoadBlock: ASDisplayNodeDidLoadBlock? = nil) {
    headerNode = PostDetailsHeaderNode()
    descriptionNode = DTAttributedTextContentNode()
    tagCollectionNode = TagCollectionNode()
    postItemsNode = PostDetailsItemNode()
    separator = SeparatorNode()
    conculsionNode = DTAttributedTextContentNode()
    postItemsNodeLoader = LoaderNode()
    postItemsNodeViewAll = DisclosureNode()
    booksHorizontalFlowLayout = UICollectionViewFlowLayout()
    booksHorizontalFlowLayout.scrollDirection = .horizontal
    booksHorizontalFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: internalMargin, bottom: 0, right: internalMargin)
    booksHorizontalFlowLayout.minimumInteritemSpacing  = 0
    booksHorizontalFlowLayout.minimumLineSpacing       = internalMargin
    booksHorizontalCollectionNode = ASCollectionNode(collectionViewLayout: booksHorizontalFlowLayout)
    sectionTitleHeaderNode = SectionTitleHeaderNode()
    postItemsSeparator = SeparatorNode()
    relatedBooksViewAllNode = DisclosureNode()
    relatedBooksSeparator = SeparatorNode()
    relatedBooksTopSeparator = SeparatorNode()
    postCardsNode = PostDetailsItemNode()
    relatedPostsSectionTitleHeaderNode = SectionTitleHeaderNode()
    relatedPostsViewAllNode = DisclosureNode()
    relatedPostsTopSeparator = SeparatorNode()
    relatedPostsBottomSeparator = SeparatorNode()
    relatedPostsNodeLoader = LoaderNode()
    relatedBooksNodeLoader = LoaderNode()
    bannerImageNode = ASImageNode()
    commentsNode = CommentsNode()
    super.init(viewBlock: viewBlock, didLoad: didLoadBlock)
  }

  override init() {
    headerNode = PostDetailsHeaderNode()
    descriptionNode = DTAttributedTextContentNode()
    tagCollectionNode = TagCollectionNode()
    postItemsNode = PostDetailsItemNode()
    separator = SeparatorNode()
    conculsionNode = DTAttributedTextContentNode()
    postItemsNodeLoader = LoaderNode()
    postItemsNodeViewAll = DisclosureNode()
    booksHorizontalFlowLayout = UICollectionViewFlowLayout()
    booksHorizontalFlowLayout.scrollDirection = .horizontal
    booksHorizontalFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: internalMargin, bottom: 0, right: internalMargin)
    booksHorizontalFlowLayout.minimumInteritemSpacing  = 0
    booksHorizontalFlowLayout.minimumLineSpacing       = internalMargin
    booksHorizontalCollectionNode = ASCollectionNode(collectionViewLayout: booksHorizontalFlowLayout)
    sectionTitleHeaderNode = SectionTitleHeaderNode()
    postItemsSeparator = SeparatorNode()
    relatedBooksViewAllNode = DisclosureNode()
    relatedBooksSeparator = SeparatorNode()
    relatedBooksTopSeparator = SeparatorNode()
    postCardsNode = PostDetailsItemNode()
    relatedPostsSectionTitleHeaderNode = SectionTitleHeaderNode()
    relatedPostsViewAllNode = DisclosureNode()
    relatedPostsTopSeparator = SeparatorNode()
    relatedPostsBottomSeparator = SeparatorNode()
    relatedPostsNodeLoader = LoaderNode()
    relatedBooksNodeLoader = LoaderNode()
    bannerImageNode = ASImageNode()
    commentsNode = CommentsNode()
    super.init()
    automaticallyManagesSubnodes = true
    automaticallyManagesContentSize = true
    initializeNode()
  }

  func loadPostItemsNode() {
    postItemsNode.loadNodes()
    setNeedsLayout()
  }

  func loadRelatedCards() {
    postCardsNode.loadNodes()
    setNeedsLayout()
  }
  
  func loadComments(for resource: ModelCommonProperties) {
    commentsNode.initialize(with: resource)
    commentsNode.reloadData()
  }

  func initializeNode() {
    headerNode.delegate = self

    booksHorizontalCollectionNode.style.preferredSize = CGSize(width: UIScreen.main.bounds.width,
                                                               height: horizontalCollectionNodeHeight)
    descriptionNode.delegate = self
    conculsionNode.delegate = self

    backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
    style.flexGrow = 1.0
    style.flexShrink = 1.0

    descriptionNode.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 5.0)
    descriptionNode.style.flexGrow = 1.0
    descriptionNode.style.flexShrink = 1.0

    tagCollectionNode.delegate = self

    conculsionNode.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 5.0)
    conculsionNode.style.flexGrow = 1.0
    conculsionNode.style.flexShrink = 1.0

    postItemsNodeViewAll.configuration.style = .highlighted
    postItemsNodeViewAll.text = Strings.view_all()
    postItemsNodeViewAll.delegate = self

    relatedBooksViewAllNode.configuration.style = .highlighted
    relatedBooksViewAllNode.text = Strings.view_all_related_books()
    relatedBooksViewAllNode.delegate = self

    relatedPostsViewAllNode.configuration.style = .highlighted
    relatedPostsViewAllNode.text = Strings.view_all_related_posts()
    relatedPostsViewAllNode.delegate = self

    sectionTitleHeaderNode.setTitle(title: Strings.related_books(), verticalBarColor: ThemeManager.shared.currentTheme.colorNumber10(), horizontalBarColor: ThemeManager.shared.currentTheme.colorNumber9())
    relatedPostsSectionTitleHeaderNode.setTitle(title: Strings.related_posts(), verticalBarColor: ThemeManager.shared.currentTheme.colorNumber4(), horizontalBarColor: ThemeManager.shared.currentTheme.colorNumber3())

    bannerImageNode.style.height = ASDimensionMake(120.0)
    bannerImageNode.style.flexGrow = 1
    bannerImageNode.style.flexShrink = 1
    bannerImageNode.contentMode = .scaleAspectFit
    setBannerImage()

    bannerImageNode.addTarget(self, action: #selector(bannerTouchUpInside) , forControlEvents: .touchUpInside)
    
    commentsNode.displayMode = .compact
    commentsNode.delegate = self
  }

  func setBannerImage() {
    switch GeneralSettings.sharedInstance.preferredLanguage {
    case Localization.Language.French.rawValue:
      bannerImageNode.image = #imageLiteral(resourceName: "freeShippingBannerFr")
    case Localization.Language.English.rawValue: fallthrough
    default:
      bannerImageNode.image = #imageLiteral(resourceName: "freeShippingBannerEn")
    }
  }

  func bannerTouchUpInside() {
    delegate?.bannerTapAction(url: Environment.current.shipementInfoURL)
  }

  func setWitValue(witted: Bool) {

  }

  func sidesEdgeInset() -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: internalMargin, bottom: 0, right: internalMargin)
  }

  func wrapNode(node: ASDisplayNode, width: CGFloat = UIScreen.main.bounds.width) -> ASLayoutSpec {
    let wrapperSpec = ASWrapperLayoutSpec(layoutElement: node)
    wrapperSpec.style.width = ASDimensionMake(width)
    return wrapperSpec
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let vStackSpec = ASStackLayoutSpec.vertical()
    vStackSpec.spacing = 0.0

    let descriptionInsetSpec = ASInsetLayoutSpec(insets: sidesEdgeInset(), child: descriptionNode)    
    let tagCollectionInsetSpec = ASInsetLayoutSpec(insets: sidesEdgeInset(), child: tagCollectionNode)

    let separatorInsetSpec = ASInsetLayoutSpec(insets: sidesEdgeInset(), child: separator)

    vStackSpec.children = [headerNode, ASLayoutSpec.spacer(height: contentSpacing),
                           descriptionInsetSpec, ASLayoutSpec.spacer(height: contentSpacing)]

    if self.tags?.count ?? 0 > 0 {
      let tagNodes: [ASLayoutElement] = [tagCollectionInsetSpec, ASLayoutSpec.spacer(height: contentSpacing)]
      vStackSpec.children?.append(contentsOf: tagNodes)
    }

    vStackSpec.children?.append(separatorInsetSpec)

    postItemsNodeLoader.updateLoaderVisibility(show: showPostsLoader)
    if showPostsLoader {
      let postItemsLoaderOverlaySpec = ASWrapperLayoutSpec(layoutElement: postItemsNodeLoader)
      postItemsLoaderOverlaySpec.style.width = ASDimensionMake(constrainedSize.max.width)
      vStackSpec.children?.append(ASLayoutSpec.spacer(height: contentSpacing))
      vStackSpec.children?.append(postItemsLoaderOverlaySpec)
      vStackSpec.children?.append(ASLayoutSpec.spacer(height: contentSpacing))
      vStackSpec.children?.append(postItemsSeparator)
    } else if delegate?.hasContentItems() ?? false {
      vStackSpec.children?.append(postItemsNode)
      vStackSpec.children?.append(postItemsNodeViewAll)
      vStackSpec.children?.append(postItemsSeparator)
    }

    if !conculsion.isEmptyOrNil() {
      let conculsionInsetSpec = ASInsetLayoutSpec(insets: sidesEdgeInset(), child: conculsionNode)
      vStackSpec.children?.append(ASLayoutSpec.spacer(height: contentSpacing))
      vStackSpec.children?.append(conculsionInsetSpec)
    }
    
    if showCommentNode {
      let commentsWrapper = wrapNode(node: commentsNode, width: constrainedSize.max.width)
      vStackSpec.children?.append(commentsWrapper)
    }

    relatedBooksNodeLoader.updateLoaderVisibility(show: showRelatedBooksLoader)
    if showRelatedBooksLoader {
      let wrapperSpec = wrapNode(node: relatedBooksNodeLoader, width: constrainedSize.max.width)
      vStackSpec.children?.append(ASLayoutSpec.spacer(height: contentSpacing))
      vStackSpec.children?.append(wrapperSpec)
      vStackSpec.children?.append(ASLayoutSpec.spacer(height: contentSpacing))
      vStackSpec.children?.append(relatedBooksSeparator)
    } else if delegate?.hasRelatedBooks() ?? false {
      vStackSpec.children?.append(ASLayoutSpec.spacer(height: contentSpacing))
      vStackSpec.children?.append(sectionTitleHeaderNode)
      vStackSpec.children?.append(ASLayoutSpec.spacer(height: contentSpacing))
      vStackSpec.children?.append(booksHorizontalCollectionNode)
      vStackSpec.children?.append(ASLayoutSpec.spacer(height: contentSpacing))
      vStackSpec.children?.append(relatedBooksTopSeparator)
      vStackSpec.children?.append(relatedBooksViewAllNode)
      vStackSpec.children?.append(relatedBooksSeparator)

      let bannerInsetSpec = ASInsetLayoutSpec(insets: sidesEdgeInset(), child: bannerImageNode)
      vStackSpec.children?.append(ASLayoutSpec.spacer(height: contentSpacing))
      vStackSpec.children?.append(bannerInsetSpec)
    }
    

    relatedPostsNodeLoader.updateLoaderVisibility(show: showRelatedPostsLoader)
    if showRelatedPostsLoader {
      let wrapperSpec = ASWrapperLayoutSpec(layoutElement: relatedPostsNodeLoader)
      wrapperSpec.style.width = ASDimensionMake(constrainedSize.max.width)
      vStackSpec.children?.append(ASLayoutSpec.spacer(height: contentSpacing))
      vStackSpec.children?.append(wrapperSpec)
      vStackSpec.children?.append(ASLayoutSpec.spacer(height: contentSpacing))
      vStackSpec.children?.append(relatedPostsBottomSeparator)
    } else if delegate?.hasRelatedPosts() ?? false {
      vStackSpec.children?.append(ASLayoutSpec.spacer(height: contentSpacing))
      vStackSpec.children?.append(relatedPostsSectionTitleHeaderNode)
      vStackSpec.children?.append(ASLayoutSpec.spacer(height: contentSpacing))
      vStackSpec.children?.append(postCardsNode)
      vStackSpec.children?.append(ASLayoutSpec.spacer(height: contentSpacing))
      vStackSpec.children?.append(relatedPostsTopSeparator)
      vStackSpec.children?.append(relatedPostsViewAllNode)
      vStackSpec.children?.append(relatedPostsBottomSeparator)
      vStackSpec.children?.append(ASLayoutSpec.spacer(height: contentSpacing))
    }
    return vStackSpec
  }
}

extension PostDetailsNode: PostDetailsHeaderNodeDelegate {
  func postDetailsHeader(node: PostDetailsHeaderNode, requestToViewImage image: UIImage, from imageNode: ASNetworkImageNode) {
    delegate?.postDetails(node: self, requestToViewImage: image, from: imageNode)
  }

  func postDetailsHeader(node: PostDetailsHeaderNode, didRequestActionInfo fromNode: ASTextNode) {
    delegate?.postDetails(node: self, didRequestActionInfo: fromNode)
  }
}

extension PostDetailsNode: CommentsNodeDelegate {
  func commentsNode(_ commentsNode: CommentsNode, reactFor action: CommentsNode.Action, didFinishAction: ((Bool) -> ())?) {
    delegate?.commentsNode(commentsNode, reactFor: action, didFinishAction: didFinishAction)
  }
}

// MARK: - Comment related methods
extension PostDetailsNode {
  func publishComment(content: String?, parentCommentIdentifier: String?, completion: @escaping (_ success: Bool, _ error: CommentsManager.Error?) -> Void) {
    commentsNode.publishComment(content: content, parentCommentIdentifier: parentCommentIdentifier) {
      (success, error) in
      completion(success, error)
    }
  }
  
  func removeComment(commentIdentifier: String, completion: ((_ success: Bool, _ error: CommentsManager.Error?) -> Void)?) {
    commentsNode.removeComment(commentIdentifier: commentIdentifier) {
      (success, error) in
      completion?(success, error)
    }
  }
  
  func wit(commentIdentifier: String, completion: ((_ success: Bool, _ error: CommentsManager.Error?) -> Void)?) {
    commentsNode.wit(commentIdentifier: commentIdentifier) {
      (success, error) in
      completion?(success, error)
    }
  }
  
  func unwit(commentIdentifier: String, completion: ((_ success: Bool, _ error: CommentsManager.Error?) -> Void)?) {
    commentsNode.unwit(commentIdentifier: commentIdentifier) {
      (success, error) in
      completion?(success, error)
    }
  }
}

extension PostDetailsNode: TagCollectionNodeDelegate {
  func tagCollection(node: TagCollectionNode, didSelectItemAt index: Int) {
    delegate?.postDetails(node: self, didSelectTagAt: index)
  }
}
