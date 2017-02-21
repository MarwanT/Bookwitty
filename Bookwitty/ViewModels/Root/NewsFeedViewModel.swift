//
//  NewsFeedViewModel.swift
//  Bookwitty
//
//  Created by Marwan  on 2/17/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya
import Spine

final class NewsFeedViewModel {
  var cancellableRequest:  Cancellable?
  let viewController = localizedString(key: "news", defaultValue: "News")
  var data: [Feed] = []
  var selectedPenNameId: String = "6c08337a-108f-4335-b2d0-3a25b9fe6bed"

  func loadNewsfeed(completionBlock: @escaping (_ success: Bool) -> ()) {
    cancellableRequest = NewsfeedAPI.feed(forPenName: selectedPenNameId) { (success, feeds, error) in
      self.data = feeds ?? []
      completionBlock(success)
    }
  }

  func numberOfSections() -> Int {
    return data.count > 0 ? 1 : 0
  }

  func numberOfItemsInSection() -> Int {
    return data.count
  }

  func nodeForItem(atIndex index: Int) -> BaseCardPostNode? {
    guard data.count > index else { return nil }
    let feed = data[index]
    return CardRegistry.getCard(feed: feed)
  }
}

class CardRegistry {
  typealias RegEntry = () -> BaseCardPostNode

  static let sharedInstance: CardRegistry = CardRegistry()

  private var registry = [String : RegEntry]()


  func register(feed : Feed.Type, creator : @escaping () -> BaseCardPostNode) {
    registry[feed.resourceType] = creator
  }

  private init() {
    //Making Constructor Not Reachable
    register(feed: Author.self) { () -> BaseCardPostNode in
      TopicCardPostCellNode()
    }
    register(feed: Text.self) { () -> BaseCardPostNode in
      ArticleCardPostCellNode()
    }
    register(feed: Quote.self) { () -> BaseCardPostNode in
      QuoteCardPostCellNode()
    }
    register(feed: Topic.self) { () -> BaseCardPostNode in
      TopicCardPostCellNode()
    }
    register(feed: Audio.self) { () -> BaseCardPostNode in
      LinkCardPostCellNode()
    }
    register(feed: Image.self) { () -> BaseCardPostNode in
      PhotoCardPostCellNode()
    }
    register(feed: Video.self) { () -> BaseCardPostNode in
      VideoCardPostCellNode()
    }
    register(feed: PenName.self) { () -> BaseCardPostNode in
      ProfileCardPostCellNode()
    }
    register(feed: ReadingList.self) { () -> BaseCardPostNode in
      ReadingListCardPostCellNode()
    }
    register(feed: Link.self) { () -> BaseCardPostNode in
      LinkCardPostCellNode()
    }
  }

  static func getCard(feed : Feed) -> BaseCardPostNode? {
    let resourceType: ResourceType = feed.registeredResourceType

    switch(resourceType) {
    case Author.resourceType:
      return sharedInstance.createAuthorCard(feed)
    case Text.resourceType:
      return sharedInstance.createTextCard(feed)
    case Quote.resourceType:
      return sharedInstance.createQuoteCard(feed)
    case Topic.resourceType:
      return sharedInstance.createTopicCard(feed)
    case Audio.resourceType:
      return sharedInstance.createAudioCard(feed)
    case Image.resourceType:
      return sharedInstance.createImageCard(feed)
    case Video.resourceType:
      return sharedInstance.createVideoCard(feed)
    case PenName.resourceType:
      return sharedInstance.createPenNameCard(feed)
    case ReadingList.resourceType:
      return sharedInstance.createReadingListCard(feed)
    case Link.resourceType:
      return sharedInstance.createLinkCard(feed)
    default:
      return nil
    }
  }

  private func createAuthorCard(_ resource: Feed) -> BaseCardPostNode? {
    guard let entry = registry[resource.registeredResourceType] else {
      return nil
    }
    let cardCanditate = entry()
    guard let card = cardCanditate as? TopicCardPostCellNode else {
      return nil
    }
    guard let resource = resource as? Author else {
      return nil
    }

    card.node.articleTitle = resource.caption
    card.node.articleDescription = resource.shortDescription ?? resource.biography
    card.node.subImageUrl = resource.thumbnailImageUrl ?? resource.profileImageUrl ?? resource.imageUrl
    card.node.imageUrl = resource.coverImageUrl

    return card
  }

  private func createTextCard(_ resource: Feed) -> BaseCardPostNode? {
    guard let entry = registry[resource.registeredResourceType] else {
      return BaseCardPostNode()
    }
    let cardCanditate = entry()
    guard let card = cardCanditate as? ArticleCardPostCellNode else {
      return nil
    }
    guard let resource = resource as? Text else {
      return nil
    }

    card.postInfoData = CardPostInfoNodeData("Charles","December 2, 2020","https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
    card.node.articleTitle = resource.title
    card.node.articleDescription = resource.shortDescription
    card.node.imageUrl = resource.coverImageUrl ?? resource.thumbnailImageUrl
    card.articleCommentsSummary = "XX commented on this"

    return card
  }

  private func createQuoteCard(_ resource: Feed) -> BaseCardPostNode? {
    guard let entry = registry[resource.registeredResourceType] else {
      return nil
    }
    let cardCanditate = entry()
    guard let card = cardCanditate as? QuoteCardPostCellNode else {
      return nil
    }
    guard let resource = resource as? Quote else {
      return nil
    }

    let quoteCell = QuoteCardPostCellNode()
    quoteCell.postInfoData = CardPostInfoNodeData("Charles","December 2, 2020","https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
    quoteCell.node.articleQuotePublisher = resource.author
    quoteCell.node.articleQuote = resource.body.isEmptyOrNil() ? "" : "“ \(resource.body!) ”"
    quoteCell.articleCommentsSummary = "X commented on this"

    return card
  }

  private func createTopicCard(_ resource: Feed) -> BaseCardPostNode? {
    guard let entry = registry[resource.registeredResourceType] else {
      return BaseCardPostNode()
    }
    let cardCanditate = entry()
    guard let card = cardCanditate as? TopicCardPostCellNode else {
      return nil
    }
    guard let resource = resource as? Topic else {
      return nil
    }

    card.postInfoData = CardPostInfoNodeData("Shafic","December 12, 2014","https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
    card.node.articleTitle = nil
    card.node.articleDescription = resource.shortDescription
    card.node.imageUrl = resource.coverImageUrl
    card.node.setTopicStatistics(numberOfPosts: "XX")
    card.articleCommentsSummary = "X commented on this"
    card.node.subImageUrl = resource.thumbnailImageUrl

    return card
  }

  private func createLinkCard(_ resource: Feed) -> BaseCardPostNode? {
    guard let entry = registry[resource.registeredResourceType] else {
      return BaseCardPostNode()
    }
    let cardCanditate = entry()
    guard let card = cardCanditate as? LinkCardPostCellNode else {
      return nil
    }
    guard let resource = resource as? Link else {
      return nil
    }

    card.postInfoData = CardPostInfoNodeData("Charles","December 2, 2020","https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
    card.node.linkUrl = resource.urlLink
    card.node.articleTitle = resource.title
    card.node.articleDescription = resource.shortDescription
    card.node.imageNode.url = resource.coverImageUrl.isEmptyOrNil() ? nil : URL(string: resource.coverImageUrl!)

    return card
  }

  private func createAudioCard(_ resource: Feed) -> BaseCardPostNode? {
    guard let entry = registry[resource.registeredResourceType] else {
      return BaseCardPostNode()
    }
    let cardCanditate = entry()
    guard let card = cardCanditate as? LinkCardPostCellNode else {
      return nil
    }
    guard let resource = resource as? Audio else {
      return nil
    }

    card.postInfoData = CardPostInfoNodeData("Charles","December 2, 2020","https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
    card.node.linkUrl = nil
    card.node.articleTitle = resource.title
    card.node.articleDescription = resource.shortDescription
    card.node.imageNode.url = resource.coverImageUrl.isEmptyOrNil() ? nil : URL(string: resource.coverImageUrl!)

    return card
  }

  private func createImageCard(_ resource: Resource) -> BaseCardPostNode? {
    guard let entry = registry[resource.registeredResourceType] else {
      return BaseCardPostNode()
    }
    let cardCanditate = entry()
    guard let card = cardCanditate as? PhotoCardPostCellNode else {
      return nil
    }
    guard let resource = resource as? Image else {
      return nil
    }

    card.postInfoData = CardPostInfoNodeData("Michel","December 1, 2016","https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
    card.node.imageUrl = resource.coverImageUrl
    card.articleCommentsSummary = "X commented on this"

    return card
  }

  private func createVideoCard(_ resource: Feed) -> BaseCardPostNode? {
    guard let entry = registry[resource.registeredResourceType] else {
      return BaseCardPostNode()
    }
    let cardCanditate = entry()
    guard let card = cardCanditate as? VideoCardPostCellNode else {
      return nil
    }
    guard let resource = resource as? Video else {
      return nil
    }

    card.postInfoData = CardPostInfoNodeData("Charles","December 2, 2020","https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
    card.node.articleTitle = resource.title
    card.node.articleDescription = resource.shortDescription
    card.node.imageUrl = resource.coverImageUrl
    card.articleCommentsSummary = "XX commented on this"

    return card
  }

  private func createPenNameCard(_ resource: Feed) -> BaseCardPostNode? {
    guard let entry = registry[resource.registeredResourceType] else {
      return BaseCardPostNode()
    }
    let cardCanditate = entry()
    guard let card = cardCanditate as? ProfileCardPostCellNode else {
      return nil
    }
    guard let resource = resource as? PenName else {
      return nil
    }

    card.node.imageUrl = resource.avatarUrl
    card.node.followersCount = String(resource.followersCount?.intValue ?? 0)
    card.node.userName = resource.name
    card.node.articleDescription = resource.biography

    return card
  }

  private func createReadingListCard(_ resource: Feed) -> BaseCardPostNode? {
    guard let entry = registry[resource.registeredResourceType] else {
      return BaseCardPostNode()
    }
    let cardCanditate = entry()
    guard let card = cardCanditate as? ReadingListCardPostCellNode else {
      return nil
    }
    guard let resource = resource as? ReadingList else {
      return nil
    }

    card.postInfoData = CardPostInfoNodeData("Shafic","December 12, 2014","https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
    card.node.articleTitle = resource.title
    card.node.articleDescription = resource.shortDescription
    card.node.setTopicStatistics(numberOfPosts: "XX")
    card.articleCommentsSummary = "X commented on this"

    return card
  }
}
