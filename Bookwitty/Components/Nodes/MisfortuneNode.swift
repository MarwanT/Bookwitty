//
//  MisfortuneNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/15/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

protocol MisfortuneNodeDelegate {
  func misfortuneNodeDidTapActionButton(node: MisfortuneNode, mode: MisfortuneNode.Mode)
  func misfortuneNodeDidTapSettingsButton(node: MisfortuneNode, mode: MisfortuneNode.Mode)
}

class MisfortuneNode: ASCellNode {
  fileprivate let imageColoredBackgroundNode: ASDisplayNode
  fileprivate let imageWhiteBackgroundNode: ASDisplayNode
  fileprivate let imageNode: ASImageNode
  fileprivate let titleNode: ASTextNode
  fileprivate let descriptionNode: ASTextNode
  fileprivate let actionButtonNode: ASButtonNode
  fileprivate let settingsTextNode: ASTextNode
  
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
    settingsTextNode = ASTextNode()
    super.init()
    initializeNode()
    reloadNode()
    applyTheme()
  }
  
  private func initializeNode() {
    automaticallyManagesSubnodes = true
    
    actionButtonNode.addTarget(self, action: #selector(actionButtonTouchUpInside(_:)), forControlEvents: ASControlNodeEvent.touchUpInside)
    settingsTextNode.addTarget(self, action: #selector(settingsTouchUpInside(_:)), forControlEvents: ASControlNodeEvent.touchUpInside)
    
    backgroundColor = UIColor.white
    imageWhiteBackgroundNode.backgroundColor = backgroundColor
    imageNode.contentMode = UIViewContentMode.scaleAspectFit
    actionButtonNode.contentEdgeInsets = configuration.actionButtonContentEdgeInsets
  }
  
  private func reloadNode() {
    titleText = mode.titleText
    descriptionText = mode.descriptionText
    actionButtonText = mode.actionButtonText
    settingsAttributedText = mode.settingsAttributedText
    imageColoredBackgroundNode.backgroundColor = mode.backgroundColor
    image = mode.image
    ThemeManager.shared.currentTheme.styleSecondaryButton(
      button: actionButtonNode,
      withColor: mode.actionButtonColor,
      highlightedColor: mode.actionButtonColor)
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
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
    delegate?.misfortuneNodeDidTapActionButton(node: self, mode: mode)
  }
  func settingsTouchUpInside(_ sender: Any) {
    delegate?.misfortuneNodeDidTapSettingsButton(node: self, mode: mode)
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
  
  fileprivate var settingsAttributedText: NSAttributedString? {
    didSet {
      settingsTextNode.attributedText = settingsAttributedText
      setNeedsLayout()
    }
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
  enum Mode {
    case noInternet
    case empty
    case somethingWrong
    case noResultsFound
    case appNeedsUpdate(URL?)
    
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
      case .appNeedsUpdate:
        // TODO: Update with right Data
        return #imageLiteral(resourceName: "illustrationErrorEmptyContent")
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
      }
    }
    var settingsAttributedText: NSAttributedString {
      // TODO: Localize this
      return AttributedStringBuilder(fontDynamicType: FontDynamicType.caption1).append(text: "or check your ", color: ThemeManager.shared.currentTheme.defaultTextColor()).append(text: "settings", fontDynamicType: FontDynamicType.footnote, color: ThemeManager.shared.currentTheme.colorNumber19()).applyParagraphStyling(alignment: NSTextAlignment.center).attributedString
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
      case .appNeedsUpdate:
        return ThemeManager.shared.currentTheme.colorNumber7()
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
