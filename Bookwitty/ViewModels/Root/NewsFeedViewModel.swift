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
  var nextPage: URL?
  var data: [ModelResource] = []
  var penNames: [PenName] {
    return UserManager.shared.penNames ?? []
  }
  var defaultPenName: PenName? {
    return UserManager.shared.defaultPenName
  }

  func didUpdateDefaultPenName(penName: PenName, completionBlock: (_ didSaveDefault: Bool) -> ()) {
    var didSaveDefault: Bool = false
    defer {
      completionBlock(didSaveDefault)
    }

    if let oldPenNameId = defaultPenName?.id {
      //Cached Pen-Name Id
      if let newPenNameId = penName.id, newPenNameId != oldPenNameId {
        UserManager.shared.saveDefaultPenName(penName: penName)
        didSaveDefault = true
      }
      //Else do nothing: Since the default PenName did not change.
    } else {
      //Save Default Pen-Name
      UserManager.shared.saveDefaultPenName(penName: penName)
      didSaveDefault = true
    }
  }

  func witContent(index: Int, completionBlock: @escaping (_ success: Bool) -> ()) {
    let showsPenNameSelectionHeader = (hasPenNames() ? 1 : 0)
    let dataIndex = index - showsPenNameSelectionHeader
    guard data.count > dataIndex,
      let contentId = data[dataIndex].id else {
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
      let contentId = data[dataIndex].id else {
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

  func loadNextPage(completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let nextPage = nextPage else {
      completionBlock(false)
      return
    }

    cancellableRequest = NewsfeedAPI.nextFeedPage(nextPage: nextPage) { (success, resources, nextPage, error) in
      if let resources = resources, success {
        self.data += resources
        self.nextPage = nextPage
      }
      completionBlock(success)
    }
  }

  func sharingContent(index: Int) -> String? {
    let showsPenNameSelectionHeader = (hasPenNames() ? 1 : 0)
    let dataIndex = index - showsPenNameSelectionHeader
    guard data.count > dataIndex,
    let commonProperties = data[dataIndex] as? ModelCommonProperties else {
        return nil
    }

    let content = data[dataIndex]
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
    return CardFactory.shared.createCardFor(resource: resource)
  }
}

class CardRegistry {
  typealias RegEntry = (_ shouldShowInfoNode: Bool) -> BaseCardPostNode

  static let sharedInstance: CardRegistry = CardRegistry()

  private var registry = [String : RegEntry]()


  func register(resource : ModelResource.Type, creator : @escaping (_ shouldShowInfoNode: Bool) -> BaseCardPostNode) {
    registry[resource.resourceType] = creator
  }

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
    guard let resource = resource as? Author else {
      return nil
    }
    let cardCanditate = entry(resource.penName?.name != nil)
    guard let card = cardCanditate as? TopicCardPostCellNode else {
      return nil
    }

    let name = resource.penName?.name ?? "[No Name]"
    let date = Date.formatDate(date: resource.createdAt)
    card.postInfoData = CardPostInfoNodeData(name, date, "https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
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
    guard let resource = resource as? Text else {
      return nil
    }
    let cardCanditate = entry(resource.penName?.name != nil)
    guard let card = cardCanditate as? ArticleCardPostCellNode else {
      return nil
    }

    let name = resource.penName?.name ?? "[No Name]"
    let date = Date.formatDate(date: resource.createdAt)
    card.postInfoData = CardPostInfoNodeData(name, date, "https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
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
    guard let resource = resource as? Quote else {
      return nil
    }
    let cardCanditate = entry(resource.penName?.name != nil)
    guard let card = cardCanditate as? QuoteCardPostCellNode else {
      return nil
    }

    let name = resource.penName?.name ?? "[No Name]"
    let date = Date.formatDate(date: resource.createdAt)
    card.postInfoData = CardPostInfoNodeData(name, date, "https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
    card.node.articleQuotePublisher = resource.author
    if let qoute = resource.body, !qoute.isEmpty {
      card.node.articleQuote = "“ \(qoute) ”"
    } else if let qoute = resource.title, !qoute.isEmpty {
      card.node.articleQuote = "“ \(qoute) ”"
    }
    card.articleCommentsSummary = "X commented on this"

    return card
  }

  private func createTopicCard(_ resource: ModelResource) -> BaseCardPostNode? {
    guard let entry = registry[resource.registeredResourceType] else {
      return BaseCardPostNode()
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
    card.postInfoData = CardPostInfoNodeData(name, date, "https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
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
    guard let resource = resource as? Link else {
      return nil
    }
    let cardCanditate = entry(resource.penName?.name != nil)
    guard let card = cardCanditate as? LinkCardPostCellNode else {
      return nil
    }

    let name = resource.penName?.name ?? "[No Name]"
    let date = Date.formatDate(date: resource.createdAt)
    card.postInfoData = CardPostInfoNodeData(name, date, "https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
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
    guard let resource = resource as? Audio else {
      return nil
    }
    let cardCanditate = entry(resource.penName?.name != nil)
    guard let card = cardCanditate as? LinkCardPostCellNode else {
      return nil
    }

    let name = resource.penName?.name ?? "[No Name]"
    let date = Date.formatDate(date: resource.createdAt)
    card.postInfoData = CardPostInfoNodeData(name, date, "https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
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
    guard let resource = resource as? Image else {
      return nil
    }
    let cardCanditate = entry(resource.penName?.name != nil)
    guard let card = cardCanditate as? PhotoCardPostCellNode else {
      return nil
    }

    let name = resource.penName?.name ?? "[No Name]"
    let date = Date.formatDate(date: resource.createdAt)
    card.postInfoData = CardPostInfoNodeData(name, date, "https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
    card.node.imageUrl = resource.coverImageUrl
    card.articleCommentsSummary = "X commented on this"

    return card
  }

  private func createVideoCard(_ resource: ModelResource) -> BaseCardPostNode? {
    guard let entry = registry[resource.registeredResourceType] else {
      return BaseCardPostNode()
    }
    guard let resource = resource as? Video else {
      return nil
    }
    let cardCanditate = entry(resource.penName?.name != nil)
    guard let card = cardCanditate as? VideoCardPostCellNode else {
      return nil
    }

    let name = resource.penName?.name ?? "[No Name]"
    let date = Date.formatDate(date: resource.createdAt)
    card.postInfoData = CardPostInfoNodeData(name, date, "https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
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

  private func createReadingListCard(_ resource: ModelResource) -> BaseCardPostNode? {
    guard let entry = registry[resource.registeredResourceType] else {
      return BaseCardPostNode()
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
    card.postInfoData = CardPostInfoNodeData(name, date, "https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
    card.node.articleTitle = resource.title
    card.node.articleDescription = resource.shortDescription
    card.node.setTopicStatistics(numberOfPosts: "XX")
    card.articleCommentsSummary = "X commented on this"

    return card
  }
}
