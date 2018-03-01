//
//  MisfortuneNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/15/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit
import TTTAttributedLabel

protocol MisfortuneNodeDelegate {
  func misfortuneNodeDidPerformAction(node: MisfortuneNode, action: MisfortuneNode.Action?)
}

class MisfortuneNode: ASCellNode {
  fileprivate let imageColoredBackgroundNode: ASDisplayNode
  fileprivate let imageWhiteBackgroundNode: ASDisplayNode
  fileprivate let imageNode: ASImageNode
  fileprivate let titleNode: ASTextNode
  fileprivate let descriptionNode: ASTextNode
  fileprivate let actionButtonNode: ASButtonNode
  fileprivate let settingsTextNode: TTTAttributedLabelNode
  
  var mode: Mode! = nil {
    didSet {
      reloadNode()
    }
  }
  
  fileprivate var configuration = Configuration()
  
  var delegate: MisfortuneNodeDelegate?
  
  init(mode: Mode) {
    self.mode = mode
    imageColoredBackgroundNode = ASDisplayNode()
    imageWhiteBackgroundNode = ASDisplayNode()
    imageNode = ASImageNode()
    titleNode = ASTextNode()
    descriptionNode = ASTextNode()
    actionButtonNode = ASButtonNode()
    settingsTextNode = TTTAttributedLabelNode()
    super.init()
    initializeNode()
    reloadNode()
    applyTheme()
  }
  
  private func initializeNode() {
    automaticallyManagesSubnodes = true
    
    actionButtonNode.addTarget(self, action: #selector(actionButtonTouchUpInside(_:)), forControlEvents: ASControlNodeEvent.touchUpInside)
    
    settingsTextNode.textAlignment = .center
    
    backgroundColor = UIColor.white
    imageWhiteBackgroundNode.backgroundColor = backgroundColor
    imageNode.contentMode = UIViewContentMode.scaleAspectFit
    actionButtonNode.contentEdgeInsets = configuration.actionButtonContentEdgeInsets
  }
  
  private func reloadNode() {
    titleText = mode.titleText
    descriptionText = mode.descriptionText
    actionButtonText = mode.actionButtonText
    setupSettingsAttributedText()
    imageColoredBackgroundNode.backgroundColor = mode.backgroundColor
    image = mode.image
    ThemeManager.shared.currentTheme.styleSecondaryButton(
      button: actionButtonNode,
      withColor: mode.actionButtonColor,
      highlightedColor: mode.actionButtonColor)
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    if case .none = mode {
      let noSpec = ASLayoutSpec()
      noSpec.style.preferredSize = CGSize(width: 1.0, height: 1.0)
      return noSpec
    }

    // TOP PART OF THE NODE
    //----------------------
    let imageBackgroundForegroundInset = ASInsetLayoutSpec(
      insets: UIEdgeInsets(top: CGFloat.infinity, left: 0, bottom: 0, right: 0),
      child: imageWhiteBackgroundNode)
    imageWhiteBackgroundNode.style.height = ASDimensionMake("\(self.mode.imageBottomWhiteHeightDimension)%")
    let imageBackgroundOverlaySpec = ASOverlayLayoutSpec(
      child: imageColoredBackgroundNode,
      overlay: imageBackgroundForegroundInset)
    
    let imageSpec = ASBackgroundLayoutSpec(child: imageNode, background: imageBackgroundOverlaySpec)
    imageSpec.style.maxHeight = ASDimensionMake(constrainedSize.max.height/2)
    imageSpec.style.flexShrink = 1.0
    
    // BOTTOM HALF OF THE NODE
    //-------------------------
    let topContentVerticalStack = ASStackLayoutSpec(
      direction: .vertical,
      spacing: 10,
      justifyContent: .start,
      alignItems: .stretch,
      children: [titleNode, descriptionNode])
    let topContentStackInset = ASInsetLayoutSpec(
      insets: UIEdgeInsets(
        top: (configuration.contentVerticalMargin * 2), left: 0,
        bottom: configuration.contentVerticalMargin, right: 0),
      child: topContentVerticalStack)
    
    // Add bottom action nodes based on the visibility specified in the node
    let actionButtonInsets = ASInsetLayoutSpec(
      insets: UIEdgeInsets(
        top: 0, left: 0,
        bottom: configuration.contentVerticalMargin, right: 0),
      child: actionButtonNode)
    var bottomContentLayoutElements = [ASLayoutElement]()
    if mode.actionButtonVisible {
      bottomContentLayoutElements.append(actionButtonInsets)
    }
    if mode.settingsTextVisible {
      settingsTextNode.style.width = ASDimensionMake(constrainedSize.max.width)
      bottomContentLayoutElements.append(settingsTextNode)
    }
    let bottomContentVerticalStack = ASStackLayoutSpec(
      direction: .vertical,
      spacing: 0,
      justifyContent: .end,
      alignItems: .center,
      children: bottomContentLayoutElements)
    let bottomContentStackInset = ASInsetLayoutSpec(
      insets: UIEdgeInsets(
        top: configuration.contentVerticalMargin, left: 0,
        bottom: (configuration.contentVerticalMargin * 2), right: 0),
      child: bottomContentVerticalStack)
    
    // If there were no views at all in the bottom part then do not include
    // the layout element
    var contentStackLayoutElements: [ASLayoutElement] = [topContentStackInset]
    if bottomContentLayoutElements.count > 0 {
      contentStackLayoutElements.append(bottomContentStackInset)
    }
    
    // Get the bottom half layout of the base layout
    let contentStack = ASStackLayoutSpec(
      direction: .vertical,
      spacing: 0,
      justifyContent: .spaceBetween,
      alignItems: .stretch,
      children: contentStackLayoutElements)
    contentStack.style.minHeight = ASDimensionMake(constrainedSize.max.height/2)
    
    let contentStackInset = ASInsetLayoutSpec(
      insets: UIEdgeInsets(
        top: 0, left: configuration.contentHerizontalMargin,
        bottom: 0, right: configuration.contentHerizontalMargin),
      child: contentStack)
    contentStackInset.style.flexGrow = 1.0
    
    // Build the base vertical Layout
    //--------------------------------
    let verticalStack = ASStackLayoutSpec(
      direction: .vertical,
      spacing: 0,
      justifyContent: ASStackLayoutJustifyContent.start,
      alignItems: .stretch,
      children: [imageSpec, contentStackInset])
    verticalStack.style.height = ASDimensionMake(constrainedSize.max.height)
    return verticalStack
  }
  
  // MARK: - Actions
  func actionButtonTouchUpInside(_ sender: Any) {
    delegate?.misfortuneNodeDidPerformAction(node: self, action: self.mode.action)
  }
  func settingsTouchUpInside(_ sender: Any?) {
    delegate?.misfortuneNodeDidPerformAction(node: self, action: Action.settings)
  }
  
  // MARK: - Conetent setters
  fileprivate var image: UIImage? {
    didSet {
      imageNode.image = image
      imageNode.setNeedsDisplay()
    }
  }
  
  fileprivate var titleText: String? {
    didSet {
      titleNode.attributedText = AttributedStringBuilder(fontDynamicType: FontDynamicType.headline)
        .append(text: titleText ?? "", color: mode.titleTextColor).applyParagraphStyling(alignment: NSTextAlignment.center).attributedString
      setNeedsLayout()
    }
  }
  
  fileprivate var descriptionText: String? {
    didSet {
      descriptionNode.attributedText = AttributedStringBuilder(fontDynamicType: FontDynamicType.caption1).append(text: descriptionText ?? "", color: mode.descriptionTextColor).applyParagraphStyling(alignment: NSTextAlignment.center).attributedString
      setNeedsLayout()
    }
  }
  
  fileprivate var actionButtonText: String? {
    didSet {
      actionButtonNode.setTitle(actionButtonText ?? "", with: FontDynamicType.subheadline.font, with: mode.actionButtonColor, for: UIControlState.normal)
      setNeedsLayout()
    }
  }
  
  fileprivate func setupSettingsAttributedText() {
    //Set Attributed Styled up Text
    let settingsText = mode.settingsAttributedText
    let settingsNSString = settingsText.mutableString as NSMutableString
    
    //Attributed Label Links Styling
    settingsTextNode.linkAttributes = ThemeManager.shared.currentTheme.styleTextLinkAttributes()
    settingsTextNode.linkAttributes[NSFontAttributeName] = FontDynamicType.footnote.font
    
    let range: NSRange = NSRange(location: 0, length: settingsNSString.length)
    let regular = try! NSRegularExpression(pattern: "•(.*?)•", options: [])
    
    var resultRanges: [NSRange] = []
    regular.enumerateMatches(in: settingsText.string, options: [], range: range, using: {
      (result: NSTextCheckingResult?, flags, stop) in
      if let result = result {
        resultRanges.append(result.rangeAt(1))
      }
    })
    
    settingsNSString.replaceOccurrences(of: "•", with: "", options: [], range: range)
    settingsTextNode.attributedText = settingsText
    
    for (index, range) in resultRanges.enumerated() {
      let effectiveRange = NSRange(location: (range.location - (2 * index + 1)), length: range.length)
      switch index {
      case 0:
        _ = settingsTextNode.addLink(to: AttributedLinkReference.settings.url, with: effectiveRange)
      default:
        break
      }
    }
    
    //Set Delegates
    settingsTextNode.delegate = self
    setNeedsLayout()
  }
}

// MARK: - TTTAttributedText delegate
extension MisfortuneNode: TTTAttributedLabelDelegate {
  enum AttributedLinkReference: String {
    case settings
    var url: URL {
      get {
        return URL(string: "bookwittyapp://" + self.rawValue)!
      }
    }
  }
  
  func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
    guard url.host != nil else {
      return
    }
    settingsTouchUpInside(nil)
  }
}

// MARK: - Themeable
extension MisfortuneNode: Themeable {
  func applyTheme() {
    ThemeManager.shared.currentTheme.styleSecondaryButton(
      button: actionButtonNode,
      withColor: mode.actionButtonColor,
      highlightedColor: mode.actionButtonColor)
  }
}

// MARK: - Mode Declaration
extension MisfortuneNode {
  enum Action {
    case tryAgain
    case updateApp
    case myInterests
    case settings
  }
  
  enum Mode {
    case noInternet
    case empty
    case somethingWrong
    case noResultsFound
    case appNeedsUpdate(URL?)
    case none
    
    // Visibility
    var actionButtonVisible: Bool {
      switch self {
      case .empty:
        return false
      case .noInternet:
        return true
      case .noResultsFound:
        return false
      case .somethingWrong:
        return true
      case .appNeedsUpdate:
        return true
      case .none:
        return false
      }
    }
    
    var action: Action? {
      switch self {
      case .empty:
        return Action.myInterests
      case .noInternet:
        return Action.tryAgain
      case .noResultsFound:
        return nil
      case .somethingWrong:
        return Action.tryAgain
      case .appNeedsUpdate:
        return Action.updateApp
      case .none:
        return nil
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
      case .appNeedsUpdate:
        return false
      case .none:
        return false
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
        return #imageLiteral(resourceName: "illustrationErrorNoResult")
      case .somethingWrong:
        return #imageLiteral(resourceName: "illustrationErrorSomethingsWrong")
      case .appNeedsUpdate:
        // TODO: Update with right Data
        return #imageLiteral(resourceName: "illustrationErrorEmptyContent")
      case .none:
        return UIImage()
      }
    }
    
    /// Image white background overlay percentage
    var imageBottomWhiteHeightDimension: CGFloat {
      switch self {
      case .empty:
        return 20
      case .noInternet:
        return 20
      case .noResultsFound:
        return 20
      case .somethingWrong:
        return 20
      case .appNeedsUpdate:
        return 20
      case .none:
        return 0
      }
    }
    
    // Text
    var titleText: String {
      switch self {
      case .empty:
        return Strings.empty_error_title()
      case .noInternet:
        return Strings.no_internet_error_title()
      case .noResultsFound:
        return Strings.no_results_found_title()
      case .somethingWrong:
        return Strings.something_wrong_error_title()
      case .appNeedsUpdate:
        return Strings.new_version_available_title()
      case .none:
        return ""
      }
    }
    var descriptionText: String {
      switch self {
      case .empty:
        return Strings.empty_error_description()
      case .noInternet:
        return Strings.no_internet_error_description()
      case .noResultsFound:
        return Strings.no_results_found_description()
      case .somethingWrong:
        return Strings.something_wrong_error_description()
      case .appNeedsUpdate:
        return Strings.new_version_available_description()
      case .none:
        return ""
      }
    }
    var actionButtonText: String {
      switch self {
      case .empty:
        return Strings.my_interests()
      case .noInternet:
        return Strings.try_again()
      case .noResultsFound:
        return ""
      case .somethingWrong:
        return Strings.try_again()
      case .appNeedsUpdate:
        return Strings.update_now()
      case .none:
        return ""
      }
    }
    var settingsAttributedText: NSMutableAttributedString {
      // TODO: Localize this
      return AttributedStringBuilder(fontDynamicType: FontDynamicType.caption1).append(text: Strings.or_check_your_settings()).applyParagraphStyling(alignment: NSTextAlignment.center).attributedString
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
      case .appNeedsUpdate:
        return ThemeManager.shared.currentTheme.colorNumber8()
      case .none:
        return ThemeManager.shared.currentTheme.colorNumber1()
      }
    }
    var backgroundColor: UIColor {
      switch self {
      case .empty:
        return ThemeManager.shared.currentTheme.colorNumber7()
      case .noInternet:
        return ThemeManager.shared.currentTheme.colorNumber3()
      case .noResultsFound:
        return ThemeManager.shared.currentTheme.colorNumber5()
      case .somethingWrong:
        return ThemeManager.shared.currentTheme.colorNumber9()
      case .appNeedsUpdate:
        return ThemeManager.shared.currentTheme.colorNumber7()
      case .none:
        return ThemeManager.shared.currentTheme.colorNumber1()
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
