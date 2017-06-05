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

  func values() -> (infoNode: Bool, postInfo: CardPostInfoNodeData?, content: (quote: String?, publisher: String?, comments: String?, wit: (is: Bool, count: Int), dim: (is: Bool, count: Int))) {
    guard let resource = resource, let quote = resource as? Quote else {
      return (false, nil, content: (nil, nil, nil, wit: (false, 0), dim: (false, 0)))
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
    let wit = (is: resource.isWitted, count: resource.counts?.wits ?? 0)
    let dim = (is: resource.isDimmed, count: resource.counts?.dims ?? 0)

    return (infoNode, cardPostInfoData, content: (body, publisher, comments, wit: wit, dim: dim))
  }
}
