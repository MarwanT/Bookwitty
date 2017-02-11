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
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    //Add the User Profile Image - Vertical Stack [Name - Date] - Image ArrowDown
    let verticalStack = ASStackLayoutSpec.vertical()
    verticalStack.style.flexShrink = 1.0
    verticalStack.style.flexGrow = 1.0
    verticalStack.justifyContent = .center
    verticalStack.alignItems = .start
    verticalStack.children = [userNameTextNode, postDateTextNode]

    let horizontalStackSpec = ASStackLayoutSpec(direction: .horizontal,
                                                      spacing: 10,
                                                      justifyContent: .center,
                                                      alignItems: .stretch,
                                                      children: [userProfileImageNode, verticalStack, arrowDownImageNode])

    return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: horizontalStackSpec)
  }

}
