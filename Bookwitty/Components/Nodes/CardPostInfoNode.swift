//
//  CardPostInfoNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/11/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

typealias CardPostInfoNodeData = (name: String, imageUrl: String?, date: String)

class CardPostInfoNode: ASCellNode {
  var userProfileImageNode: ASNetworkImageNode
  var arrowDownImageNode: ASImageNode
  var userNameTextNode: ASTextNode
  var postDateTextNode: ASTextNode


  var data: CardPostInfoNodeData?

  private override init() {
    userProfileImageNode = ASNetworkImageNode()
    arrowDownImageNode = ASImageNode()
    userNameTextNode = ASTextNode()
    postDateTextNode = ASTextNode()
    super.init()
    addSubnode(userNameTextNode)
    addSubnode(postDateTextNode)
    addSubnode(userProfileImageNode)
    addSubnode(arrowDownImageNode)
  }

  convenience init(data: CardPostInfoNodeData) {
    self.init()
    self.data = data

    loadData()
  }

  private func loadData() {
    guard let data = data else {
      return
    }

    if !data.name.isEmpty {
      userNameTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .footnote).append(text: data.name).attributedString
    }

    if !data.date.isEmpty {
      postDateTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption2).append(text: data.date).attributedString
    }

    if let imageUrl = data.imageUrl, !imageUrl.isEmpty {
      userProfileImageNode.url = URL(string: imageUrl)
    }
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
