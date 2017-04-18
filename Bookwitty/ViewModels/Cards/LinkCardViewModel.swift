//
//  LinkCardViewModel.swift
//  Bookwitty
//
//  Created by charles on 4/18/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

protocol LinkCardViewModelDelegate: class {
  func resourceUpdated(viewModel: LinkCardViewModel)
}

class LinkCardViewModel {
  var resource: ModelCommonProperties? {
    didSet {
      notifyChange()
    }
  }

  weak var delegate: LinkCardViewModelDelegate?

  private func notifyChange() {
    delegate?.resourceUpdated(viewModel: self)
  }

  func values() -> (infoNode: Bool, postInfo: CardPostInfoNodeData?, content: (title: String?, description: String?, linkUrl: String?, imageUrl: String?, comments: String?, wit: (is: Bool, count: Int), dim: (is: Bool, count: Int))) {
    guard let resource = resource, let link = resource as? Link else {
      return (false, nil, content: (nil, nil, nil, nil, nil, wit: (false, 0), dim: (false, 0)))
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

    let infoNode: Bool = !(cardPostInfoData?.name.isEmpty ?? true)
    let title = resource.title
    let description = resource.shortDescription
    let imageUrl = resource.coverImageUrl
    let comments: String? = nil
    let linkUrl = link.urlLink
    let wit = (is: resource.isWitted, count: resource.counts?.wits ?? 0)
    let dim = (is: resource.isDimmed, count: resource.counts?.dims ?? 0)

    return (infoNode, cardPostInfoData, content: (title, description, linkUrl, imageUrl, comments, wit: wit, dim: dim))
  }
}
