//
//  OnBoardingInternalCellNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/3/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol OnBoardingInternalCellNodeDelegate {
  func didTapOnSelectionButton(cell: OnBoardingInternalCellNode, button: OnBoardingLoadingButton, shouldSelect: Bool, doneCompletionBlock: @escaping (_ success: Bool) -> ())
}

class OnBoardingInternalCellNode: ASCellNode {
  static let cellHeight: CGFloat = 115.0

  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()

  let titleTextNode: ASTextNode
  let shortDescriptionTextNode: ASTextNode
  let selectionButtonNode: OnBoardingLoadingButton
  let imageNode: ASNetworkImageNode
  let separator: ASDisplayNode

  fileprivate var fullSeparator: Bool {
    return isLast
  }

  var delegate: OnBoardingInternalCellNodeDelegate?
  var isLast: Bool = false
  var text: String? {
    didSet {
      if let text = text {
        titleTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .footnote)
          .append(text: text, color: ThemeManager.shared.currentTheme.defaultTextColor()).attributedString
      }
    }
  }
  var descriptionText: String? {
    didSet {
      if let descriptionText = descriptionText {
        shortDescriptionTextNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption2)
          .append(text: descriptionText, color: ThemeManager.shared.currentTheme.defaultTextColor())
          .applyParagraphStyling().attributedString
      }
    }
  }
  var following: Bool? {
    didSet {
      if let following = following {
        self.selectionButtonNode.state = following ? .selected : .normal
      }
    }
  }
  
  override init() {
    titleTextNode = ASTextNode()
    shortDescriptionTextNode =  ASTextNode()
    selectionButtonNode =  OnBoardingLoadingButton()
    imageNode =  ASNetworkImageNode()
    separator = ASDisplayNode()
    super.init()
    initializeNode()
  }

  func initializeNode() {
    automaticallyManagesSubnodes = true

    shortDescriptionTextNode.maximumNumberOfLines = 3
    titleTextNode.maximumNumberOfLines = 1

    selectionButtonNode.style.preferredSize = CGSize(width: 36.0, height: 36.0)
    imageNode.style.preferredSize = CGSize(width: 45.0, height: 45.0)
    imageNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor()

    separator.style.height = ASDimensionMake(1.0)
    separator.style.width = ASDimensionMake(UIScreen.main.bounds.width)
    separator.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()

    style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: OnBoardingInternalCellNode.cellHeight)

    selectionButtonNode.delegate = self
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let vStack =  ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .center,
                                   alignItems: .start, children: [titleTextNode, shortDescriptionTextNode])
    vStack.children = [titleTextNode, ASLayoutSpec.spacer(height: internalMargin/2), shortDescriptionTextNode]

    let textInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: internalMargin, bottom: 0, right: internalMargin), child: vStack)
    textInsetSpec.style.flexShrink = 1.0
    textInsetSpec.style.flexGrow = 1.0

    let endStack = ASStackLayoutSpec.vertical()
    endStack.justifyContent = .center
    endStack.children = [selectionButtonNode]

    let hStack = ASStackLayoutSpec(direction: .horizontal, spacing: 0,
                                   justifyContent: .start, alignItems: .stretch,
                                   children: [imageNode, textInsetSpec, endStack])
    let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: contentSpacing, left: internalMargin, bottom: contentSpacing, right: internalMargin), child: hStack)

    let separatorWidth = fullSeparator ?
      constrainedSize.max.width :
      constrainedSize.max.width - ((textInsetSpec.insets.left + insetSpec.insets.left) + imageNode.style.width.value)
    separator.style.width = ASDimensionMake(separatorWidth)

    let finalVStack = ASStackLayoutSpec.vertical()
    finalVStack.justifyContent = .spaceBetween
    finalVStack.alignItems = .stretch
    finalVStack.children = [insetSpec, separator]

    return finalVStack
  }
}

extension OnBoardingInternalCellNode: OnBoardingLoadingButtonDelegate {
  func loadingButtonTouchUpInside(onBoardingLoadingButton: OnBoardingLoadingButton) {
    guard !selectionButtonNode.isLoading else {
      return
    }
    selectionButtonNode.state = .loading

    let shouldSelect = !selectionButtonNode.button.isSelected
    delegate?.didTapOnSelectionButton(cell: self, button: selectionButtonNode, shouldSelect: shouldSelect, doneCompletionBlock: { (success: Bool) in
      //Randomize For testing => (arc4random_uniform(2) == 0) ? .normal : .selected
      self.selectionButtonNode.state = (success && shouldSelect) ? .selected : .normal
    })
  }
}
