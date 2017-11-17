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
    case follow
    case unfollow
    case reply
    case more
    case remove
  }
  var followButton: ASButtonNode
  var witButton: ASButtonNode
  var commentButton: ASButtonNode
  var shareButton: ASButtonNode
  var moreButton: ASButtonNode
  var replyNode: ASTextNode
  weak var delegate: CardActionBarNodeDelegate? = nil

  fileprivate var actionButton: ASButtonNode {
    return followingMode ? followButton : witButton
  }
  fileprivate var followingMode: Bool = false {
    didSet {
      setNeedsLayout()
    }
  }

  var hideCommentButton: Bool = false {
    didSet {
      setNeedsLayout()
    }
  }
  
  var hideShareButton: Bool = false {
    didSet {
      setNeedsLayout()
    }
  }
  
  var hideMoreButton: Bool = false {
    didSet {
      setNeedsLayout()
    }
  }

  var hideReplyButton: Bool = true {
    didSet {
      setNeedsLayout()
    }
  }
  
  var configuration = Configuration() {
    didSet {
      setNeedsLayout()
    }
  }

  override init() {
    witButton = ASButtonNode()
    commentButton = ASButtonNode()
    shareButton = ASButtonNode()
    moreButton = ASButtonNode()
    followButton = ASButtonNode()
    replyNode = ASTextNode()
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

    shareButton.imageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(imageTintColor)
    shareButton.setImage(#imageLiteral(resourceName: "shareOutside"), for: .normal)

    moreButton.imageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(imageTintColor)
    moreButton.setImage(#imageLiteral(resourceName: "threeDots"), for: .normal)

    setupWitButtonStyling()
    setupFollowButtonStyling()
    setupReplyNodeStyling()

    moreButton.addTarget(self, action: #selector(moreButtonTouchUpInside(_:)), forControlEvents: .touchUpInside)
    shareButton.addTarget(self, action: #selector(shareButtonTouchUpInside(_:)), forControlEvents: .touchUpInside)
    commentButton.addTarget(self, action: #selector(commentButtonTouchUpInside(_:)), forControlEvents: .touchUpInside)
    witButton.addTarget(self, action: #selector(witButtonTouchUpInside(_:)), forControlEvents: .touchUpInside)
    followButton.addTarget(self, action: #selector(followButtonTouchUpInside(_:)), forControlEvents: .touchUpInside)
    replyNode.addTarget(self, action: #selector(replyButtonTouchUpInside(_:)), forControlEvents: .touchUpInside)
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

    witButton.style.preferredSize.width = 75.0

    witButton.setTitle(Strings.wit_it(), with: buttonFont, with: textColor, for: .normal)
    witButton.setTitle(Strings.witted(), with: buttonFont, with: selectedTextColor, for: .selected)

    witButton.cornerRadius = 2.0
    witButton.borderColor = ThemeManager.shared.currentTheme.defaultButtonColor().cgColor
    witButton.borderWidth = 2
    witButton.clipsToBounds = true
  }

  private func setupReplyNodeStyling() {
    replyNode.attributedText = AttributedStringBuilder(fontDynamicType: FontDynamicType.footnote)
      .append(text: Strings.reply(), color: ThemeManager.shared.currentTheme.defaultGrayedTextColor()).attributedString
    replyNode.style.maxWidth = ASDimensionMake(120.0)
    replyNode.maximumNumberOfLines = 1
    replyNode.truncationMode = NSLineBreakMode.byTruncatingTail
  }

  func setFollowingValue(following: Bool) {
    followButton.isSelected = following
  }

  func setWitButton(witted: Bool) {
    witButton.isSelected = witted
  }

  func updateWitAndDim(for action: Action, success: Bool = true) {
    switch action {
    case .wit:
      setWitButton(witted: success)
    case .unwit:
      setWitButton(witted: false)

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

    delegate?.cardActionBarNode(cardActionBar: self, didRequestAction: action, forSender: sender, didFinishAction: { [weak self] (success: Bool) in
      guard let strongSelf = self else { return }
      if !success { //Toggle back on failure
        strongSelf.updateWitAndDim(for: action, success: false)
      }
      strongSelf.witButton.isEnabled = true
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
  
  func moreButtonTouchUpInside(_ sender: ASButtonNode?) {
    guard let sender = sender else { return }
    delegate?.cardActionBarNode(cardActionBar: self, didRequestAction: CardActionBarNode.Action.more, forSender: sender, didFinishAction: nil)
  }

  func replyButtonTouchUpInside(_ sender: ASButtonNode?) {
    guard let sender = sender else { return }
    delegate?.cardActionBarNode(cardActionBar: self, didRequestAction: CardActionBarNode.Action.reply, forSender: sender, didFinishAction: nil)
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
    var shouldAddSpace: Bool = true
    
    //Setup Dynamic width Wit Button
    actionButton.titleNode.truncationMode = NSLineBreakMode.byTruncatingTail
    actionButton.titleNode.maximumNumberOfLines = 1
    actionButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    actionButton.style.height = ASDimensionMake(configuration.buttonSize.height)

    //Setup other buttons
    commentButton.style.preferredSize = configuration.iconSize
    shareButton.style.preferredSize = configuration.iconSize
    moreButton.style.preferredSize = configuration.iconSize
    
    // • Layout visible subnodes
    var horizontalStackElements = [ASLayoutElement]()
    
    // • Add voting action buttons
    let textHorizontalStackSpec = ASStackLayoutSpec.horizontal()
    textHorizontalStackSpec.justifyContent = .start
    textHorizontalStackSpec.alignItems = .center
    if !followingMode {

    }
    horizontalStackElements.append(actionButton)
    horizontalStackElements.append(textHorizontalStackSpec)
    horizontalStackElements.append(spacer())
    shouldAddSpace = false
    
    // • Add Comment Button
    if !hideCommentButton {
      horizontalStackElements.append(commentButton)
      shouldAddSpace = true
    }
    
    // • Add Share Button
    if !hideShareButton {
      if shouldAddSpace {
        horizontalStackElements.append(spacer(width: 10))
      }
      horizontalStackElements.append(shareButton)
      shouldAddSpace = true
    }

    // • Add Share Button
    if !hideMoreButton {
      if shouldAddSpace {
        horizontalStackElements.append(spacer(width: 10))
      }
      horizontalStackElements.append(moreButton)
      shouldAddSpace = true
    }
    
    // • Add Reply Button
    if !hideReplyButton {
      if shouldAddSpace {
        horizontalStackElements.append(spacer(width: 10))
      }
      horizontalStackElements.append(replyNode)
      shouldAddSpace = true
    }
    
    let horizontalStackSpec = ASStackLayoutSpec(direction: .horizontal,
                                                spacing: 0,
                                                justifyContent: .spaceAround,
                                                alignItems: .center,
                                                children: horizontalStackElements)

    let centeredActionBarLayoutSpec = ASCenterLayoutSpec(centeringOptions: ASCenterLayoutSpecCenteringOptions.Y, sizingOptions: ASCenterLayoutSpecSizingOptions.minimumY, child: horizontalStackSpec)
    //Set Node Height
    centeredActionBarLayoutSpec.style.height = ASDimensionMake(configuration.actionBarHeight)

    //Set Node Insets
    return ASInsetLayoutSpec.init(insets: UIEdgeInsets.init(top: 0, left: configuration.externalHorizontalMargin, bottom: 0, right: configuration.externalHorizontalMargin), child: centeredActionBarLayoutSpec)
  }
}

extension CardActionBarNode {
  struct Configuration {
    var witItButtonMargin = ThemeManager.shared.currentTheme.witItButtonMargin()
    var internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
    var externalHorizontalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
    
    var actionBarHeight: CGFloat = 60.0
    var buttonSize: CGSize = CGSize(width: 36.0, height: 36.0)
    var iconSize: CGSize = CGSize(width: 40.0, height: 40.0)
  }
}
