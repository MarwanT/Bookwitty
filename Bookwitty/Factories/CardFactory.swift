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
      return createAuthorCard(resource.registeredResourceType)
    case Text.resourceType:
      return createTextCard(resource.registeredResourceType)
    case Quote.resourceType:
      return createQuoteCard(resource.registeredResourceType)
    case Topic.resourceType:
      return createTopicCard(resource.registeredResourceType)
    case Audio.resourceType:
      return createAudioCard(resource.registeredResourceType)
    case Image.resourceType:
      return createImageCard(resource.registeredResourceType)
    case Video.resourceType:
      return createVideoCard(resource.registeredResourceType)
    case PenName.resourceType:
      return createPenNameCard(resource.registeredResourceType)
    case ReadingList.resourceType:
      return createReadingListCard(resource.registeredResourceType)
    case Link.resourceType:
      return createLinkCard(resource.registeredResourceType)
    case Book.resourceType:
      return createBookCard(resource.registeredResourceType)
    default:
      return nil
    }
  }
}

// MARK: - Author Card
extension  CardFactory {
  fileprivate func createAuthorCard(_ resourceType: ResourceType) -> TopicCardPostCellNode? {
    guard resourceType == Author.resourceType else {
      return nil
    }

    return TopicCardPostCellNode()
  }
}

// MARK: - Article/Text Card
extension  CardFactory {
  fileprivate func createTextCard(_ resourceType: ResourceType) -> ArticleCardPostCellNode? {
    guard resourceType == Text.resourceType else {
      return nil
    }

    return ArticleCardPostCellNode()
  }
}

// MARK: - Quote Card
extension  CardFactory {
  fileprivate func createQuoteCard(_ resourceType: ResourceType) -> QuoteCardPostCellNode? {
    guard resourceType == Quote.resourceType else {
      return nil
    }

    return QuoteCardPostCellNode()
  }
}

// MARK: - Topic Card
extension  CardFactory {
  fileprivate func createTopicCard(_ resourceType: ResourceType) -> TopicCardPostCellNode? {
    guard resourceType == Topic.resourceType else {
      return nil
    }

    return TopicCardPostCellNode()
  }
}

// MARK: - Link/Link Card
extension  CardFactory {
  fileprivate func createLinkCard(_ resourceType: ResourceType) -> LinkCardPostCellNode? {
    guard resourceType == Link.resourceType else {
      return nil
    }

    return LinkCardPostCellNode()
  }
}

// MARK: - Book Card
extension  CardFactory {
  fileprivate func createBookCard(_ resourceType: ResourceType) -> BookCardPostCellNode? {
    guard resourceType == Book.resourceType else {
      return nil
    }

    return BookCardPostCellNode()
  }
}

// MARK: - Link/Audio Card
extension  CardFactory {
  fileprivate func createAudioCard(_ resourceType: ResourceType) -> LinkCardPostCellNode? {
    guard resourceType == Audio.resourceType else {
      return nil
    }

    return LinkCardPostCellNode()
  }
}

// MARK: - Photo/Image Card
extension  CardFactory {
  fileprivate func createImageCard(_ resourceType: ResourceType) -> PhotoCardPostCellNode? {
    guard resourceType == Image.resourceType else {
      return nil
    }

    return PhotoCardPostCellNode()
  }
}

// MARK: - Video Card
extension  CardFactory {
  fileprivate func createVideoCard(_ resourceType: ResourceType) -> VideoCardPostCellNode? {
    guard resourceType == Video.resourceType else {
      return nil
    }

    return VideoCardPostCellNode()
  }
}

// MARK: - Profile/PenName Card
extension  CardFactory {
  fileprivate func createPenNameCard(_ resourceType: ResourceType) -> ProfileCardPostCellNode? {
    guard resourceType == PenName.resourceType else {
      return nil
    }

    return ProfileCardPostCellNode()
  }
}

// MARK: - ReadingList Card
extension  CardFactory {
  fileprivate func createReadingListCard(_ resourceType: ResourceType) -> ReadingListCardPostCellNode? {
    guard resourceType == ReadingList.resourceType else {
      return nil
    }

    return ReadingListCardPostCellNode()
  }
}
