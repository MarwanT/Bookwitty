//
//  ReadingListCardPostCellNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/15/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class ReadingListCardPostCellNode: BaseCardPostNode {
  let node: ReadingListCardContentNode
  var showsInfoNode: Bool = true
  override var shouldShowInfoNode: Bool { return showsInfoNode }
  override var contentShouldExtendBorders: Bool { return true }
  override var contentNode: ASDisplayNode { return node }

  let viewModel: ReadingListCardViewModel
  override var baseViewModel: CardViewModelProtocol? {
    return viewModel
  }
  
  override init() {
    node = ReadingListCardContentNode()
    viewModel = ReadingListCardViewModel()
    super.init()
    shouldHandleTopComments = true
    viewModel.delegate = self
  }

  convenience init(shouldShowInfoNode: Bool) {
    self.init()
    showsInfoNode = shouldShowInfoNode
  }
}

class ReadingListCardContentNode: ASDisplayNode {
  fileprivate let externalMargin = ThemeManager.shared.currentTheme.cardExternalMargin()
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let collectionImageSize: CGSize = CGSize(width: 60, height: 100)

  private let titleNode: ASTextNode
  private let topicStatsNode: ASTextNode
  private let descriptionNode: ASTextNode
  private let customHorizontalList: ReadingListBooksNode

  var articleTitle: String? {
    didSet {
      if let articleTitle = articleTitle {
        titleNode.attributedText = AttributedStringBuilder(fontDynamicType: .title2)
          .append(text: articleTitle, color: ThemeManager.shared.currentTheme.colorNumber20()).attributedString
      } else {
        titleNode.attributedText = nil
      }
      titleNode.setNeedsLayout()
    }
  }

  var articleDescription: String? {
    didSet {
      if let articleDescription = articleDescription?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
        descriptionNode.attributedText = AttributedStringBuilder(fontDynamicType: .body)
          .append(text: articleDescription, color: ThemeManager.shared.currentTheme.colorNumber20()).attributedString
      } else {
        descriptionNode.attributedText = nil
      }

      descriptionNode.setNeedsLayout()
    }
  }

  var isImageCollectionLoaded: Bool {
    return customHorizontalList.isImageCollectionLoaded
  }
  
  var maxNumberOfImages: Int {
    return customHorizontalList.maxItems
  }

  func reload() {
    customHorizontalList.reload()
  }

  func prepareImages(imageCount count: Int) {
    customHorizontalList.prepareImages(for: count)
  }

  func loadImages(with imageCollection: [String]) {
    customHorizontalList.updateCollection(images: imageCollection, shouldLoadImages: true)
  }

  override init() {
    titleNode = ASTextNode()
    topicStatsNode = ASTextNode()
    descriptionNode = ASTextNode()
    customHorizontalList = ReadingListBooksNode()
    super.init()
    automaticallyManagesSubnodes = true
    setupNode()
  }

  func setupNode() {
    titleNode.maximumNumberOfLines = 3
    descriptionNode.maximumNumberOfLines = 3
    topicStatsNode.maximumNumberOfLines = 1

    titleNode.truncationMode = NSLineBreakMode.byTruncatingTail
    descriptionNode.truncationMode = NSLineBreakMode.byTruncatingTail
    topicStatsNode.truncationMode = NSLineBreakMode.byTruncatingTail

    initializeImageCollectionNode()
  }

  func initializeImageCollectionNode() {
    customHorizontalList.imageNodeSize = collectionImageSize
  }

  func setTopicStatistics(numberOfPosts: Int? = nil, numberOfBooks: Int? = nil, numberOfFollowers: Int? = nil) {
    let separator =  " | "
    var attrStringBuilder = AttributedStringBuilder(fontDynamicType: .footnote)
    var addSeparator: Bool = false

    if let numberOfPosts = numberOfPosts {
      attrStringBuilder = attrStringBuilder
        .append(text: Strings.posts(number: numberOfPosts), fontDynamicType: .caption2)
      addSeparator = true
    } else {
      addSeparator = false
    }

    if let numberOfBooks = numberOfBooks {
      attrStringBuilder = attrStringBuilder
        .append(text: (addSeparator ? separator : ""), fontDynamicType: .caption2)
        .append(text: Strings.books(number: numberOfBooks), fontDynamicType: .caption2)
      addSeparator = true
    }

    if let numberOfFollowers = numberOfFollowers {
      attrStringBuilder = attrStringBuilder
        .append(text: (addSeparator ? separator : ""), fontDynamicType: .caption2)
        .append(text: Strings.followers(number: numberOfFollowers), fontDynamicType: .caption2)
    }

    //Set the string value
    topicStatsNode.attributedText = attrStringBuilder.attributedString
    setNeedsLayout()
  }

  private func isValid(_ value: String?) -> Bool {
    return !value.isEmptyOrNil()
  }

  private func spacer(height: CGFloat = 0, width: CGFloat = 0) -> ASLayoutSpec {
    return ASLayoutSpec().styled { (style) in
      style.height = ASDimensionMake(height)
      style.width = ASDimensionMake(width)
    }
  }

  private func cardSidesInset() -> UIEdgeInsets {
    return UIEdgeInsets(top: 0,
                        left: internalMargin + externalMargin,
                        bottom: 0 ,
                        right: internalMargin + externalMargin)
  }

  private func imageInset() -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 0, bottom: 0 , right: 0)
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    var nodesArray: [ASLayoutElement] = []

    let customLayoutSpec = ASCenterLayoutSpec(centeringOptions: ASCenterLayoutSpecCenteringOptions.XY, sizingOptions: ASCenterLayoutSpecSizingOptions.minimumXY, child: customHorizontalList)
    nodesArray.append(customLayoutSpec)

    let titleNodeInset = ASInsetLayoutSpec(insets: cardSidesInset(), child: titleNode)
    let topicStatsNodeInset = ASInsetLayoutSpec(insets: cardSidesInset(), child: topicStatsNode)
    let descriptionNodeInset = ASInsetLayoutSpec(insets: cardSidesInset(), child: descriptionNode)

    let statsStr = topicStatsNode.attributedText?.string

    if(isValid(articleTitle)) {
      nodesArray.append(spacer(height: internalMargin))
      nodesArray.append(titleNodeInset)
    }
    if(isValid(statsStr)) {
      nodesArray.append(spacer(height: internalMargin/2))
      nodesArray.append(topicStatsNodeInset)
    }
    if(isValid(articleDescription)) {
      let marginHeight = isValid(statsStr) ? internalMargin/2 : internalMargin

      nodesArray.append(spacer(height: marginHeight))
      nodesArray.append(descriptionNodeInset)
    }

    let verticalStack = ASStackLayoutSpec(direction: .vertical,
                                          spacing: 0,
                                          justifyContent: .start,
                                          alignItems: .stretch,
                                          children: nodesArray)

    return verticalStack
  }

}

//MARK: - ReadingListsViewModelDelegate implementation
extension ReadingListCardPostCellNode: ReadingListCardViewModelDelegate {
  func resourceUpdated(viewModel: ReadingListCardViewModel) {
    let values = viewModel.values()
    showsInfoNode = values.infoNode
    postInfoData = values.postInfo
    node.articleTitle = values.content.title
    node.articleDescription = values.content.description
    node.setTopicStatistics(numberOfPosts: values.content.statistics.posts, numberOfBooks: values.content.statistics.relatedBooks, numberOfFollowers: values.content.statistics.followers)
    setWitValue(witted: values.content.wit.is)
    actionInfoValue = values.content.wit.info
    topComment = values.content.topComment
    tags = values.content.tags
    reported = values.reported

    if !node.isImageCollectionLoaded {
      if values.content.relatedContent.posts.count > 0 {
        node.loadImages(with: values.content.relatedContent.posts)
      } else if values.content.relatedContent.count > 0 {
        node.prepareImages(imageCount: values.content.relatedContent.count)
      }
    }
  }
}
