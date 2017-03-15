//
//  CardDetailsViewController.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/10/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import Spine
import Moya

class CardDetailsViewController: GenericNodeViewController {
  var viewModel: CardDetailsViewModel

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init(node: BaseCardPostNode, title: String? = nil, resource: ModelResource) {
    viewModel = CardDetailsViewModel(resource: resource)
    super.init(node: node, title: title)
    node.delegate = self
    node.updateDimVisibility(visible: true)
  }
}

// MARK - BaseCardPostNode Delegate
extension CardDetailsViewController: BaseCardPostNodeDelegate {
  func cardActionBarNode(card: BaseCardPostNode, cardActionBar: CardActionBarNode, didRequestAction action: CardActionBarNode.Action, forSender sender: ASButtonNode, didFinishAction: ((_ success: Bool) -> ())?) {
    switch(action) {
    case .wit:
      viewModel.witContent() { (success) in
        didFinishAction?(success)
      }
    case .unwit:
      viewModel.unwitContent() { (success) in
        didFinishAction?(success)
      }
    case .share:
      if let sharingInfo: [String] = viewModel.sharingContent() {
        presentShareSheet(shareContent: sharingInfo)
      }
    default:
      //TODO: handle comment
      break
    }
  }
}
