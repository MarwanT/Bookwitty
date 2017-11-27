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
  
  init() {
    commentsNode = CommentsNode()
    super.init(node: commentsNode)
    commentsNode.delegate = self
  }
  
  func initialize(with commentsManager: CommentsManager) {
    commentsNode.initialize(with: commentsManager)
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
  
  fileprivate func pushCommentsViewControllerForReplies(comment: Comment, resource: ModelCommonProperties?) {
    let commentsManager = CommentsManager()
    commentsManager.initialize(resource: resource, comment: comment)
    let commentsViewController = CommentsViewController()
    commentsViewController.initialize(with: commentsManager)
    self.navigationController?.pushViewController(commentsViewController, animated: true)
  }
}

// MARK: - Comments node delegate
extension CommentsViewController: CommentsNodeDelegate {

  func commentsNode(_ commentsNode: CommentsNode, reactFor action: CommentsNode.Action, didFinishAction: ((Bool) -> ())?) {
    switch action {
    case .viewRepliesForComment(let comment, let resource):
      pushCommentsViewControllerForReplies(comment: comment, resource: resource)
    case .viewAllComments(let commentsManager):
      break
    case .writeComment(let commentManager):
      CommentComposerViewController.show(from: self, commentsManager: commentManager, delegate: self)
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
extension CommentsViewController: CommentComposerViewControllerDelegate {
  func commentComposerCancel(_ viewController: CommentComposerViewController) {
    dismiss(animated: true, completion: nil)
  }
}
