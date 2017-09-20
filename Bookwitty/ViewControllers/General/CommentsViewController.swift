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
  }
  
  func reloadData() {
    commentsNode.reloadData()
  }
  
  fileprivate func pushCommentsViewControllerForReplies(comment: Comment, postId: String) {
    let commentsManager = CommentsManager()
    commentsManager.initialize(postIdentifier: postId, comment: comment)
    let commentsViewController = CommentsViewController()
    commentsViewController.initialize(with: commentsManager)
    self.navigationController?.pushViewController(commentsViewController, animated: true)
  }
}

// MARK: - Comments node delegate
extension CommentsViewController: CommentsNodeDelegate {

  func commentsNode(_ commentsNode: CommentsNode, reactFor action: CommentsNode.Action, didFinishAction: ((Bool) -> ())?) {
    switch action {
    case .viewRepliesForComment(let comment, let postId):
      pushCommentsViewControllerForReplies(comment: comment, postId: postId)
    case .viewAllComments(let commentsManager):
      break
    case .writeComment(let parentCommentIdentifier, _):
      CommentComposerViewController.show(from: self, delegate: self, postId: nil, parentCommentId: parentCommentIdentifier)
    case .commentAction(let comment, let action):
      switch action {
      case .wit:
        commentsNode.wit(comment: comment, completion: nil)
      case .unwit:
        commentsNode.unwit(comment: comment, completion: nil)
      case .reply:
        CommentComposerViewController.show(from: self, delegate: self, postId: nil, parentCommentId: comment.id)
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
  
  func commentComposerPublish(_ viewController: CommentComposerViewController, content: String?, postId: String?, parentCommentId: String?) {
    SwiftLoader.show(animated: true)
    commentsNode.publishComment(content: content, parentCommentId: parentCommentId) {
      (success, error) in
      SwiftLoader.hide()
      guard success else {
        if let error = error {
          self.showAlertWith(title: error.title ?? "", message: error.message ?? "", handler: {
            (_) in
            // Restart editing the comment
            _ = viewController.becomeFirstResponder()
          })
        }
        return
      }
      
      self.dismiss(animated: true, completion: nil)
    }
  }
}
