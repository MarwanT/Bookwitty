//
//  PhotoCardViewModel.swift
//  Bookwitty
//
//  Created by charles on 4/18/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

protocol PhotoCardViewModelDelegate: class {
  func resourceUpdated(viewModel: PhotoCardViewModel)
}

class PhotoCardViewModel: CardViewModelProtocol {
  var resource: ModelCommonProperties? {
    didSet {
      notifyChange()
    }
  }

  weak var delegate: PhotoCardViewModelDelegate?

  private func notifyChange() {
    delegate?.resourceUpdated(viewModel: self)
  }

  func values() -> (infoNode: Bool, postInfo: CardPostInfoNodeData?, content: (title: String?, description: String?, imageUrl: String?, comments: String?, wit: (is: Bool, count: Int, info: String?))) {
    guard let resource = resource else {
      return (false, nil, content: (nil, nil, nil, nil, wit: (false, 0, nil)))
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
    let imageUrl = resource.coverImageUrl
    let comments: String? = nil
    let wit = (is: resource.isWitted, count: resource.counts?.wits ?? 0, resource.witters)

    return (infoNode, cardPostInfoData, content: (title, description, imageUrl, comments, wit: wit))
  }
}
