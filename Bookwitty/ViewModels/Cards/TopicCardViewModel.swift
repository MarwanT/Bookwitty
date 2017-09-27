//
//  TopicCardViewModel.swift
//  Bookwitty
//
//  Created by charles on 4/18/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

protocol TopicCardViewModelDelegate: class {
  func resourceUpdated(viewModel: TopicCardViewModel)
}

class TopicCardViewModel: CardViewModelProtocol {
  var resource: ModelCommonProperties? {
    didSet {
      notifyChange()
    }
  }

  weak var delegate: TopicCardViewModelDelegate?

  private func notifyChange() {
    delegate?.resourceUpdated(viewModel: self)
  }

  func values() -> (infoNode: Bool, postInfo: CardPostInfoNodeData?, content: (title: String?, description: String?, image: (cover: String?, thumbnail: String?), comments: String?, statistics: (posts: Int?, relatedBooks: Int?, followers: Int?), following: Bool, wit: (is: Bool, count: Int, info: String?)), reported: Bool) {
    guard let resource = resource else {
      return (false, nil, content: (nil, nil, image: (nil, nil), nil, statistics: (nil, nil, nil), false, wit: (false, 0, nil)), false)
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
    
    let title: String?
    switch resource {
    case is Author:
      title = (resource as? Author)?.name
    default:
       title = resource.title
    }

    let description = resource.shortDescription
    let imageUrl = resource.coverImageUrl
    let comments: String? = nil
    let posts = resource.counts?.posts
    let relatedBooks: Int? = nil
    let following = resource.following
    let followers = resource.counts?.followers
    let statistics = (posts, relatedBooks, followers)
    let wit = (is: resource.isWitted, count: resource.counts?.wits ?? 0, resource.witters)
    let reported: Bool = DataManager.shared.isReported(resource as? ModelResource)

    return (infoNode, cardPostInfoData, content: (title, description, image: (imageUrl, nil), comments, statistics: statistics, following, wit: wit), reported: reported)
  }
}
