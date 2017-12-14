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
  
  func initialize(with resource: ModelCommonProperties, parentComment: Comment? = nil) {
    commentsNode.initialize(with: resource, parentComment: parentComment)
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
  
  fileprivate func pushCommentsViewControllerForReplies(resource: ModelCommonProperties, parentComment: Comment) {
    let commentsViewController = CommentsViewController()
    commentsViewController.initialize(with: resource, parentComment: parentComment)
    self.navigationController?.pushViewController(commentsViewController, animated: true)
  }
}

// MARK: - Comments node delegate
extension CommentsViewController: CommentsNodeDelegate {

  func commentsNode(_ commentsNode: CommentsNode, reactFor action: CommentsNode.Action, didFinishAction: ((Bool) -> ())?) {
    switch action {
    case .viewReplies(let resource, let comment):
      pushCommentsViewControllerForReplies(resource: resource, parentComment: comment)
    case .viewAllComments:
      break
    case .writeComment(let resource, let parentComment):
      CommentComposerViewController.show(from: self, delegate: self, resource: resource, parentComment: parentComment)
    case .commentAction(let comment, let action, let resource, let parentComment):
      switch action {
      case .wit:
        commentsNode.wit(comment: comment, completion: {
          (success: Bool, _) in
          didFinishAction?(success)
        })
      case .unwit:
        commentsNode.unwit(comment: comment, completion: {
          (success: Bool, _) in
          didFinishAction?(success)
        })
      case .reply:
        CommentComposerViewController.show(from: self, delegate: self, resource: resource, parentComment: parentComment)
      default:
        break
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
