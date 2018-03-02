//
//  StatefulNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/28/18.
//  Copyright © 2018 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol StatefulNodeDelegate {
  func statefulNodeDidPerformAction(node: StatefulNode, statefulAction: StatefulNode.Action?, misfortuneAction: MisfortuneNode.Action?)
}

class StatefulNode: ASCellNode {
  fileprivate let captionNode: ASTextNode
  fileprivate let actionNode: ASTextNode
  fileprivate let illustrationNode: ASImageNode
  fileprivate let colorNode: ASDisplayNode
  fileprivate let misfortuneNode: MisfortuneNode

  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let sectionMargin = ThemeManager.shared.currentTheme.sectionSpacing()
  fileprivate let imageBackgroudColorHeightPercent: CGFloat = 0.65

  fileprivate var category: Category = .none
  fileprivate var mode: Mode = .none
  fileprivate var misfortuneMode: MisfortuneNode.Mode = .none

  var delegate: StatefulNodeDelegate?

  override init() {
    captionNode = ASTextNode()
    actionNode = ASTextNode()
    illustrationNode = ASImageNode()
    colorNode = ASDisplayNode()
    misfortuneNode = MisfortuneNode(mode: MisfortuneNode.Mode.empty)
    super.init()
    automaticallyManagesSubnodes = true
    setup()
  }

  private func setup() {
    backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
    colorNode.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
    illustrationNode.contentMode = UIViewContentMode.scaleAspectFit

    actionNode.addTarget(self, action: #selector(actionButtonTouchUpInside(_:)), forControlEvents: ASControlNodeEvent.touchUpInside)
    misfortuneNode.delegate = self
  }

  func updateState(category: Category, mode: Mode, misfortuneMode: MisfortuneNode.Mode?) {
    self.category = category
    self.mode = mode
    self.misfortuneMode = misfortuneMode ?? .none
    self.misfortuneNode.mode = self.misfortuneMode

    captionNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption3)
      .append(text: captionText, color: ThemeManager.shared.currentTheme.defaultGrayedTextColor())
      .attributedString

    actionNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption2)
      .append(text: actionText ?? "", color: ThemeManager.shared.currentTheme.colorNumber19())
      .attributedString

    illustrationNode.image = image

    setNeedsLayout()
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    if case .none = misfortuneMode {
      return noNodeLayoutSpec(constrainedSize)
    }

    switch (misfortuneMode, mode, category) {
    case (.empty, _, _):
      //".empty" Misfortune State with any Mode and Category
      return topicVariantsLayoutSpec(constrainedSize)
    case (_, _, _):
      //Anything but not the ".empty" Misfortune State
      return misfortuneNodeLayoutSpec(constrainedSize)
    }
  }
}

// MARK: - Actions
extension StatefulNode {
  func actionButtonTouchUpInside(_ sender: Any) {
    delegate?.statefulNodeDidPerformAction(node: self, statefulAction: action, misfortuneAction: nil)
  }
}

// MARK: - Misfortune Delegate Implementation
extension StatefulNode: MisfortuneNodeDelegate {
  func misfortuneNodeDidPerformAction(node: MisfortuneNode, action: MisfortuneNode.Action?) {
    delegate?.statefulNodeDidPerformAction(node: self, statefulAction: nil, misfortuneAction: misfortuneNode.mode.action)
  }
}

//MARK: - Layout Spec Creators
extension StatefulNode {
  fileprivate func noNodeLayoutSpec(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let noSpec = ASLayoutSpec()
    noSpec.style.preferredSize = CGSize(width: 0.0, height: 0.0)
    return noSpec
  }

  fileprivate func misfortuneNodeLayoutSpec(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
      return ASWrapperLayoutSpec(layoutElement: misfortuneNode)
  }

  fileprivate func topicVariantsLayoutSpec(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let captionInsetSpec = ASInsetLayoutSpec(insets: sideInsets(), child: captionNode)
    let actionInsetSpec = ASInsetLayoutSpec(insets: sideInsets(), child: actionNode)

    let vStack = ASStackLayoutSpec(direction: .vertical,
                                   spacing: internalMargin,
                                   justifyContent: .start,
                                   alignItems: .center,
                                   children: [ASLayoutSpec.spacer(height: sectionMargin),
                                              captionInsetSpec,
                                              actionInsetSpec])

    //Update Color Node height with the percentage needed
    colorNode.style.height = ASDimensionMake(constrainedSize.max.height * imageBackgroudColorHeightPercent)
    colorNode.style.width = ASDimensionMake(constrainedSize.max.width)

    let colorBgLayoutSpec = ASStackLayoutSpec(direction: .vertical,
                                       spacing: 0.0,
                                       justifyContent: .start,
                                       alignItems: .stretch,
                                       children: [colorNode, ASLayoutSpec.spacer(flexGrow: 1)])

    let mainLayoutSpec = ASBackgroundLayoutSpec(child: vStack, background: illustrationNode)
    return ASOverlayLayoutSpec(child: colorBgLayoutSpec, overlay: mainLayoutSpec)
  }
}

//MARK: - Helpers
extension StatefulNode {
  fileprivate func sideInsets() -> UIEdgeInsets {
    return UIEdgeInsets( top: 0.0,
                         left: ThemeManager.shared.currentTheme.generalExternalMargin(),
                         bottom: 0.0,
                         right: ThemeManager.shared.currentTheme.generalExternalMargin())
  }
}

//MARK: State Valuation
extension StatefulNode {
  enum Action {
    case suggestABook
    case addAPost
  }

  enum Category {
    case latest
    case relatedBooks
    case followers
    case editions
    case none
  }

  enum Mode {
    case topic
    case author
    case book
    case none
  }

  fileprivate var captionText: String {
    switch (mode, category) {
    case (.topic, .latest):
      return Strings.topic_no_posts()
    case (.topic, .followers):
      return Strings.topic_no_followers()
    case (.topic, .relatedBooks):
      return Strings.topic_no_related_books()
    case (.book, .latest):
      return Strings.book_no_posts()
    case (.book, .followers):
      return Strings.book_no_followers()
    case (.author, .latest):
      return Strings.author_no_posts()
    case (.author, .relatedBooks):
      return Strings.author_no_related_books()
    case (.author, .followers):
      return Strings.author_no_followers()
    default: break
    }
    return Strings.empty_error_title()
  }

  fileprivate var actionText: String? {
    switch (mode, category) {
    case (_, .latest):
      return Strings.add_a_post().uppercased()
    case (_, .relatedBooks):
      return Strings.suggest_a_book().uppercased()
    default: break
    }
    return nil
  }

  fileprivate var image: UIImage? {
    guard case .empty = misfortuneMode else {
      return nil
    }

    switch category {
    case .latest:
      return #imageLiteral(resourceName: "illustrationErrorTopicEmptyLatest")
    case .relatedBooks:
      return #imageLiteral(resourceName: "illustrationErrorTopicEmptyRelatedbooks")
    case .editions:
      return #imageLiteral(resourceName: "illustrationErrorTopicEmptyAuthor")
    case .followers:
      return #imageLiteral(resourceName: "illustrationErrorTopicEmptyFollowers")
    case .none:
      return nil
    }
  }

  fileprivate var action: Action? {
    switch (mode, category) {
    case (.topic, .latest):
      return .addAPost
    case (.author, .latest):
      return .addAPost
    case(_, .relatedBooks):
      return .suggestABook
    default:
      return nil
    }
  }
}
