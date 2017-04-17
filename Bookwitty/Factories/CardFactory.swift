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
      return CardFactory.createAuthorCard()
    case Text.resourceType:
      return CardFactory.createTextCard()
    case Quote.resourceType:
      return CardFactory.createQuoteCard()
    case Topic.resourceType:
      return CardFactory.createTopicCard()
    case Audio.resourceType:
      return CardFactory.createAudioCard()
    case Image.resourceType:
      return CardFactory.createImageCard()
    case Video.resourceType:
      return CardFactory.createVideoCard()
    case PenName.resourceType:
      return CardFactory.createPenNameCard()
    case ReadingList.resourceType:
      return CardFactory.createReadingListCard()
    case Link.resourceType:
      return CardFactory.createLinkCard()
    case Book.resourceType:
      return CardFactory.createBookCard()
    default:
      return nil
    }
  }
}

// MARK: - Author Card
extension  CardFactory {
  fileprivate class func createAuthorCard() -> TopicCardPostCellNode? {
    return TopicCardPostCellNode()
  }
}

// MARK: - Article/Text Card
extension  CardFactory {
  fileprivate class func createTextCard() -> ArticleCardPostCellNode? {
    return ArticleCardPostCellNode()
  }
}

// MARK: - Quote Card
extension  CardFactory {
  fileprivate class func createQuoteCard() -> QuoteCardPostCellNode? {
    return QuoteCardPostCellNode()
  }
}

// MARK: - Topic Card
extension  CardFactory {
  fileprivate class func createTopicCard() -> TopicCardPostCellNode? {
    return TopicCardPostCellNode()
  }
}

// MARK: - Link/Link Card
extension  CardFactory {
  fileprivate class func createLinkCard() -> LinkCardPostCellNode? {
    return LinkCardPostCellNode()
  }
}

// MARK: - Book Card
extension  CardFactory {
  fileprivate class func createBookCard() -> BookCardPostCellNode? {
    return BookCardPostCellNode()
  }
}

// MARK: - Link/Audio Card
extension  CardFactory {
  fileprivate class func createAudioCard() -> LinkCardPostCellNode? {
    return LinkCardPostCellNode()
  }
}

// MARK: - Photo/Image Card
extension  CardFactory {
  fileprivate class func createImageCard() -> PhotoCardPostCellNode? {
    return PhotoCardPostCellNode()
  }
}

// MARK: - Video Card
extension  CardFactory {
  fileprivate class func createVideoCard() -> VideoCardPostCellNode? {
    return VideoCardPostCellNode()
  }
}

// MARK: - Profile/PenName Card
extension  CardFactory {
  fileprivate class func createPenNameCard() -> ProfileCardPostCellNode? {
    return ProfileCardPostCellNode()
  }
}

// MARK: - ReadingList Card
extension  CardFactory {
  fileprivate class func createReadingListCard() -> ReadingListCardPostCellNode? {
    return ReadingListCardPostCellNode()
  }
}
