//
//  CardActionBarNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/11/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class CardActionBarNode: ASCellNode {

  var witButton: ASButtonNode
  var commentButton: ASButtonNode
  var shareButton: ASButtonNode

  let buttonHeight: CGFloat = 34.0

  private override init() {
    witButton = ASButtonNode()
    commentButton = ASButtonNode()
    shareButton = ASButtonNode()
    super.init()
    addSubnode(witButton)
    addSubnode(commentButton)
    addSubnode(shareButton)
  }

  private func spacer(flexGrow: CGFloat = 1.0) -> ASLayoutSpec {
    return ASLayoutSpec().styled { (style) in
      style.flexGrow = flexGrow
    }
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    //Setup Dynamic width Wit Button
    witButton.titleNode.maximumNumberOfLines = 1
    witButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    witButton.style.height = ASDimensionMake(buttonHeight)

    //Setup other buttons
    commentButton.style.preferredSize = CGSize(width: buttonHeight, height: buttonHeight)
    shareButton.style.preferredSize = CGSize(width: buttonHeight, height: buttonHeight)

    shareButton.style.spacingBefore = 50

    let horizontalStackSpec = ASStackLayoutSpec(direction: .horizontal,
                                                spacing: 0,
                                                justifyContent: .spaceAround,
                                                alignItems: .stretch,
                                                children: [witButton,
                                                           spacer(),
                                                           commentButton,
                                                           shareButton])

    return horizontalStackSpec
  }

}
