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
      return createAuthorCard()
    case Text.resourceType:
      return createTextCard()
    case Quote.resourceType:
      return createQuoteCard()
    case Topic.resourceType:
      return createTopicCard()
    case Audio.resourceType:
      return createAudioCard()
    case Image.resourceType:
      return createImageCard()
    case Video.resourceType:
      return createVideoCard()
    case PenName.resourceType:
      return createPenNameCard()
    case ReadingList.resourceType:
      return createReadingListCard()
    case Link.resourceType:
      return createLinkCard()
    case Book.resourceType:
      return createBookCard()
    default:
      return nil
    }
  }
}

// MARK: - Author Card
extension  CardFactory {
  fileprivate func createAuthorCard() -> TopicCardPostCellNode? {
    return TopicCardPostCellNode()
  }
}

// MARK: - Article/Text Card
extension  CardFactory {
  fileprivate func createTextCard() -> ArticleCardPostCellNode? {
    return ArticleCardPostCellNode()
  }
}

// MARK: - Quote Card
extension  CardFactory {
  fileprivate func createQuoteCard() -> QuoteCardPostCellNode? {
    return QuoteCardPostCellNode()
  }
}

// MARK: - Topic Card
extension  CardFactory {
  fileprivate func createTopicCard() -> TopicCardPostCellNode? {
    return TopicCardPostCellNode()
  }
}

// MARK: - Link/Link Card
extension  CardFactory {
  fileprivate func createLinkCard() -> LinkCardPostCellNode? {
    return LinkCardPostCellNode()
  }
}

// MARK: - Book Card
extension  CardFactory {
  fileprivate func createBookCard() -> BookCardPostCellNode? {
    return BookCardPostCellNode()
  }
}

// MARK: - Link/Audio Card
extension  CardFactory {
  fileprivate func createAudioCard() -> LinkCardPostCellNode? {
    return LinkCardPostCellNode()
  }
}

// MARK: - Photo/Image Card
extension  CardFactory {
  fileprivate func createImageCard() -> PhotoCardPostCellNode? {
    return PhotoCardPostCellNode()
  }
}

// MARK: - Video Card
extension  CardFactory {
  fileprivate func createVideoCard() -> VideoCardPostCellNode? {
    return VideoCardPostCellNode()
  }
}

// MARK: - Profile/PenName Card
extension  CardFactory {
  fileprivate func createPenNameCard() -> ProfileCardPostCellNode? {
    return ProfileCardPostCellNode()
  }
}

// MARK: - ReadingList Card
extension  CardFactory {
  fileprivate func createReadingListCard() -> ReadingListCardPostCellNode? {
    return ReadingListCardPostCellNode()
  }
}
