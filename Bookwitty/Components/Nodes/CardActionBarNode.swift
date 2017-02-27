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
  func cardActionBarNode(cardActionBar: CardActionBarNode, didRequestAction action: CardActionBarNode.Action, forSender sender: ASButtonNode, didFinishAction: ((_ success: Bool) -> ())?)
}

class CardActionBarNode: ASDisplayNode {
  enum Action {
    case wit
    case unwit
    case comment
    case share
  }
  var witButton: ASButtonNode
  var commentButton: ASButtonNode
  var shareButton: ASButtonNode
  var delegate: CardActionBarNodeDelegate? = nil

  private let witItButtonMargin = ThemeManager.shared.currentTheme.witItButtonMargin()
  private let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()

  private let normal = ASControlState(rawValue: 0)
  private let actionBarHeight: CGFloat = 60.0
  private let buttonSize: CGSize = CGSize(width: 36.0, height: 36.0)
  private let iconSize: CGSize = CGSize(width: 40.0, height: 40.0)
  //MARK: - Localized Strings
  private let witItTitle: String = localizedString(key: "wit_it", defaultValue: "Wit")
  private let wittedTitle: String = localizedString(key: "witted", defaultValue: "Witted")

  override init() {
    witButton = ASButtonNode()
    commentButton = ASButtonNode()
    shareButton = ASButtonNode()
    super.init()
    addSubnode(witButton)
    addSubnode(commentButton)
    addSubnode(shareButton)
    self.initializeNode()
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

    let buttonBackgroundImage = UIImage(color: ThemeManager.shared.currentTheme.defaultBackgroundColor())
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
    setNeedsLayout()
  }

  func witButtonTouchUpInside(_ sender: ASButtonNode?) {
    guard let sender = sender else { return }
    //Get action from witButton status
    let action = !witButton.isSelected ? CardActionBarNode.Action.wit : CardActionBarNode.Action.unwit
    //Assume success and Toggle button anyway, if witting/unwitting fails delegate should either call didFinishAction or  call toggleWitButton.
    toggleWitButton()

    delegate?.cardActionBarNode(cardActionBar: self, didRequestAction: action, forSender: sender, didFinishAction: { [weak self] (success: Bool) in
      guard let strongSelf = self else { return }
      if !success { //Toggle back on failure
        strongSelf.toggleWitButton()
      }
    })
  }

  func commentButtonTouchUpInside(_ sender: ASButtonNode?) {
    guard let sender = sender else { return }
    delegate?.cardActionBarNode(cardActionBar: self, didRequestAction: CardActionBarNode.Action.comment, forSender: sender, didFinishAction: nil)
  }

  func shareButtonTouchUpInside(_ sender: ASButtonNode?) {
    guard let sender = sender else { return }
    delegate?.cardActionBarNode(cardActionBar: self, didRequestAction: CardActionBarNode.Action.share, forSender: sender, didFinishAction: nil)
  }

  private func spacer(width: CGFloat = 0.0, flexGrow: CGFloat = 1.0) -> ASLayoutSpec {
    return ASLayoutSpec().styled { (style) in
      if(width == 0) {
        style.flexGrow = flexGrow
      }
      style.width = ASDimensionMake(width)
    }
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    //Setup Dynamic width Wit Button
    witButton.titleNode.maximumNumberOfLines = 1
    witButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    witButton.style.height = ASDimensionMake(buttonSize.height)

    //Setup other buttons
    commentButton.style.preferredSize = iconSize
    shareButton.style.preferredSize = iconSize

    let horizontalStackSpec = ASStackLayoutSpec(direction: .horizontal,
                                                spacing: 0,
                                                justifyContent: .spaceAround,
                                                alignItems: .stretch,
                                                children: [witButton,
                                                           spacer(),
                                                           commentButton,
                                                           spacer(width: 10),
                                                           shareButton])

    let centeredActionBarLayoutSpec = ASCenterLayoutSpec(centeringOptions: ASCenterLayoutSpecCenteringOptions.Y, sizingOptions: ASCenterLayoutSpecSizingOptions.minimumY, child: horizontalStackSpec)
    //Set Node Height
    centeredActionBarLayoutSpec.style.height = ASDimensionMake(actionBarHeight)

    //Set Node Insets
    return ASInsetLayoutSpec.init(insets: UIEdgeInsets.init(top: 0, left: internalMargin, bottom: 0, right: internalMargin), child: centeredActionBarLayoutSpec)
  }

}
