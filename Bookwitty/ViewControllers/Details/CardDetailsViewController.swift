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
import GSImageViewerController
import SwiftLoader

class CardDetailsViewController: GenericNodeViewController {
  var commentsNode: CommentsNode?
  
  var viewModel: CardDetailsViewModel

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init(node: BaseCardPostNode, title: String? = nil, resource: ModelResource, includeCommentsSection: Bool = true) {
    viewModel = CardDetailsViewModel(resource: resource)
    var containerNode: ASDisplayNode = node
    if let resource = resource as? ModelCommonProperties {
      let concatNode = CommentsNode.concatenate(with: node, resource: resource)
      containerNode = concatNode.wrapperNode
      commentsNode = concatNode.commentsNode
    }
    
    super.init(node: containerNode, title: nil)
    
    commentsNode?.delegate = self
    
    node.delegate = self
    node.updateMode(fullMode: true)
    node.shouldHandleTopComments = false

    if let photoNode = node as? PhotoCardPostCellNode {
      photoNode.node.delegate = self
    } else if let linkCard = node as? LinkCardPostCellNode {
      linkCard.node.tappableTitle = true
    } else if let videoCard = node as? VideoCardPostCellNode {
      videoCard.node.tappableTitle = true
    }

    loadTags(node: node)

    viewControllerAnalyticsScreenName(for: resource)
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

  func loadTags(node: BaseCardPostNode) {
    guard viewModel.tags?.count ?? 0 == 0 else {
      return
    }

    viewModel.loadTags { (success: Bool, error: BookwittyAPIError?) in
      node.tags = self.viewModel.tags
      node.setNeedsLayout()
    }
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
        card.setWitValue(witted: resource.isWitted)        
      }
    }
  }
  
  func pushCommentsViewController(with commentsManager: CommentsManager) {
    let commentsVC = CommentsViewController()
    commentsVC.initialize(with: commentsManager)
    self.navigationController?.pushViewController(commentsVC, animated: true)
  }
  
  func viewControllerAnalyticsScreenName(for resource: ModelResource) {

    //MARK: [Analytics] Screen Name
    let name: Analytics.ScreenName
    switch resource.registeredResourceType {
    case Image.resourceType:
      name = Analytics.ScreenNames.Image
    case Quote.resourceType:
      name = Analytics.ScreenNames.Quote
    case Video.resourceType:
      name = Analytics.ScreenNames.Video
    case Link.resourceType:
      name = Analytics.ScreenNames.Link
    case Author.resourceType:
      name = Analytics.ScreenNames.Author
    case ReadingList.resourceType:
      name = Analytics.ScreenNames.ReadingList
    case Topic.resourceType:
      name = Analytics.ScreenNames.Topic
    case Text.resourceType:
      name = Analytics.ScreenNames.Article
    case Book.resourceType:
      name = Analytics.ScreenNames.BookDetails
    default:
      name = Analytics.ScreenNames.Default
    }

    Analytics.shared.send(screenName: name)
  }
}

// MARK - BaseCardPostNode Delegate
extension CardDetailsViewController: BaseCardPostNodeDelegate {

  private func userProfileHandler() {
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

  private func actionInfoHandler() {
    guard let resource = viewModel.resource else {
      return
    }

    pushPenNamesListViewController(with: resource)
  }

  func cardInfoNode(card: BaseCardPostNode, cardPostInfoNode: CardPostInfoNode, didRequestAction action: CardPostInfoNode.Action, forSender sender: Any) {
    switch action {
    case .userProfile:
      userProfileHandler()
    case .actionInfo:
      actionInfoHandler()
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
    case .comment:
      pushCommentsViewController(for: viewModel.resource as? ModelCommonProperties)
      didFinishAction?(true)
    case .more:
      guard let resource = viewModel.resource as? ModelCommonProperties,
        let identifier = resource.id else { return }
      self.showMoreActionSheet(identifier: identifier, actions: [.report(.content)], completion: { (success: Bool) in
        didFinishAction?(success)
      })
    default:
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

  func cardNode(card: BaseCardPostNode, didRequestAction action: BaseCardPostNode.Action, from: ASDisplayNode) {
    //Empty Implementation 
    /* Discussion
     * Top Comment Node Is Not Visible Here
     */
  }

  func cardNode(card: BaseCardPostNode, didSelectTagAt index: Int) {
    guard let tags = (self.viewModel.resource as? ModelCommonProperties)?.tags else {
      return
    }

    guard index >= 0 && index < tags.count else {
      return
    }

    let tag = tags[index]

    let tagController = TagFeedViewController()
    tagController.viewModel.tag = tag
    self.navigationController?.pushViewController(tagController, animated: true)
  }
}

extension CardDetailsViewController: PhotoCardContentNodeDelegate {
  func photoCard(node: PhotoCardContentNode, requestToViewImage image: UIImage, from imageNode: ASNetworkImageNode) {
    let imageInfo = GSImageInfo(image: image, imageMode: .aspectFit, imageHD: nil)
    let transitionInfo = GSTransitionInfo(fromView: imageNode.view)
    let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
    present(imageViewer, animated: true, completion: nil)

  }
}

extension CardDetailsViewController: CommentsNodeDelegate {
  func commentsNode(_ commentsNode: CommentsNode, reactFor action: CommentsNode.Action, didFinishAction: ((Bool) -> ())?) {
    switch action {
    case .viewRepliesForComment(let comment, let postId):
      break
    case .viewAllComments(let commentsManager):
      pushCommentsViewController(with: commentsManager)
    case .writeComment(let commentsManager):
      CommentComposerViewController.show(from: self, commentsManager: commentsManager, delegate: self)
    case .commentAction(let comment, let action, let resource):
      switch action {
      case .wit:
        commentsNode.wit(comment: comment, completion: nil)
      case .unwit:
        commentsNode.unwit(comment: comment, completion: nil)
      case .reply:
        let commentsManager = CommentsManager()
        commentsManager.initialize(resource: resource, comment: comment)
        CommentComposerViewController.show(from: self, commentsManager: commentsManager, delegate: self)
      default:
        break
      }
    }
  }
}

// MARK: - Compose comment delegate implementation
extension CardDetailsViewController: CommentComposerViewControllerDelegate {
  func commentComposerCancel(_ viewController: CommentComposerViewController) {
    dismiss(animated: true, completion: nil)
  }
}
