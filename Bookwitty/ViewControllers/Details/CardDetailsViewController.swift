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
    super.init(node: node, title: nil)
    node.delegate = self
    node.updateMode(fullMode: true)
    node.updateDimVisibility(visible: true)
    viewControllerTitleForResouce(resource: resource)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.backBarButtonItem = UIBarButtonItem.back

    NotificationCenter.default.addObserver(self, selector:
      #selector(self.updatedResources(_:)), name: DataManager.Notifications.Name.UpdateResource, object: nil)
  }

  func updatedResources(_ notification: NSNotification) {
    guard let resourceId = viewModel.resource.id,
      let identifiers = notification.object as? [String],
      identifiers.count > 0,
      identifiers.contains( where: { $0 == resourceId } ) else {
        return
    }

    guard let resource = DataManager.shared.fetchResource(with: resourceId) as? ModelCommonProperties else {
        return
    }
    if let index = node.subnodes.index( where: { $0 is BaseCardPostNode } ) {
      if let card = node.subnodes[index] as? BaseCardPostNode {
        card.setWitValue(witted: resource.isWitted, wits: resource.counts?.wits ?? 0)
        card.setDimValue(dimmed: resource.isDimmed, dims: resource.counts?.dims ?? 0)
      }
    }
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
  func cardInfoNode(card: BaseCardPostNode, cardPostInfoNode: CardPostInfoNode, didRequestAction action: CardPostInfoNode.Action, forSender sender: Any) {
    if let resource = viewModel.resource as? ModelCommonProperties,
      let penName = resource.penName {
      pushProfileViewController(penName: penName)

      //MARK: [Analytics] Event
      let category: Analytics.Category
      switch resource.registeredResourceType {
      case Image.resourceType:
        category = .Image
      case Quote.resourceType:
        category = .Quote
      case Video.resourceType:
        category = .Video
      case Audio.resourceType:
        category = .Audio
      case Link.resourceType:
        category = .Link
      case Author.resourceType:
        category = .Author
      case ReadingList.resourceType:
        category = .ReadingList
      case Topic.resourceType:
        category = .Topic
      case Text.resourceType:
        category = .Text
      case Book.resourceType:
        category = .TopicBook
      case PenName.resourceType:
        category = .PenName
      default:
        category = .Default
      }

      let event: Analytics.Event = Analytics.Event(category: category,
                                                   action: .GoToPenName,
                                                   name: penName.name ?? "")
      Analytics.shared.send(event: event)
    } else if let penName = viewModel.resource as? PenName  {
      pushProfileViewController(penName: penName)
      
      //MARK: [Analytics] Event
      let event: Analytics.Event = Analytics.Event(category: .PenName,
                                                   action: .GoToDetails,
                                                   name: penName.name ?? "")
      Analytics.shared.send(event: event)
    }
  }
  
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

    //MARK: [Analytics] Event
    let category: Analytics.Category
    switch viewModel.resource.registeredResourceType {
    case Image.resourceType:
      category = .Image
    case Quote.resourceType:
      category = .Quote
    case Video.resourceType:
      category = .Video
    case Audio.resourceType:
      category = .Audio
    case Link.resourceType:
      category = .Link
    case Author.resourceType:
      category = .Author
    case ReadingList.resourceType:
      category = .ReadingList
    case Topic.resourceType:
      category = .Topic
    case Text.resourceType:
      category = .Text
    case Book.resourceType:
      category = .TopicBook
    case PenName.resourceType:
      category = .PenName
    default:
      category = .Default
    }

    let name: String = (viewModel.resource as? ModelCommonProperties)?.title ?? ""
    let analyticsAction = Analytics.Action.actionFrom(cardAction: action, with: category)
    let event: Analytics.Event = Analytics.Event(category: category,
                                                 action: analyticsAction,
                                                 name: name)
    Analytics.shared.send(event: event)
  }
}
