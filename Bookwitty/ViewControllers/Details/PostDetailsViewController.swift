//
//  PostDetailsViewController.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/10/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class PostDetailsViewController: ASViewController<PostDetailsNode> {

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init(title: String? = nil, resource: Resource) {
    postDetailsNode = PostDetailsNode()
    super.init(node: postDetailsNode)
  }

}
