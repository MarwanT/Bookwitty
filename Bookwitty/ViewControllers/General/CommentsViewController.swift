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
}
