//
//  CardPostInfoNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/11/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class CardPostInfoNode: ASCellNode {
  var userProfileImageNode: ASNetworkImageNode
  var arrowDownImageNode: ASImageNode
  var userNameTextNode: ASTextNode
  var postDateTextNode: ASTextNode


  private override init() {
    userProfileImageNode = ASNetworkImageNode()
    arrowDownImageNode = ASImageNode()
    userNameTextNode = ASTextNode()
    postDateTextNode = ASTextNode()
    super.init()
  }
}
