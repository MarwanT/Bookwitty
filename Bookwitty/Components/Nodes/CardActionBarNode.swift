//
//  CardActionBarNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/11/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol CardActionBarNodeDelegate {
  func witButtonTouchUpInside(sender: ASButtonNode)
  func commentButtonTouchUpInside(sender: ASButtonNode)
  func shareButtonTouchUpInside(sender: ASButtonNode)
}

class CardActionBarNode: ASCellNode {

  var witButton: ASButtonNode
  var commentButton: ASButtonNode
  var shareButton: ASButtonNode
  var delegate: CardActionBarNodeDelegate? = nil

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

    setupWitButtonStyling()

    shareButton.addTarget(self, action: #selector(shareButtonTouchUpInside(_:)), forControlEvents: .touchUpInside)
    commentButton.addTarget(self, action: #selector(commentButtonTouchUpInside(_:)), forControlEvents: .touchUpInside)
    witButton.addTarget(self, action: #selector(witButtonTouchUpInside(_:)), forControlEvents: .touchUpInside)
  }

  func setupWitButtonStyling() {
    let buttonFont = FontDynamicType.subheadline.font

    let buttonBackgroundImage = UIImage(color: ThemeManager.shared.currentTheme.defaultButtonColor())
    let textColor = ThemeManager.shared.currentTheme.colorNumber23()

    let selectedBackgroundColor = ThemeManager.shared.currentTheme.colorNumber23()
    let selectedTextColor = ThemeManager.shared.currentTheme.defaultButtonColor()
    let selectedButtonBackgroundImage = UIImage(color: selectedBackgroundColor)

    witButton.setBackgroundImage(buttonBackgroundImage, for: normal)
    witButton.setBackgroundImage(selectedButtonBackgroundImage, for: .selected)

    witButton.setTitle("Wit it", with: buttonFont, with: textColor, for: normal)
    witButton.setTitle("Witted", with: buttonFont, with: selectedTextColor, for: .selected)

    witButton.cornerRadius = 4
    witButton.borderColor = ThemeManager.shared.currentTheme.defaultButtonColor().cgColor
    witButton.clipsToBounds = true
  }

  func updateButtonStyle(selected: Bool) {
    if(selected) {
      witButton.borderWidth = 0
    } else {
      witButton.borderWidth = 2
    }
  }

  func witButtonTouchUpInside(_ sender: ASButtonNode?) {
    guard let button = sender else { return }
    //TODO: Delegate action and wait for delegate callback confromation to update ui.
    if (!button.isSelected) {
      button.isSelected = true
    } else {
      button.isSelected = false
    }
    updateButtonStyle(selected: isSelected)
  }

  func commentButtonTouchUpInside(_ sender: ASButtonNode?) {
    //TODO: delegate action
  }

  func shareButtonTouchUpInside(_ sender: ASButtonNode?) {
    //TODO: delegate action
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
