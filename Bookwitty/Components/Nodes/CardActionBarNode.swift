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

  let normal = ASControlState(rawValue: 0)
  let buttonHeight: CGFloat = 34.0

  private override init() {
    witButton = ASButtonNode()
    commentButton = ASButtonNode()
    shareButton = ASButtonNode()
    super.init()
    initializeNode()
    addSubnode(witButton)
    addSubnode(commentButton)
    addSubnode(shareButton)
  }

  private func initializeNode() {
    let imageTintColor: UIColor = ThemeManager.shared.currentTheme.colorNumber15()

    //Note: Had a Problem with the selected and highlighted states of the button images
    let commentImage: UIImage = UIImage(data: UIImagePNGRepresentation(#imageLiteral(resourceName: "comment"))!, scale: 3)!
    commentButton.imageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(imageTintColor)
    commentButton.setImage(commentImage, for: normal)

    let shareImage: UIImage = UIImage(data: UIImagePNGRepresentation(#imageLiteral(resourceName: "shareOutside"))!, scale: 3)!
    shareButton.imageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(imageTintColor)
    shareButton.setImage(shareImage, for: normal)
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
