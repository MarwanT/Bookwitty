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
  func attributedTextContentNodeNeedsLayout(node: DTAttributedTextContentNode) {
    setNeedsLayout()
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

extension PostDetailsNode: CardActionBarNodeDelegate {
  func cardActionBarNode(cardActionBar: CardActionBarNode, didRequestAction action: CardActionBarNode.Action, forSender sender: ASButtonNode, didFinishAction: ((_ success: Bool) -> ())?) {
    delegate?.cardActionBarNode(cardActionBar: cardActionBar, didRequestAction: action, forSender: sender, didFinishAction: didFinishAction)
  }
}

protocol PostDetailsNodeDelegate {
  func bannerTapAction(url: URL?)
  func shouldShowPostDetailsAllPosts()
  func shouldShowPostDetailsAllRelatedBooks()
  func shouldShowPostDetailsAllRelatedPosts()
  func hasRelatedPosts() -> Bool
  func hasRelatedBooks() -> Bool
  func hasContentItems() -> Bool
  func cardActionBarNode(cardActionBar: CardActionBarNode, didRequestAction action: CardActionBarNode.Action, forSender sender: ASButtonNode, didFinishAction: ((_ success: Bool) -> ())?)
}

class PostDetailsNode: ASScrollNode {
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()
  fileprivate let horizontalCollectionNodeHeight: CGFloat = RelatedBooksMinimalCellNode.cellHeight


  fileprivate let descriptionNode: DTAttributedTextContentNode
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
  var delegate: PostDetailsNodeDelegate?
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
    super.init(viewBlock: viewBlock, didLoad: didLoadBlock)
  }

  override init() {
    headerNode = PostDetailsHeaderNode()
    descriptionNode = DTAttributedTextContentNode()
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

  func initializeNode() {
    headerNode.actionBarNode.delegate = self

    booksHorizontalCollectionNode.style.preferredSize = CGSize(width: UIScreen.main.bounds.width,
                                                               height: horizontalCollectionNodeHeight)
    descriptionNode.delegate = self
    conculsionNode.delegate = self

    backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
    style.flexGrow = 1.0
    style.flexShrink = 1.0

    descriptionNode.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 25.0)
    descriptionNode.style.flexGrow = 1.0
    descriptionNode.style.flexShrink = 1.0

    conculsionNode.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 25.0)
    conculsionNode.style.flexGrow = 1.0
    conculsionNode.style.flexShrink = 1.0

    postItemsNodeViewAll.configuration.style = .highlighted
    postItemsNodeViewAll.text = Strings.view_all()
    postItemsNodeViewAll.delegate = self

    relatedBooksViewAllNode.configuration.style = .highlighted
    relatedBooksViewAllNode.text = Strings.view_all_related_books()
    relatedBooksViewAllNode.delegate = self

    relatedPostsViewAllNode.configuration.style = .highlighted
    relatedPostsViewAllNode.text = Strings.view_all_related_books()
    relatedPostsViewAllNode.delegate = self

    sectionTitleHeaderNode.setTitle(title: Strings.related_books(), verticalBarColor: ThemeManager.shared.currentTheme.colorNumber10(), horizontalBarColor: ThemeManager.shared.currentTheme.colorNumber9())
    relatedPostsSectionTitleHeaderNode.setTitle(title: Strings.related_posts(), verticalBarColor: ThemeManager.shared.currentTheme.colorNumber4(), horizontalBarColor: ThemeManager.shared.currentTheme.colorNumber3())

    bannerImageNode.style.height = ASDimensionMake(120.0)
    bannerImageNode.style.flexGrow = 1
    bannerImageNode.style.flexShrink = 1
    bannerImageNode.contentMode = .scaleAspectFit
    bannerImageNode.image = #imageLiteral(resourceName: "freeShippingBanner")
    bannerImageNode.addTarget(self, action: #selector(bannerTouchUpInside) , forControlEvents: .touchUpInside)
  }

  func bannerTouchUpInside() {
    delegate?.bannerTapAction(url: Environment.current.shipementInfoURL)
  }

  func setWitValue(witted: Bool, wits: Int) {
    headerNode.actionBarNode.setWitButton(witted: witted, wits: wits)
  }

  func setDimValue(dimmed: Bool, dims: Int) {
    headerNode.actionBarNode.setDimValue(dimmed: dimmed, dims: dims)
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
    let separatorInsetSpec = ASInsetLayoutSpec(insets: sidesEdgeInset(), child: separator)

    vStackSpec.children = [headerNode, ASLayoutSpec.spacer(height: contentSpacing),
                           descriptionInsetSpec, ASLayoutSpec.spacer(height: contentSpacing),
                           separatorInsetSpec]

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
