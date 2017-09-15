//
//  ReadingListCardViewModel.swift
//  Bookwitty
//
//  Created by charles on 4/18/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

protocol ReadingListCardViewModelDelegate: class {
  func resourceUpdated(viewModel: ReadingListCardViewModel)
}

class ReadingListCardViewModel: CardViewModelProtocol {
  var resource: ModelCommonProperties? {
    didSet {
      notifyChange()
    }
  }

  weak var delegate: ReadingListCardViewModelDelegate?

  private func notifyChange() {
    delegate?.resourceUpdated(viewModel: self)
  }

  func values() -> (infoNode: Bool, postInfo: CardPostInfoNodeData?, content: (title: String?, description: String?, topComment: Comment?, comments: String?, tags: [String]?, relatedContent: (posts: [String], count: Int), statistics: (posts: Int?, relatedBooks: Int?, followers: Int?), wit: (is: Bool, count: Int, info: String?)), reported: Bool) {
    guard let resource = resource, let readingList = resource as? ReadingList else {
      return (false, nil, content: (nil, nil, nil, nil, nil, relatedContent: ([], 0), statistics: (nil, nil, nil), wit: (false, 0, nil)), false)
    }

    let cardPostInfoData: CardPostInfoNodeData?
    if let penName = resource.penName {
      let name = penName.name ?? ""
      let date = resource.createdAt?.formatted() ?? ""
      let penNameprofileImage = penName.avatarUrl
      cardPostInfoData = CardPostInfoNodeData(name, date, penNameprofileImage)
    } else {
      cardPostInfoData = nil
    }

    let infoNode: Bool = !(cardPostInfoData?.name.isEmpty ?? true)
    let title = resource.title
    let description = resource.shortDescription
    let comments: String? = nil
    let topComment: Comment? = resource.topComments?.first
    let tags = resource.tags?.flatMap({ $0.title })
    let posts = resource.counts?.posts
    let relatedBooks: Int? = nil
    let followers = resource.counts?.followers
    let statistics = (posts, relatedBooks, followers)
    let wit = (is: resource.isWitted, count: resource.counts?.wits ?? 0, resource.witters)

    let postsCount = readingList.postsRelations?.count ?? 0
    let images = readingList.posts?.flatMap({ ($0 as? ModelCommonProperties)?.thumbnailImageUrl }) ?? []
    let relatedContent = (images, postsCount)
    let reported: Bool = DataManager.shared.isReported(resource as? ModelResource)

    return (infoNode, cardPostInfoData, content: (title, description, topComment, comments, tags, relatedContent: relatedContent, statistics: statistics, wit: wit), reported: reported)
  }
}
