//
//  CardActionBarNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/11/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol CardActionBarNodeDelegate: class {
  func cardActionBarNode(cardActionBar: CardActionBarNode, didRequestAction action: CardActionBarNode.Action, forSender sender: ASButtonNode, didFinishAction: ((_ success: Bool) -> ())?)
}

class CardActionBarNode: ASCellNode {
  enum Action {
    case wit
    case unwit
    case comment
    case share
    case dim
    case undim
    case follow
    case unfollow
  }
  var followButton: ASButtonNode
  var witButton: ASButtonNode
  var commentButton: ASButtonNode
  var shareButton: ASButtonNode
  var numberOfWitsNode: ASTextNode
  var numberOfDimsNode: ASTextNode
  weak var delegate: CardActionBarNodeDelegate? = nil

  fileprivate var numberOfWits: Int? {
    didSet {
      if let numberOfWits = numberOfWits, numberOfWits > 0 {
        numberOfWitsNode.attributedText = AttributedStringBuilder(fontDynamicType: FontDynamicType.caption1)
          .append(text: "(\(numberOfWits))", color: ThemeManager.shared.currentTheme.defaultButtonColor()).attributedString
      } else {
        numberOfWitsNode.attributedText = nil
      }
    }
  }
  fileprivate var numberOfDims: Int? {
    didSet {
      numberOfDimsNode.isHidden = hideDim
      guard !hideDim else {
        return
      }

      if let numberOfDims = numberOfDims {
        let fontDynamicType = FontDynamicType.footnote
        numberOfDimsNode.attributedText = AttributedStringBuilder(fontDynamicType: fontDynamicType)
          .append(text: dimText, color: ThemeManager.shared.currentTheme.defaultGrayedTextColor())
          .append(text: " ")
          .append(text: "(\(numberOfDims))", fontDynamicType: FontDynamicType.caption1, color: ThemeManager.shared.currentTheme.defaultGrayedTextColor()).attributedString
      } else {
        numberOfDimsNode.attributedText = nil
      }
    }
  }
  fileprivate var dimText: String {
    return numberOfDimsNode.isSelected ? Strings.dimmed() : Strings.dim()
  }
  fileprivate var actionButton: ASButtonNode {
    return followingMode ? followButton : witButton
  }
  fileprivate var followingMode: Bool = false {
    didSet {
      setNeedsLayout()
    }
  }
  private let witItButtonMargin = ThemeManager.shared.currentTheme.witItButtonMargin()
  private let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()

  private let actionBarHeight: CGFloat = 60.0
  private let buttonSize: CGSize = CGSize(width: 36.0, height: 36.0)
  private let iconSize: CGSize = CGSize(width: 40.0, height: 40.0)

  var hideDim: Bool = false {
    didSet {
      numberOfDimsNode.isHidden = hideDim
      setNeedsLayout()
    }
  }

  override init() {
    witButton = ASButtonNode()
    commentButton = ASButtonNode()
    shareButton = ASButtonNode()
    numberOfWitsNode = ASTextNode()
    numberOfDimsNode = ASTextNode()
    followButton = ASButtonNode()
    super.init()
    self.initializeNode()
  }

  func setup(forFollowingMode followingMode: Bool) {
    self.followingMode = followingMode
  }

  private func initializeNode() {
    automaticallyManagesSubnodes = true
    
    let imageTintColor: UIColor = ThemeManager.shared.currentTheme.colorNumber15()

    //Note: Had a Problem with the selected and highlighted states of the button images
    commentButton.imageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(imageTintColor)
    commentButton.setImage(#imageLiteral(resourceName: "comment"), for: .normal)
    commentButton.isHidden = true

    shareButton.imageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(imageTintColor)
    shareButton.setImage(#imageLiteral(resourceName: "shareOutside"), for: .normal)

    setupWitButtonStyling()
    setupFollowButtonStyling()

    shareButton.addTarget(self, action: #selector(shareButtonTouchUpInside(_:)), forControlEvents: .touchUpInside)
    commentButton.addTarget(self, action: #selector(commentButtonTouchUpInside(_:)), forControlEvents: .touchUpInside)
    witButton.addTarget(self, action: #selector(witButtonTouchUpInside(_:)), forControlEvents: .touchUpInside)
    followButton.addTarget(self, action: #selector(followButtonTouchUpInside(_:)), forControlEvents: .touchUpInside)
    numberOfDimsNode.addTarget(self, action: #selector(dimButtonTouchUpInside(_:)), forControlEvents: .touchUpInside)

    numberOfWitsNode.style.maxWidth = ASDimensionMake(60.0)
    numberOfWitsNode.maximumNumberOfLines = 1
    numberOfDimsNode.style.maxWidth = ASDimensionMake(120.0)
    numberOfDimsNode.maximumNumberOfLines = 1

    numberOfWitsNode.truncationMode = NSLineBreakMode.byTruncatingTail
    numberOfDimsNode.truncationMode = NSLineBreakMode.byTruncatingTail

    //By default dim info should be hidden, needs to be explicitly set false to show
    hideDim = true
  }

  private func setupFollowButtonStyling() {
    let buttonFont = FontDynamicType.subheadline.font

    let buttonBackgroundImage = UIImage(color: ThemeManager.shared.currentTheme.defaultBackgroundColor())
    let textColor = ThemeManager.shared.currentTheme.defaultButtonColor()

    let selectedTextColor = ThemeManager.shared.currentTheme.colorNumber23()
    let selectedButtonBackgroundImage = UIImage(color: ThemeManager.shared.currentTheme.defaultButtonColor())

    followButton.setBackgroundImage(buttonBackgroundImage, for: .normal)
    followButton.setBackgroundImage(selectedButtonBackgroundImage, for: .selected)

    followButton.setTitle(Strings.follow(), with: buttonFont, with: textColor, for: .normal)
    followButton.setTitle(Strings.following(), with: buttonFont, with: selectedTextColor, for: .selected)

    followButton.cornerRadius = 2.0
    followButton.borderColor = ThemeManager.shared.currentTheme.defaultButtonColor().cgColor
    followButton.borderWidth = 2
    followButton.clipsToBounds = true
  }

  private func setupWitButtonStyling() {
    let buttonFont = FontDynamicType.subheadline.font

    let buttonBackgroundImage = UIImage(color: ThemeManager.shared.currentTheme.defaultBackgroundColor())
    let textColor = ThemeManager.shared.currentTheme.defaultButtonColor()

    let selectedTextColor = ThemeManager.shared.currentTheme.colorNumber23()
    let selectedButtonBackgroundImage = UIImage(color: ThemeManager.shared.currentTheme.defaultButtonColor())

    witButton.setBackgroundImage(buttonBackgroundImage, for: .normal)
    witButton.setBackgroundImage(selectedButtonBackgroundImage, for: .selected)

    witButton.setTitle(Strings.wit_it(), with: buttonFont, with: textColor, for: .normal)
    witButton.setTitle(Strings.witted(), with: buttonFont, with: selectedTextColor, for: .selected)

    witButton.cornerRadius = 2.0
    witButton.borderColor = ThemeManager.shared.currentTheme.defaultButtonColor().cgColor
    witButton.borderWidth = 2
    witButton.clipsToBounds = true
  }

  func setFollowingValue(following: Bool) {
    followButton.isSelected = following
  }

  func setWitButton(witted: Bool, wits: Int? = nil) {
    witButton.isSelected = witted
    setNumberOfWits(wits: wits ?? 0)
  }

  func setDimValue(dimmed: Bool, dims: Int? = nil) {
    numberOfDimsNode.isSelected = dimmed
    setNumberOfDims(dims: dims ?? 0)
  }

  private func setNumberOfWits(wits: Int) {
    numberOfWits = wits
  }

  private func setNumberOfDims(dims: Int) {
    numberOfDims = dims
  }

  func updateWitAndDim(for action: Action, success: Bool = true) {
    let inverter = success ? 1 : -1

    switch action {
    case .dim:
      let wits: Int? = (numberOfWits ?? 0 > 0) ? (numberOfWits! + (-1 * inverter)) : nil
      setWitButton(witted: false, wits: wits)
      let dims: Int? = (numberOfDims ?? 0) + (1 * inverter)
      setDimValue(dimmed: success, dims: dims)

    case .undim:
      let dims: Int? = (numberOfDims ?? 0 > 0) ? (numberOfDims! + (-1 * inverter)) : nil
      setDimValue(dimmed: false, dims: dims)

    case .wit:
      let dims: Int? = (numberOfDims ?? 0 > 0) ? (numberOfDims! + (-1 * inverter)) : nil
      setDimValue(dimmed: false, dims: dims)
      let wits: Int? = (numberOfWits ?? 0) + (1 * inverter)
      setWitButton(witted: success, wits: wits)

    case .unwit:
      let wits: Int? = (numberOfWits ?? 0 > 0) ? (numberOfWits! + (-1 * inverter)) : nil
      setWitButton(witted: false, wits: wits)

    default: break
    }
  }

  func updateFollow(for action: Action, success: Bool = true) {
    switch action {
    case .follow:
      followButton.isSelected = success
    case .unfollow:
      followButton.isSelected = !success
    default: break
    }
  }

  func dimButtonTouchUpInside(_ sender: ASTextNode?) {
    guard UserManager.shared.isSignedIn else {
      //If user is not signed In post notification and do not fall through
      NotificationCenter.default.post( name: AppNotification.callToAction, object: CallToAction.dim)
      return
    }

    let action = !numberOfDimsNode.isSelected ? CardActionBarNode.Action.dim : CardActionBarNode.Action.undim
    self.updateWitAndDim(for: action)
    self.witButton.isEnabled = false
    self.numberOfDimsNode.isEnabled = false

    delegate?.cardActionBarNode(cardActionBar: self, didRequestAction: action, forSender: witButton, didFinishAction: { [weak self] (success: Bool) in
      guard let strongSelf = self else { return }
      if !success { //Toggle back on failure
        strongSelf.updateWitAndDim(for: action, success: false)
      }
      strongSelf.witButton.isEnabled = true
      strongSelf.numberOfDimsNode.isEnabled = true
    })
  }

  func witButtonTouchUpInside(_ sender: ASButtonNode?) {
    guard UserManager.shared.isSignedIn else {
      //If user is not signed In post notification and do not fall through
      NotificationCenter.default.post( name: AppNotification.callToAction, object: CallToAction.wit)
      return
    }

    guard let sender = sender else { return }
    //Get action from witButton status
    let action = !witButton.isSelected ? CardActionBarNode.Action.wit : CardActionBarNode.Action.unwit
    //Assume success and Toggle button anyway, if witting/unwitting fails delegate should either call didFinishAction or  call toggleWitButton.
    self.updateWitAndDim(for: action)
    self.witButton.isEnabled = false
    self.numberOfDimsNode.isEnabled = false

    delegate?.cardActionBarNode(cardActionBar: self, didRequestAction: action, forSender: sender, didFinishAction: { [weak self] (success: Bool) in
      guard let strongSelf = self else { return }
      if !success { //Toggle back on failure
        strongSelf.updateWitAndDim(for: action, success: false)
      }
      strongSelf.witButton.isEnabled = true
      strongSelf.numberOfDimsNode.isEnabled = true
    })
  }

  func followButtonTouchUpInside(_ sender: ASButtonNode?) {
    guard UserManager.shared.isSignedIn else {
      //If user is not signed In post notification and do not fall through
      NotificationCenter.default.post( name: AppNotification.callToAction, object: CallToAction.follow)
      return
    }

    guard let sender = sender else { return }
    //Get action from witButton status
    let action = !followButton.isSelected ? CardActionBarNode.Action.follow : CardActionBarNode.Action.unfollow
    //Assume success and Toggle button anyway, if follow/unfollow fails delegate should either call didFinishAction or  call toggle follow.
    self.updateFollow(for: action)

    delegate?.cardActionBarNode(cardActionBar: self, didRequestAction: action, forSender: sender, didFinishAction: { [weak self] (success: Bool) in
      guard let strongSelf = self else { return }
      if !success { //Toggle back on failure
        strongSelf.updateFollow(for: action, success: false)
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
    actionButton.titleNode.truncationMode = NSLineBreakMode.byTruncatingTail
    actionButton.titleNode.maximumNumberOfLines = 1
    actionButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    actionButton.style.height = ASDimensionMake(buttonSize.height)

    //Setup other buttons
    commentButton.style.preferredSize = iconSize
    shareButton.style.preferredSize = iconSize
    let textHorizontalStackSpec = ASStackLayoutSpec.horizontal()
    textHorizontalStackSpec.justifyContent = .start
    textHorizontalStackSpec.alignItems = .center
    if !followingMode {
      textHorizontalStackSpec.children = [ASLayoutSpec.spacer(width: internalMargin/2),
                                          numberOfWitsNode]
      if !hideDim {
        textHorizontalStackSpec.children?.append(ASLayoutSpec.spacer(width: internalMargin))
        textHorizontalStackSpec.children?.append(numberOfDimsNode)
      }
    }
    let horizontalStackSpec = ASStackLayoutSpec(direction: .horizontal,
                                                spacing: 0,
                                                justifyContent: .spaceAround,
                                                alignItems: .center,
                                                children: [actionButton,
                                                          textHorizontalStackSpec,
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
