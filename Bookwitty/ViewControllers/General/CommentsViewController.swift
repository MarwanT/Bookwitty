//
//  CommentsViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 5/30/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class CommentsViewController: ASViewController<ASDisplayNode> {
  let commentsNode: CommentsNode
  
  init() {
    commentsNode = CommentsNode()
    super.init(node: commentsNode)
    commentsNode.delegate = self
  }
  
  func initialize(with commentManager: CommentManager) {
    commentsNode.initialize(with: commentManager)
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
  
  fileprivate func pushCommentsViewControllerForReplies(comment: Comment) {
    guard let commentIdentifier = comment.id else {
      return
    }
    
    let commentManager = CommentManager()
    commentManager.initialize(commentIdentifier: commentIdentifier)
    let commentsViewController = CommentsViewController()
    commentsViewController.initialize(with: commentManager)
    self.navigationController?.pushViewController(commentsViewController, animated: true)
  }
}

// MARK: - Comments node delegate
extension CommentsViewController: CommentsNodeDelegate {
  func commentsNode(_ commentsNode: CommentsNode, reactFor action: CommentsNode.Action) {
    switch action {
    case .viewRepliesForComment(let comment):
      pushCommentsViewControllerForReplies(comment: comment)
    case .writeComment(let parentCommentIdentifier):
      break // TODO: Trigger the writing a comment process
    }
  }
}
