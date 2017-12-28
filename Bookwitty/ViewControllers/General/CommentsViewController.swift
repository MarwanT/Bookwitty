//
//  CommentsViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 5/30/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit
import SwiftLoader

class CommentsViewController: ASViewController<ASDisplayNode> {
  let commentsNode: CommentsNode
  fileprivate weak var viewModel: CommentsViewModel?
  
  init() {
    commentsNode = CommentsNode()
    super.init(node: commentsNode)
    commentsNode.delegate = self
  }
  
  func initialize(with resource: ModelCommonProperties, parentCommentIdentifier: String? = nil) {
    commentsNode.initialize(with: resource, parentCommentIdentifier: parentCommentIdentifier)
    viewModel = commentsNode.viewModel
    title = viewModel?.resourceExcerpt
    if isViewLoaded {
      reloadData()
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    reloadData()

    navigationItem.backBarButtonItem = UIBarButtonItem.back
  }
  
  func reloadData() {
    commentsNode.reloadData()
  }
  
  fileprivate func pushCommentsViewControllerForReplies(resource: ModelCommonProperties, parentCommentIdentifier: String) {
    let commentsViewController = CommentsViewController()
    commentsViewController.initialize(with: resource, parentCommentIdentifier: parentCommentIdentifier)
    self.navigationController?.pushViewController(commentsViewController, animated: true)
  }
  
  fileprivate func displayActionSheet(forComment identifier: String) {
    guard let availableActionsForComment = viewModel?.actions(forComment: identifier),
      availableActionsForComment.count > 0 else {
        return
    }
    
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
    
    for action in availableActionsForComment {
      guard let actionTitle = viewModel?.string(for: action) else { continue }
      let actionButton = UIAlertAction(title: actionTitle, style: .default, handler: { [action] (actionButton) in
        self.perform(action: action, onComment: identifier)
      })
      alertController.addAction(actionButton)
    }
    alertController.addAction(UIAlertAction(title: Strings.cancel(), style: UIAlertActionStyle.cancel, handler: nil))
    present(alertController, animated: true, completion: nil)
  }
  
  // TODO: Set a common method that perform comment action
  // And remove redundancy present in CommentsNodeDelegate implementation methods
  // TODO: Move the perform actions to "comments node"
  fileprivate func perform(action: CardActionBarNode.Action, onComment identifier: String) {
    guard let resource = commentsNode.viewModel.resource else {
      return
    }
    
    switch action {
    case .wit:
      commentsNode.wit(commentIdentifier: identifier, completion: nil)
    case .unwit:
      commentsNode.unwit(commentIdentifier: identifier, completion: nil)
    case .reply:
      let parentCommentIdentifier = commentsNode.viewModel.parentIdentifier(forCommentWithIdentifier: identifier, action: action)
      CommentComposerViewController.show(from: self, delegate: self, resource: resource, parentCommentIdentifier: parentCommentIdentifier)
    case .remove:
      commentsNode.removeComment(commentIdentifier: identifier, completion: nil)
    default:
      break
    }
  }
}

// MARK: - Comments node delegate
extension CommentsViewController: CommentsNodeDelegate {

  func commentsNode(_ commentsNode: CommentsNode, reactFor action: CommentsNode.Action, didFinishAction: ((Bool) -> ())?) {
    switch action {
    case .viewReplies(let resource, let parentCommentIdentifier):
      pushCommentsViewControllerForReplies(resource: resource, parentCommentIdentifier: parentCommentIdentifier)
      didFinishAction?(true)
    case .viewAllComments:
      didFinishAction?(true)
    case .writeComment(let resource, let parentCommentIdentifier):
      CommentComposerViewController.show(from: self, delegate: self, resource: resource, parentCommentIdentifier: parentCommentIdentifier)
      didFinishAction?(true)
    case .commentAction(let commentIdentifier, let action, let resource, let parentCommentIdentifier):
      switch action {
      case .wit:
        commentsNode.wit(commentIdentifier: commentIdentifier, completion: {
          (success: Bool, _) in
          didFinishAction?(success)
        })
      case .unwit:
        commentsNode.unwit(commentIdentifier: commentIdentifier, completion: {
          (success: Bool, _) in
          didFinishAction?(success)
        })
      case .reply:
        CommentComposerViewController.show(from: self, delegate: self, resource: resource, parentCommentIdentifier: commentIdentifier)
        didFinishAction?(true)
      case .more:
        displayActionSheet(forComment: commentIdentifier)
        didFinishAction?(true)
      default:
        didFinishAction?(true)
      }
    }
  }
}

// MARK: - Compose comment delegate implementation
extension CommentsViewController: CommentComposerViewControllerDelegate {
  func commentComposerCancel(_ viewController: CommentComposerViewController) {
    dismiss(animated: true, completion: nil)
  }
  
  func commentComposerWillBeginPublishingComment(_ viewController: CommentComposerViewController) {
    SwiftLoader.show(animated: true)
  }
  
  func commentComposerDidFinishPublishingComment(_ viewController: CommentComposerViewController, success: Bool, comment: Comment?, resource: ModelCommonProperties?) {
    SwiftLoader.hide()
    if success {
      self.dismiss(animated: true, completion: nil)
    }
  }
}
