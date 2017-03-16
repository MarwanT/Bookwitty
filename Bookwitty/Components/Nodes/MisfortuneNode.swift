//
//  MisfortuneNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/15/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class MisfortuneNode: ASDisplayNode {
  fileprivate let imageNode: ASImageNode
  fileprivate let titleNode: ASTextNode
  fileprivate let descriptionNode: ASTextNode
  fileprivate let actionButtonNode: ASButtonNode
  fileprivate let settingsTextNode: ASTextNode
  
  fileprivate var mode: Mode! = nil
  
  fileprivate var configuration = Configuration()
  
  init(mode: Mode) {
    self.mode = mode
    imageNode = ASImageNode()
    titleNode = ASTextNode()
    descriptionNode = ASTextNode()
    actionButtonNode = ASButtonNode()
    settingsTextNode = ASTextNode()
    super.init()
  }
  
  // MARK: - Conetent setters
  fileprivate var image: UIImage? {
    didSet {
      imageNode.image = image
    }
  }
  
  fileprivate var titleText: String? {
    didSet {
      titleNode.attributedText = AttributedStringBuilder(fontDynamicType: FontDynamicType.headline)
        .append(text: titleText ?? "", color: mode.titleTextColor).applyParagraphStyling(lineSpacing: 0, alignment: NSTextAlignment.center).attributedString
      setNeedsLayout()
    }
  }
  
  fileprivate var descriptionText: String? {
    didSet {
      descriptionNode.attributedText = AttributedStringBuilder(fontDynamicType: FontDynamicType.caption1).append(text: descriptionText ?? "", color: mode.descriptionTextColor).applyParagraphStyling(lineSpacing: 0, alignment: NSTextAlignment.center).attributedString
      setNeedsLayout()
    }
  }
  
  fileprivate var actionButtonText: String? {
    didSet {
      actionButtonNode.setTitle(actionButtonText ?? "", with: FontDynamicType.subheadline.font, with: mode.actionButtonColor, for: UIControlState.normal)
      setNeedsLayout()
    }
  }
  
  fileprivate var settingsAttributedText: NSAttributedString? {
    didSet {
      settingsTextNode.attributedText = settingsAttributedText
      setNeedsLayout()
    }
  }
}

// MARK: - Mode Declaration
extension MisfortuneNode {
  enum Mode {
    case noInternet
    case empty
    case somethingWrong
    case noResultsFound
    
    // Visibility
    var actionButtonVisible: Bool {
      switch self {
      case .empty:
        return true
      case .noInternet:
        return true
      case .noResultsFound:
        return false
      case .somethingWrong:
        return true
      }
    }
    var settingsTextVisible: Bool {
      switch self {
      case .empty:
        return false
      case .noInternet:
        return true
      case .noResultsFound:
        return false
      case .somethingWrong:
        return true
      }
    }
    
    // Image
    var image: UIImage {
      switch self {
      case .empty:
        return #imageLiteral(resourceName: "illustrationErrorEmptyContent")
      case .noInternet:
        return #imageLiteral(resourceName: "illustrationErrorNoInternet")
      case .noResultsFound:
        return #imageLiteral(resourceName: "illustrationErrorEmptyContent")
      case .somethingWrong:
        return #imageLiteral(resourceName: "illustrationErrorSomethingsWrong")
      }
    }
    
    // Text
    var titleText: String {
      switch self {
      case .empty:
        return "Its empty in here"
      case .noInternet:
        return "No Internet!"
      case .noResultsFound:
        return "No results found"
      case .somethingWrong:
        return "Something's wrong!"
      }
    }
    var descriptionText: String {
      switch self {
      case .empty:
        return "Select people, topics and tags of\ninterest to populate this section\nwith content you like."
      case .noInternet:
        return "Your internet connection appears\nto be offline."
      case .noResultsFound:
        return "We can't find what you were\nlooking for. Check the spelling or try a different search."
      case .somethingWrong:
        return "We can't load your\nfeed right now."
      }
    }
    var actionButtonText: String {
      switch self {
      case .empty:
        return "My interests"
      case .noInternet:
        return "Try again"
      case .noResultsFound:
        return ""
      case .somethingWrong:
        return "Try again"
      }
    }
    var settingsAttributedText: NSAttributedString {
      return AttributedStringBuilder(fontDynamicType: FontDynamicType.caption1).append(text: "or check your ", color: ThemeManager.shared.currentTheme.defaultTextColor()).append(text: "settings", fontDynamicType: FontDynamicType.footnote, color: ThemeManager.shared.currentTheme.colorNumber19()).applyParagraphStyling(lineSpacing: 0, alignment: NSTextAlignment.center).attributedString
    }
    
    // Colors
    var titleTextColor: UIColor {
      return ThemeManager.shared.currentTheme.defaultTextColor()
    }
    var descriptionTextColor: UIColor {
      return ThemeManager.shared.currentTheme.defaultTextColor()
    }
    var actionButtonColor: UIColor {
      switch self {
      case .empty:
        return ThemeManager.shared.currentTheme.colorNumber8()
      case .noInternet:
        return ThemeManager.shared.currentTheme.colorNumber4()
      case .noResultsFound:
        return ThemeManager.shared.currentTheme.colorNumber8()
      case .somethingWrong:
        return ThemeManager.shared.currentTheme.colorNumber10()
      }
    }
    var backgroundColor: UIColor {
      switch self {
      case .empty:
        return ThemeManager.shared.currentTheme.colorNumber7()
      case .noInternet:
        return ThemeManager.shared.currentTheme.colorNumber3()
      case .noResultsFound:
        return ThemeManager.shared.currentTheme.colorNumber7()
      case .somethingWrong:
        return ThemeManager.shared.currentTheme.colorNumber9()
      }
    }
  }
}

// MARK: - Configuration Declaration
extension MisfortuneNode {
  fileprivate struct Configuration {
    let contentVerticalMargin: CGFloat = ThemeManager.shared.currentTheme.generalExternalMargin()
    let contentHerizontalMargin: CGFloat = ThemeManager.shared.currentTheme.generalExternalMargin()
    let actionButtonContentEdgeInsets = UIEdgeInsets(
      top: 0, left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: 0, right: ThemeManager.shared.currentTheme.generalExternalMargin())
  }
}
