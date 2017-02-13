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
  func cardActionBarNode(card: CardActionBarNode, didRequestAction action: CardActionBarNode.Action, forSender sender: ASButtonNode)
}

class CardActionBarNode: ASDisplayNode {
  enum Action {
    case wit
    case comment
    case share
  }
  var witButton: ASButtonNode
  var commentButton: ASButtonNode
  var shareButton: ASButtonNode
  var delegate: CardActionBarNodeDelegate? = nil

  private let normal = ASControlState(rawValue: 0)
  private let buttonSize: CGSize = CGSize(width: 34.0, height: 34.0)
  //MARK: - Localized Strings
  private let witItTitle: String = localizedString(key: "wit_it", defaultValue: "Wit it")
  private let wittedTitle: String = localizedString(key: "witted", defaultValue: "Witted")

  private override init() {
    witButton = ASButtonNode()
    commentButton = ASButtonNode()
    shareButton = ASButtonNode()
    super.init()
    addSubnode(witButton)
    addSubnode(commentButton)
    addSubnode(shareButton)
  }

  convenience init(delegate: CardActionBarNodeDelegate?) {
    self.init()
    self.initializeNode()
    self.delegate = delegate
  }

  private func initializeNode() {
    let imageTintColor: UIColor = ThemeManager.shared.currentTheme.colorNumber15()

    //Note: Had a Problem with the selected and highlighted states of the button images
    commentButton.imageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(imageTintColor)
    commentButton.setImage(#imageLiteral(resourceName: "comment"), for: normal)

    shareButton.imageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(imageTintColor)
    shareButton.setImage(#imageLiteral(resourceName: "shareOutside"), for: normal)

    setupWitButtonStyling()

    shareButton.addTarget(self, action: #selector(shareButtonTouchUpInside(_:)), forControlEvents: .touchUpInside)
    commentButton.addTarget(self, action: #selector(commentButtonTouchUpInside(_:)), forControlEvents: .touchUpInside)
    witButton.addTarget(self, action: #selector(witButtonTouchUpInside(_:)), forControlEvents: .touchUpInside)
  }

  private func setupWitButtonStyling() {
    let buttonFont = FontDynamicType.subheadline.font

    let buttonBackgroundImage = UIImage(color: ThemeManager.shared.currentTheme.colorNumber23())
    let textColor = ThemeManager.shared.currentTheme.defaultButtonColor()

    let selectedTextColor = ThemeManager.shared.currentTheme.colorNumber23()
    let selectedButtonBackgroundImage = UIImage(color: ThemeManager.shared.currentTheme.defaultButtonColor())

    witButton.setBackgroundImage(buttonBackgroundImage, for: normal)
    witButton.setBackgroundImage(selectedButtonBackgroundImage, for: .selected)

    witButton.setTitle(witItTitle, with: buttonFont, with: textColor, for: normal)
    witButton.setTitle(wittedTitle, with: buttonFont, with: selectedTextColor, for: .selected)

    witButton.cornerRadius = 4
    witButton.borderColor = ThemeManager.shared.currentTheme.defaultButtonColor().cgColor
    witButton.borderWidth = 2
    witButton.clipsToBounds = true
  }

  func toggleWitButton() {
    witButton.isSelected = !witButton.isSelected
  }

  func witButtonTouchUpInside(_ sender: ASButtonNode?) {
    guard let sender = sender else { return }
    delegate?.cardActionBarNode(card: self, didRequestAction: CardActionBarNode.Action.wit, forSender: sender)
    //TODO: Remove line and instead call toggleWitButton when Wit is successful
    toggleWitButton()
  }

  func commentButtonTouchUpInside(_ sender: ASButtonNode?) {
    guard let sender = sender else { return }
    delegate?.cardActionBarNode(card: self, didRequestAction: CardActionBarNode.Action.comment, forSender: sender)
  }

  func shareButtonTouchUpInside(_ sender: ASButtonNode?) {
    guard let sender = sender else { return }
    delegate?.cardActionBarNode(card: self, didRequestAction: CardActionBarNode.Action.share, forSender: sender)
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
    witButton.style.height = ASDimensionMake(buttonSize.height)

    //Setup other buttons
    commentButton.style.preferredSize = buttonSize
    shareButton.style.preferredSize = buttonSize

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
