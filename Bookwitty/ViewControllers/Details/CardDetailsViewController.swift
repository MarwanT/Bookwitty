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
    viewControllerTitleForResouce(resource: resource)
  }
  
  func viewControllerTitleForResouce(resource: ModelResource) {

    //MARK: [Analytics] Screen Name
    let name: Analytics.ScreenName
    switch resource.registeredResourceType {
    case Image.resourceType:
      title = Strings.image()
      name = Analytics.ScreenNames.Image
    case Quote.resourceType:
      title = Strings.quote()
      name = Analytics.ScreenNames.Quote
    case Video.resourceType:
      title = Strings.video()
      name = Analytics.ScreenNames.Video
    case Link.resourceType:
      title = Strings.link()
      name = Analytics.ScreenNames.Link
    case Author.resourceType:
      title = Strings.author()
      name = Analytics.ScreenNames.Author
    case ReadingList.resourceType:
      title = Strings.reading_list()
      name = Analytics.ScreenNames.ReadingList
    case Topic.resourceType:
      title = Strings.topic()
      name = Analytics.ScreenNames.Topic
    case Text.resourceType:
      title = Strings.article()
      name = Analytics.ScreenNames.Article
    case Book.resourceType:
      title = Strings.book()
      name = Analytics.ScreenNames.BookDetails
    default:
      title = nil
      name = Analytics.ScreenNames.Default
    }

    Analytics.shared.send(screenName: name)
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
    case .dim:
      viewModel.dimContent(completionBlock: { (success) in
        didFinishAction?(success)
      })
    case .undim:
      viewModel.undimContent(completionBlock: { (success) in
        didFinishAction?(success)
      })
    case .share:
      if let sharingInfo: [String] = viewModel.sharingContent() {
        presentShareSheet(shareContent: sharingInfo)
      }
    case .follow:
      viewModel.follow() { (success) in
        didFinishAction?(success)
      }
    case .unfollow:
      viewModel.unfollow() { (success) in
        didFinishAction?(success)
      }
    default:
      //TODO: handle comment
      break
    }
  }
}
