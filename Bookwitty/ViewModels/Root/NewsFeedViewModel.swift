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
  var nextPage: URL?
  var data: [ModelResource] = []
  var penNames: [PenName] {
    return UserManager.shared.penNames ?? []
  }
  var defaultPenName: PenName? {
    return UserManager.shared.defaultPenName
  }

  func didUpdateDefaultPenName(penName: PenName, completionBlock: () -> ()) {
    UserManager.shared.saveDefaultPenName(penName: penName)
    completionBlock()
  }

  func witContent(index: Int, completionBlock: @escaping (_ success: Bool) -> ()) {
    let showsPenNameSelectionHeader = (hasPenNames() ? 1 : 0)
    let dataIndex = index - showsPenNameSelectionHeader
    guard data.count > dataIndex,
      let contentId = data[index].id else {
      completionBlock(false)
      return
    }

    cancellableRequest = NewsfeedAPI.wit(contentId: contentId, completion: { (success, error) in
      completionBlock(success)
    })
  }

  func unwitContent(index: Int, completionBlock: @escaping (_ success: Bool) -> ()) {
    let showsPenNameSelectionHeader = (hasPenNames() ? 1 : 0)
    let dataIndex = index - showsPenNameSelectionHeader
    guard data.count > dataIndex,
      let contentId = data[index].id else {
        completionBlock(false)
        return
    }

    cancellableRequest = NewsfeedAPI.unwit(contentId: contentId, completion: { (success, error) in
      completionBlock(success)
    })
  }

  func loadNewsfeed(completionBlock: @escaping (_ success: Bool) -> ()) {
    cancellableRequest = NewsfeedAPI.feed() { (success, resources, nextPage, error) in
      self.data = resources ?? []
      self.nextPage = nextPage
      completionBlock(success)
    }
  }

  func hasNextPage() -> Bool {
    return (nextPage != nil)
  }

  func sharingContent(index: Int) -> String? {
    let showsPenNameSelectionHeader = (hasPenNames() ? 1 : 0)
    let dataIndex = index - showsPenNameSelectionHeader
    guard data.count > dataIndex,
    let commonProperties = data[index] as? ModelCommonProperties else {
        return nil
    }

    let content = data[index]
    //TODO: Make sure that we are sharing the right information
    let shortDesciption = commonProperties.shortDescription ?? commonProperties.title ?? ""
    if let sharingUrl = content.url {
      var sharingString = sharingUrl.absoluteString
      sharingString += shortDesciption.isEmpty ? "" : "\n\n\(shortDesciption)"
      return sharingString
    }

    //TODO: Remove dummy data and return nil instead since we do not have a url to share.
    var sharingString = "https://bookwitty-api-qa.herokuapp.com/reading_list/ios-mobile-applications-development/58a6f9b56b2c581af13637f6"
    sharingString += shortDesciption.isEmpty ? "" : "\n\n\(shortDesciption)"
    return sharingString
  }

  func hasPenNames() -> Bool {
    return penNames.count > 0
  }

  func numberOfSections() -> Int {
    let showsPenNameSelectionHeader = (hasPenNames() ? 1 : 0)
    return data.count > 0 ? 1 : showsPenNameSelectionHeader
  }

  func numberOfItemsInSection() -> Int {
    let showsPenNameSelectionHeader = (hasPenNames() ? 1 : 0)
    return data.count + showsPenNameSelectionHeader
  }

  func nodeForItem(atIndex index: Int) -> BaseCardPostNode? {
    let showsPenNameSelectionHeader = (hasPenNames() ? 1 : 0)
    let dataIndex = index - showsPenNameSelectionHeader
    guard data.count > dataIndex else { return nil }
    let resource = data[dataIndex]
    return CardRegistry.getCard(resource: resource)
  }
}

class CardRegistry {
  typealias RegEntry = () -> BaseCardPostNode

  static let sharedInstance: CardRegistry = CardRegistry()

  private var registry = [String : RegEntry]()


  func register(resource : ModelResource.Type, creator : @escaping () -> BaseCardPostNode) {
    registry[resource.resourceType] = creator
  }

  private init() {
    //Making Constructor Not Reachable
    register(resource: Author.self) { () -> BaseCardPostNode in
      TopicCardPostCellNode()
    }
    register(resource: Text.self) { () -> BaseCardPostNode in
      ArticleCardPostCellNode()
    }
    register(resource: Quote.self) { () -> BaseCardPostNode in
      QuoteCardPostCellNode()
    }
    register(resource: Topic.self) { () -> BaseCardPostNode in
      TopicCardPostCellNode()
    }
    register(resource: Audio.self) { () -> BaseCardPostNode in
      LinkCardPostCellNode()
    }
    register(resource: Image.self) { () -> BaseCardPostNode in
      PhotoCardPostCellNode()
    }
    register(resource: Video.self) { () -> BaseCardPostNode in
      VideoCardPostCellNode()
    }
    register(resource: PenName.self) { () -> BaseCardPostNode in
      ProfileCardPostCellNode()
    }
    register(resource: ReadingList.self) { () -> BaseCardPostNode in
      ReadingListCardPostCellNode()
    }
    register(resource: Link.self) { () -> BaseCardPostNode in
      LinkCardPostCellNode()
    }
  }

  static func getCard(resource : ModelResource) -> BaseCardPostNode? {
    let resourceType: ResourceType = resource.registeredResourceType

    switch(resourceType) {
    case Author.resourceType:
      return sharedInstance.createAuthorCard(resource)
    case Text.resourceType:
      return sharedInstance.createTextCard(resource)
    case Quote.resourceType:
      return sharedInstance.createQuoteCard(resource)
    case Topic.resourceType:
      return sharedInstance.createTopicCard(resource)
    case Audio.resourceType:
      return sharedInstance.createAudioCard(resource)
    case Image.resourceType:
      return sharedInstance.createImageCard(resource)
    case Video.resourceType:
      return sharedInstance.createVideoCard(resource)
    case PenName.resourceType:
      return sharedInstance.createPenNameCard(resource)
    case ReadingList.resourceType:
      return sharedInstance.createReadingListCard(resource)
    case Link.resourceType:
      return sharedInstance.createLinkCard(resource)
    default:
      return nil
    }
  }

  private func createAuthorCard(_ resource: ModelResource) -> BaseCardPostNode? {
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

    card.postInfoData = CardPostInfoNodeData("Charles","December 2, 2020","https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
    card.node.articleTitle = resource.caption
    card.node.articleDescription = resource.shortDescription ?? resource.biography
    card.node.subImageUrl = resource.thumbnailImageUrl ?? resource.profileImageUrl ?? resource.imageUrl
    card.node.imageUrl = resource.coverImageUrl

    return card
  }

  private func createTextCard(_ resource: ModelResource) -> BaseCardPostNode? {
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

  private func createQuoteCard(_ resource: ModelResource) -> BaseCardPostNode? {
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
    if let qoute = resource.body, !qoute.isEmpty {
      quoteCell.node.articleQuote = "“ \(qoute) ”"
    } else if let qoute = resource.title, !qoute.isEmpty {
      quoteCell.node.articleQuote = "“ \(qoute) ”"
    }
    quoteCell.articleCommentsSummary = "X commented on this"

    return card
  }

  private func createTopicCard(_ resource: ModelResource) -> BaseCardPostNode? {
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

  private func createLinkCard(_ resource: ModelResource) -> BaseCardPostNode? {
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

  private func createAudioCard(_ resource: ModelResource) -> BaseCardPostNode? {
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

  private func createImageCard(_ resource: ModelResource) -> BaseCardPostNode? {
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

  private func createVideoCard(_ resource: ModelResource) -> BaseCardPostNode? {
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

  private func createPenNameCard(_ resource: ModelResource) -> BaseCardPostNode? {
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

  private func createReadingListCard(_ resource: ModelResource) -> BaseCardPostNode? {
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
