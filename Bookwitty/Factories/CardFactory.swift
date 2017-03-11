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
  //TODO: Refactor to Follow the original Factory pattern
  typealias RegEntry = (_ shouldShowInfoNode: Bool) -> BaseCardPostNode

  static let shared: CardFactory = CardFactory()

  fileprivate var registry = [String : RegEntry]()

  private init() {
    //Making Constructor Not Reachable
    register(resource: Author.self) { (shouldShowInfoNode: Bool) -> BaseCardPostNode in
      TopicCardPostCellNode()
    }
    register(resource: Text.self) { (shouldShowInfoNode: Bool) -> BaseCardPostNode in
      ArticleCardPostCellNode(shouldShowInfoNode: shouldShowInfoNode)
    }
    register(resource: Quote.self) { (shouldShowInfoNode: Bool) -> BaseCardPostNode in
      QuoteCardPostCellNode(shouldShowInfoNode: shouldShowInfoNode)
    }
    register(resource: Topic.self) { (shouldShowInfoNode: Bool) -> BaseCardPostNode in
      TopicCardPostCellNode(shouldShowInfoNode: shouldShowInfoNode)
    }
    register(resource: Audio.self) { (shouldShowInfoNode: Bool) -> BaseCardPostNode in
      LinkCardPostCellNode(shouldShowInfoNode: shouldShowInfoNode)
    }
    register(resource: Image.self) { (shouldShowInfoNode: Bool) -> BaseCardPostNode in
      PhotoCardPostCellNode(shouldShowInfoNode: shouldShowInfoNode)
    }
    register(resource: Video.self) { (shouldShowInfoNode: Bool) -> BaseCardPostNode in
      VideoCardPostCellNode(shouldShowInfoNode: shouldShowInfoNode)
    }
    register(resource: PenName.self) { (shouldShowInfoNode: Bool) -> BaseCardPostNode in
      ProfileCardPostCellNode(shouldShowInfoNode: shouldShowInfoNode)
    }
    register(resource: ReadingList.self) { (shouldShowInfoNode: Bool) -> BaseCardPostNode in
      ReadingListCardPostCellNode(shouldShowInfoNode: shouldShowInfoNode)
    }
    register(resource: Link.self) { (shouldShowInfoNode: Bool) -> BaseCardPostNode in
      LinkCardPostCellNode(shouldShowInfoNode: shouldShowInfoNode)
    }
    register(resource: Book.self) { (shouldShowInfoNode: Bool) -> BaseCardPostNode in
      TopicCardPostCellNode(shouldShowInfoNode: shouldShowInfoNode)
    }
  }

  func register(resource : ModelResource.Type, creator : @escaping (_ shouldShowInfoNode: Bool) -> BaseCardPostNode) {
    registry[resource.resourceType] = creator
  }

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
    guard let entry = registry[resource.registeredResourceType] else {
      return nil
    }
    guard let resource = resource as? Author else {
      return nil
    }
    let cardCanditate = entry(resource.penName?.name != nil)
    guard let card = cardCanditate as? TopicCardPostCellNode else {
      return nil
    }

    let name = resource.penName?.name ?? "[No Name]"
    let date = Date.formatDate(date: resource.createdAt)
    let penNameprofileImage = resource.penName?.avatarUrl
    card.postInfoData = CardPostInfoNodeData(name, date, penNameprofileImage)
    card.node.articleTitle = resource.caption
    card.node.articleDescription = resource.shortDescription ?? resource.biography
    card.node.subImageUrl = resource.thumbnailImageUrl ?? resource.profileImageUrl ?? resource.imageUrl
    card.node.imageUrl = resource.coverImageUrl
    card.wit = resource.isWitted

    return card
  }
}

// MARK: - Article/Text Card
extension  CardFactory {
  fileprivate func createTextCard(_ resource: ModelResource) -> ArticleCardPostCellNode? {
    guard let entry = registry[resource.registeredResourceType] else {
      return nil
    }
    guard let resource = resource as? Text else {
      return nil
    }
    let cardCanditate = entry(resource.penName?.name != nil)
    guard let card = cardCanditate as? ArticleCardPostCellNode else {
      return nil
    }

    let name = resource.penName?.name ?? "[No Name]"
    let date = Date.formatDate(date: resource.createdAt)
    let penNameprofileImage = resource.penName?.avatarUrl
    card.postInfoData = CardPostInfoNodeData(name, date, penNameprofileImage)
    card.node.articleTitle = resource.title
    card.node.articleDescription = resource.shortDescription
    card.node.imageUrl = resource.coverImageUrl ?? resource.thumbnailImageUrl
    card.articleCommentsSummary = "XX commented on this"
    card.wit = resource.isWitted

    return card
  }
}

// MARK: - Quote Card
extension  CardFactory {
  fileprivate func createQuoteCard(_ resource: ModelResource) -> QuoteCardPostCellNode? {
    guard let entry = registry[resource.registeredResourceType] else {
      return nil
    }
    guard let resource = resource as? Quote else {
      return nil
    }
    let cardCanditate = entry(resource.penName?.name != nil)
    guard let card = cardCanditate as? QuoteCardPostCellNode else {
      return nil
    }

    let name = resource.penName?.name ?? "[No Name]"
    let date = Date.formatDate(date: resource.createdAt)
    let penNameprofileImage = resource.penName?.avatarUrl
    card.postInfoData = CardPostInfoNodeData(name, date, penNameprofileImage)
    card.node.articleQuotePublisher = resource.author
    if let qoute = resource.body, !qoute.isEmpty {
      card.node.articleQuote = "“ \(qoute) ”"
    } else if let qoute = resource.title, !qoute.isEmpty {
      card.node.articleQuote = "“ \(qoute) ”"
    }
    card.articleCommentsSummary = "X commented on this"
    card.wit = resource.isWitted

    return card
  }
}

// MARK: - Topic Card
extension  CardFactory {
  fileprivate func createTopicCard(_ resource: ModelResource) -> TopicCardPostCellNode? {
    guard let entry = registry[resource.registeredResourceType] else {
      return nil
    }
    guard let resource = resource as? Topic else {
      return nil
    }
    let cardCanditate = entry(resource.penName?.name != nil)
    guard let card = cardCanditate as? TopicCardPostCellNode else {
      return nil
    }

    let name = resource.penName?.name ?? "[No Name]"
    let date = Date.formatDate(date: resource.createdAt)
    let penNameprofileImage = resource.penName?.avatarUrl
    card.postInfoData = CardPostInfoNodeData(name, date, penNameprofileImage)
    card.node.articleTitle = nil
    card.node.articleDescription = resource.shortDescription
    card.node.imageUrl = resource.coverImageUrl
    card.node.setTopicStatistics(numberOfPosts: "XX")
    card.articleCommentsSummary = "X commented on this"
    card.node.subImageUrl = resource.thumbnailImageUrl
    card.wit = resource.isWitted

    return card
  }
}

// MARK: - Link/Link Card
extension  CardFactory {
  fileprivate func createLinkCard(_ resource: ModelResource) -> LinkCardPostCellNode? {
    guard let entry = registry[resource.registeredResourceType] else {
      return nil
    }
    guard let resource = resource as? Link else {
      return nil
    }
    let cardCanditate = entry(resource.penName?.name != nil)
    guard let card = cardCanditate as? LinkCardPostCellNode else {
      return nil
    }

    let name = resource.penName?.name ?? "[No Name]"
    let date = Date.formatDate(date: resource.createdAt)
    let penNameprofileImage = resource.penName?.avatarUrl
    card.postInfoData = CardPostInfoNodeData(name, date, penNameprofileImage)
    card.node.linkUrl = resource.urlLink
    card.node.articleTitle = resource.title
    card.node.articleDescription = resource.shortDescription
    card.node.imageNode.url = resource.coverImageUrl.isEmptyOrNil() ? nil : URL(string: resource.coverImageUrl!)
    card.wit = resource.isWitted

    return card
  }
}

// MARK: - Book Card
extension  CardFactory {
  fileprivate func createBookCard(_ resource: ModelResource) -> TopicCardPostCellNode? {
    guard let entry = registry[resource.registeredResourceType] else {
      return nil
    }
    guard let resource = resource as? Book else {
      return nil
    }

    let cardCanditate = entry(resource.productDetails?.author != nil)
    guard let card = cardCanditate as? TopicCardPostCellNode else {
      return nil
    }

    let name = resource.productDetails?.author ?? "[No Name]"
    let date = Date.formatDate(date: resource.createdAt)
    card.postInfoData = CardPostInfoNodeData(name, date, nil)

    card.node.articleTitle = resource.title
    card.node.articleDescription = resource.bookDescription
    card.node.setTopicStatistics(numberOfPosts: "XX")
    card.articleCommentsSummary = "X commented on this"
    card.node.imageUrl = resource.coverImageUrl
    card.node.subImageUrl = resource.thumbnailImageUrl
    card.wit = resource.isWitted

    return card
  }
}

// MARK: - Link/Audio Card
extension  CardFactory {
  fileprivate func createAudioCard(_ resource: ModelResource) -> LinkCardPostCellNode? {
    guard let entry = registry[resource.registeredResourceType] else {
      return nil
    }
    guard let resource = resource as? Audio else {
      return nil
    }
    let cardCanditate = entry(resource.penName?.name != nil)
    guard let card = cardCanditate as? LinkCardPostCellNode else {
      return nil
    }

    let name = resource.penName?.name ?? "[No Name]"
    let date = Date.formatDate(date: resource.createdAt)
    let penNameprofileImage = resource.penName?.avatarUrl
    card.postInfoData = CardPostInfoNodeData(name, date, penNameprofileImage)
    card.node.linkUrl = nil
    card.node.articleTitle = resource.title
    card.node.articleDescription = resource.shortDescription
    card.node.imageNode.url = resource.coverImageUrl.isEmptyOrNil() ? nil : URL(string: resource.coverImageUrl!)
    card.wit = resource.isWitted

    return card
  }
}

// MARK: - Photo/Image Card
extension  CardFactory {
  fileprivate func createImageCard(_ resource: ModelResource) -> PhotoCardPostCellNode? {
    guard let entry = registry[resource.registeredResourceType] else {
      return nil
    }
    guard let resource = resource as? Image else {
      return nil
    }
    let cardCanditate = entry(resource.penName?.name != nil)
    guard let card = cardCanditate as? PhotoCardPostCellNode else {
      return nil
    }

    let name = resource.penName?.name ?? "[No Name]"
    let date = Date.formatDate(date: resource.createdAt)
    let penNameprofileImage = resource.penName?.avatarUrl
    card.postInfoData = CardPostInfoNodeData(name, date, penNameprofileImage)
    card.node.imageUrl = resource.coverImageUrl
    card.articleCommentsSummary = "X commented on this"
    card.wit = resource.isWitted
    
    return card
  }
}

// MARK: - Video Card
extension  CardFactory {
  fileprivate func createVideoCard(_ resource: ModelResource) -> VideoCardPostCellNode? {
    guard let entry = registry[resource.registeredResourceType] else {
      return nil
    }
    guard let resource = resource as? Video else {
      return nil
    }
    let cardCanditate = entry(resource.penName?.name != nil)
    guard let card = cardCanditate as? VideoCardPostCellNode else {
      return nil
    }

    //TODO: Remove the static data
    let name = resource.penName?.name ?? "[No Name]"
    let date = Date.formatDate(date: resource.createdAt)
    let penNameprofileImage = resource.penName?.avatarUrl
    card.postInfoData = CardPostInfoNodeData(name, date, penNameprofileImage)
    card.node.articleTitle = resource.title
    card.node.articleDescription = resource.shortDescription
    card.node.imageUrl = resource.coverImageUrl
    card.articleCommentsSummary = "XX commented on this"
    card.wit = resource.isWitted

    return card
  }
}

// MARK: - Profile/PenName Card
extension  CardFactory {
  fileprivate func createPenNameCard(_ resource: ModelResource) -> ProfileCardPostCellNode? {
    guard let entry = registry[resource.registeredResourceType] else {
      return nil
    }
    guard let resource = resource as? PenName else {
      return nil
    }
    let cardCanditate = entry(false)
    guard let card = cardCanditate as? ProfileCardPostCellNode else {
      return nil
    }

    card.node.imageUrl = resource.avatarUrl
    card.node.followersCount = String(resource.followersCount?.intValue ?? 0)
    card.node.userName = resource.name
    card.node.articleDescription = resource.biography

    return card
  }
}

// MARK: - ReadingList Card
extension  CardFactory {
  fileprivate func createReadingListCard(_ resource: ModelResource) -> ReadingListCardPostCellNode? {
    guard let entry = registry[resource.registeredResourceType] else {
      return nil
    }
    guard let resource = resource as? ReadingList else {
      return nil
    }
    let cardCanditate = entry(resource.penName?.name != nil)
    guard let card = cardCanditate as? ReadingListCardPostCellNode else {
      return nil
    }

    let name = resource.penName?.name ?? "[No Name]"
    let date = Date.formatDate(date: resource.createdAt)
    let penNameprofileImage = resource.penName?.avatarUrl
    card.postInfoData = CardPostInfoNodeData(name, date, penNameprofileImage)
    card.node.articleTitle = resource.title
    card.node.articleDescription = resource.shortDescription
    card.node.setTopicStatistics(numberOfPosts: "XX")
    card.articleCommentsSummary = "X commented on this"
    card.wit = resource.isWitted

    let images = resource.posts?.map({ ($0 as? ModelCommonProperties)?.thumbnailImageUrl }) ?? []
    card.node.imageCollection = images.flatMap({$0})

    return card
  }
}