//
//  CardFactory.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/1/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

class CardFactory {
  static let shared: CardFactory = CardFactory()

  func createCardFor(resource : ModelResource) -> BaseCardPostNode? {
    let resourceType: ResourceType = resource.registeredResourceType

    switch(resourceType) {
    case Author.resourceType:
      return createAuthorCard(resource)
    case Text.resourceType:
      return createTextCard(resource)
    case Quote.resourceType:
      return createQuoteCard(resource)
    case Topic.resourceType:
      return createTopicCard(resource)
    case Audio.resourceType:
      return createAudioCard(resource)
    case Image.resourceType:
      return createImageCard(resource)
    case Video.resourceType:
      return createVideoCard(resource)
    case PenName.resourceType:
      return createPenNameCard(resource)
    case ReadingList.resourceType:
      return createReadingListCard(resource)
    case Link.resourceType:
      return createLinkCard(resource)
    case Book.resourceType:
      return createBookCard(resource)
    default:
      return nil
    }
  }
}

// MARK: - Author Card
extension  CardFactory {
  fileprivate func createAuthorCard(_ resource: ModelResource) -> TopicCardPostCellNode? {
    guard let resource = resource as? Author else {
      return nil
    }

    let card = TopicCardPostCellNode()
    let cardPostInfoData: CardPostInfoNodeData?
    if let penName = resource.penName {
      let name = penName.name ?? ""
      let date = Date.formatDate(date: resource.createdAt)
      let penNameprofileImage = penName.avatarUrl
      cardPostInfoData = CardPostInfoNodeData(name, date, penNameprofileImage)
    } else {
      cardPostInfoData = nil
    }
    card.postInfoData = cardPostInfoData
    card.setup(forFollowingMode: true)
    card.setFollowingValue(following: resource.following)
    card.node.articleTitle = resource.caption
    card.node.articleDescription = resource.shortDescription ?? resource.biography
    card.node.subImageUrl = resource.thumbnailImageUrl ?? resource.profileImageUrl ?? resource.imageUrl
    card.node.imageUrl = nil
    card.setWitValue(witted: resource.isWitted, wits: resource.counts?.wits ?? 0)
    card.setDimValue(dimmed: resource.isDimmed, dims: resource.counts?.dims ?? 0)

    return card
  }
}

// MARK: - Article/Text Card
extension  CardFactory {
  fileprivate func createTextCard(_ resource: ModelResource) -> ArticleCardPostCellNode? {
    guard let resource = resource as? Text else {
      return nil
    }

    let card = ArticleCardPostCellNode(shouldShowInfoNode: resource.penName?.name != nil)
    let cardPostInfoData: CardPostInfoNodeData?
    if let penName = resource.penName {
      let name = penName.name ?? ""
      let date = Date.formatDate(date: resource.createdAt)
      let penNameprofileImage = penName.avatarUrl
      cardPostInfoData = CardPostInfoNodeData(name, date, penNameprofileImage)
    } else {
      cardPostInfoData = nil
    }
    card.postInfoData = cardPostInfoData

    card.node.articleTitle = resource.title
    card.node.articleDescription = resource.shortDescription
    card.node.imageUrl = resource.coverImageUrl ?? resource.thumbnailImageUrl
    card.articleCommentsSummary = nil
    card.setWitValue(witted: resource.isWitted, wits: resource.counts?.wits ?? 0)
    card.setDimValue(dimmed: resource.isDimmed, dims: resource.counts?.dims ?? 0)

    return card
  }
}

// MARK: - Quote Card
extension  CardFactory {
  fileprivate func createQuoteCard(_ resource: ModelResource) -> QuoteCardPostCellNode? {
    guard let resource = resource as? Quote else {
      return nil
    }

    let card = QuoteCardPostCellNode(shouldShowInfoNode: resource.penName?.name != nil)
    let cardPostInfoData: CardPostInfoNodeData?
    if let penName = resource.penName {
      let name = penName.name ?? ""
      let date = Date.formatDate(date: resource.createdAt)
      let penNameprofileImage = penName.avatarUrl
      cardPostInfoData = CardPostInfoNodeData(name, date, penNameprofileImage)
    } else {
      cardPostInfoData = nil
    }
    card.postInfoData = cardPostInfoData
    card.node.articleQuotePublisher = resource.author
    if let qoute = resource.body, !qoute.isEmpty {
      card.node.articleQuote = "“ \(qoute) ”"
    } else if let qoute = resource.title, !qoute.isEmpty {
      card.node.articleQuote = "“ \(qoute) ”"
    }
    card.articleCommentsSummary = nil
    card.setWitValue(witted: resource.isWitted, wits: resource.counts?.wits ?? 0)
    card.setDimValue(dimmed: resource.isDimmed, dims: resource.counts?.dims ?? 0)

    return card
  }
}

// MARK: - Topic Card
extension  CardFactory {
  fileprivate func createTopicCard(_ resource: ModelResource) -> TopicCardPostCellNode? {
    guard let resource = resource as? Topic else {
      return nil
    }

    let card = TopicCardPostCellNode(shouldShowInfoNode: resource.penName?.name != nil)
    let cardPostInfoData: CardPostInfoNodeData?
    if let penName = resource.penName {
      let name = penName.name ?? ""
      let date = Date.formatDate(date: resource.createdAt)
      let penNameprofileImage = penName.avatarUrl
      cardPostInfoData = CardPostInfoNodeData(name, date, penNameprofileImage)
    } else {
      cardPostInfoData = nil
    }
    card.postInfoData = cardPostInfoData
    card.setup(forFollowingMode: true)
    card.setFollowingValue(following: resource.following)
    card.node.articleTitle = resource.title
    card.node.articleDescription = resource.shortDescription
    card.node.imageUrl = resource.coverImageUrl
    card.node.setTopicStatistics(numberOfPosts: resource.counts?.posts, numberOfBooks: nil, numberOfFollowers: resource.counts?.followers)
    card.articleCommentsSummary = nil
    card.node.subImageUrl = nil
    card.setWitValue(witted: resource.isWitted, wits: resource.counts?.wits ?? 0)
    card.setDimValue(dimmed: resource.isDimmed, dims: resource.counts?.dims ?? 0)

    return card
  }
}

// MARK: - Link/Link Card
extension  CardFactory {
  fileprivate func createLinkCard(_ resource: ModelResource) -> LinkCardPostCellNode? {
    guard let resource = resource as? Link else {
      return nil
    }

    let card = LinkCardPostCellNode(shouldShowInfoNode: resource.penName?.name != nil)
    let cardPostInfoData: CardPostInfoNodeData?
    if let penName = resource.penName {
      let name = penName.name ?? ""
      let date = Date.formatDate(date: resource.createdAt)
      let penNameprofileImage = penName.avatarUrl
      cardPostInfoData = CardPostInfoNodeData(name, date, penNameprofileImage)
    } else {
      cardPostInfoData = nil
    }
    card.postInfoData = cardPostInfoData
    card.node.articleTitle = resource.title
    card.node.articleDescription = resource.shortDescription
    card.node.imageNode.url = resource.coverImageUrl.isEmptyOrNil() ? nil : URL(string: resource.coverImageUrl!)
    card.node.linkUrl = resource.urlLink
    card.setWitValue(witted: resource.isWitted, wits: resource.counts?.wits ?? 0)
    card.setDimValue(dimmed: resource.isDimmed, dims: resource.counts?.dims ?? 0)
    
    return card
  }
}

// MARK: - Book Card
extension  CardFactory {
  fileprivate func createBookCard(_ resource: ModelResource) -> BookCardPostCellNode? {
    guard let resource = resource as? Book else {
      return nil
    }

    let card = BookCardPostCellNode(shouldShowInfoNode: resource.penName?.name != nil)
    let cardPostInfoData: CardPostInfoNodeData?
    if let penName = resource.penName {
      let name = penName.name ?? ""
      let date = Date.formatDate(date: resource.createdAt)
      let penNameprofileImage = penName.avatarUrl
      cardPostInfoData = CardPostInfoNodeData(name, date, penNameprofileImage)
    } else {
      cardPostInfoData = nil
    }
    card.postInfoData = cardPostInfoData
    card.setup(forFollowingMode: true)
    card.setFollowingValue(following: resource.following)
    card.node.title = resource.title
    card.node.imageUrl = resource.thumbnailImageUrl
    //TODO: When the book item starts returning the number of editions we will enable the price, formatting and author details
    //If the number of Editions is greater than 0 then this is a book-product then set isProduct = true.
    card.node.isProduct = false
    card.node.setTopicStatistics(numberOfPosts: resource.counts?.posts, numberOfBooks: nil, numberOfFollowers: resource.counts?.followers)
    card.node.author = resource.productDetails?.author
    card.node.price = (resource.productDetails?.isElectronicFormat() ?? false) ? nil : resource.supplierInformation?.preferredPrice?.formattedValue
    card.node.format = resource.productDetails?.productFormat

    return card
  }
}

// MARK: - Link/Audio Card
extension  CardFactory {
  fileprivate func createAudioCard(_ resource: ModelResource) -> LinkCardPostCellNode? {
    guard let resource = resource as? Audio else {
      return nil
    }

    let card = LinkCardPostCellNode(shouldShowInfoNode: resource.penName?.name != nil)
    let cardPostInfoData: CardPostInfoNodeData?
    if let penName = resource.penName {
      let name = penName.name ?? ""
      let date = Date.formatDate(date: resource.createdAt)
      let penNameprofileImage = penName.avatarUrl
      cardPostInfoData = CardPostInfoNodeData(name, date, penNameprofileImage)
    } else {
      cardPostInfoData = nil
    }
    card.postInfoData = cardPostInfoData
    card.node.articleTitle = resource.title
    card.node.articleDescription = resource.shortDescription
    card.node.imageNode.url = resource.coverImageUrl.isEmptyOrNil() ? nil : URL(string: resource.coverImageUrl!)
    //linkUrl will override the imageNode url if it has an image
    card.node.linkUrl = resource.media?.mediaLink

    card.setWitValue(witted: resource.isWitted, wits: resource.counts?.wits ?? 0)
    card.setDimValue(dimmed: resource.isDimmed, dims: resource.counts?.dims ?? 0)

    return card
  }
}

// MARK: - Photo/Image Card
extension  CardFactory {
  fileprivate func createImageCard(_ resource: ModelResource) -> PhotoCardPostCellNode? {
    guard let resource = resource as? Image else {
      return nil
    }

    let card = PhotoCardPostCellNode(shouldShowInfoNode: resource.penName?.name != nil)
    let cardPostInfoData: CardPostInfoNodeData?
    if let penName = resource.penName {
      let name = penName.name ?? ""
      let date = Date.formatDate(date: resource.createdAt)
      let penNameprofileImage = penName.avatarUrl
      cardPostInfoData = CardPostInfoNodeData(name, date, penNameprofileImage)
    } else {
      cardPostInfoData = nil
    }
    card.postInfoData = cardPostInfoData
    card.node.imageUrl = resource.coverImageUrl
    card.node.articleTitle = resource.title
    card.node.articleDescription = resource.shortDescription
    card.setWitValue(witted: resource.isWitted, wits: resource.counts?.wits ?? 0)
    card.setDimValue(dimmed: resource.isDimmed, dims: resource.counts?.dims ?? 0)
    
    return card
  }
}

// MARK: - Video Card
extension  CardFactory {
  fileprivate func createVideoCard(_ resource: ModelResource) -> VideoCardPostCellNode? {
    guard let resource = resource as? Video else {
      return nil
    }

    let card = VideoCardPostCellNode(shouldShowInfoNode: resource.penName?.name != nil)
    if let urlStr = resource.media?.mediaLink,
      let url = URL(string: urlStr) {
      IFramely.shared.loadResponseFor(url: url, closure: { (response: Response?) in
        card.node.videoUrl = response?.embedUrl
        card.node.imageUrl = response?.thumbnails?.first?.url?.absoluteString ?? resource.coverImageUrl
      })
    }

    let cardPostInfoData: CardPostInfoNodeData?
    if let penName = resource.penName {
      let name = penName.name ?? ""
      let date = Date.formatDate(date: resource.createdAt)
      let penNameprofileImage = penName.avatarUrl
      cardPostInfoData = CardPostInfoNodeData(name, date, penNameprofileImage)
    } else {
      cardPostInfoData = nil
    }
    card.postInfoData = cardPostInfoData
    card.node.articleTitle = resource.title
    card.node.articleDescription = resource.shortDescription
    card.articleCommentsSummary = nil
    card.setWitValue(witted: resource.isWitted, wits: resource.counts?.wits ?? 0)
    card.setDimValue(dimmed: resource.isDimmed, dims: resource.counts?.dims ?? 0)

    return card
  }
}

// MARK: - Profile/PenName Card
extension  CardFactory {
  fileprivate func createPenNameCard(_ resource: ModelResource) -> ProfileCardPostCellNode? {
    guard let resource = resource as? PenName else {
      return nil
    }

    let card = ProfileCardPostCellNode()
    card.setup(forFollowingMode: true)
    card.setFollowingValue(following: resource.following)
    card.node.imageUrl = resource.avatarUrl
    card.node.followersCount = String(resource.counts?.followers ?? 0)
    card.node.userName = resource.name
    card.node.articleDescription = resource.biography

    return card
  }
}

// MARK: - ReadingList Card
extension  CardFactory {
  fileprivate func createReadingListCard(_ resource: ModelResource) -> ReadingListCardPostCellNode? {
    guard let resource = resource as? ReadingList else {
      return nil
    }

    let card = ReadingListCardPostCellNode(shouldShowInfoNode: resource.penName?.name != nil)
    let cardPostInfoData: CardPostInfoNodeData?
    if let penName = resource.penName {
      let name = penName.name ?? ""
      let date = Date.formatDate(date: resource.createdAt)
      let penNameprofileImage = penName.avatarUrl
      cardPostInfoData = CardPostInfoNodeData(name, date, penNameprofileImage)
    } else {
      cardPostInfoData = nil
    }
    card.postInfoData = cardPostInfoData

    card.node.articleTitle = resource.title
    card.node.articleDescription = resource.shortDescription

    card.node.setTopicStatistics(numberOfPosts: resource.counts?.posts, numberOfBooks: nil, numberOfFollowers: resource.counts?.followers)
    card.articleCommentsSummary = nil
    card.setWitValue(witted: resource.isWitted, wits: resource.counts?.wits ?? 0)
    card.setDimValue(dimmed: resource.isDimmed, dims: resource.counts?.dims ?? 0)

    let hasPosts = resource.posts?.count ?? 0 > 0
    if hasPosts, let images = resource.posts?.map({ ($0 as? ModelCommonProperties)?.thumbnailImageUrl }) {
      let imageCollection = images.flatMap({$0})
      if imageCollection.count > 0 {
        card.node.loadImages(with: imageCollection)
      }
    } else if let imagesCount = resource.postsRelations?.count,
      imagesCount > 0 {
      card.node.prepareImages(imageCount: imagesCount)
    }
    return card
  }
}
