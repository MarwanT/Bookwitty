//
//  QuoteCardViewModel.swift
//  Bookwitty
//
//  Created by charles on 4/18/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

protocol QuoteCardViewModelDelegate: class {
  func resourceUpdated(viewModel: QuoteCardViewModel)
}

class QuoteCardViewModel: CardViewModelProtocol {
  var resource: ModelCommonProperties? {
    didSet {
      notifyChange()
    }
  }

  weak var delegate: QuoteCardViewModelDelegate?

  private func notifyChange() {
    delegate?.resourceUpdated(viewModel: self)
  }

  func values() -> (infoNode: Bool, postInfo: CardPostInfoNodeData?, content: (quote: String?, publisher: String?, topComment: Comment?, comments: String?, tags: [String]?, wit: (is: Bool, count: Int, info: String?)), reported: Reported) {
    guard let resource = resource, let quote = resource as? Quote else {
      return (false, nil, content: (nil, nil, nil, nil, nil, wit: (false, 0, nil)), .not)
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
    
    var body: String? = nil
    if !quote.body.isEmptyOrNil() {
      body = quote.body
    } else if !quote.title.isEmptyOrNil() {
      body = quote.title
    }

    let publisher: String? = quote.author
    let comments: String? = nil
    let topComment: Comment? = resource.topComments?.first
    let tags = resource.tags?.flatMap({ $0.title })
    let wit = (is: resource.isWitted, count: resource.counts?.wits ?? 0, resource.witters)
    let reported: Reported = DataManager.shared.isReported(resource as? ModelResource)

    return (infoNode, cardPostInfoData, content: (body, publisher, topComment, comments, tags, wit: wit), reported: reported)
  }
}
