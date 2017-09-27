//
//  IntroductoryBanner.swift
//  Bookwitty
//
//  Created by Marwan  on 5/19/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

protocol IntroductoryBannerDelegate: class {
  func introductoryBannerDidTapDismissButton(_ introductoryBanner: IntroductoryBanner)
}

class IntroductoryBanner: ASCellNode {
  fileprivate let titleNode: ASTextNode
  fileprivate let subtitleNode: ASTextNode
  fileprivate let dismissButton: ASButtonNode
  
  var mode: Mode! = nil {
    didSet {
      refreshNode()
    }
  }
  
  var configuration = Configuration()
  
  weak var delegate: IntroductoryBannerDelegate? = nil
  
  init(mode: Mode) {
    self.mode = mode
    titleNode = ASTextNode()
    subtitleNode = ASTextNode()
    dismissButton = ASButtonNode()
    super.init()
    initializeNode()
    refreshNode()
    observeLanguageChanges()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let stackLayoutSpec = ASStackLayoutSpec(direction: .vertical, spacing: 15, justifyContent: .start, alignItems: .center, children: [titleNode,subtitleNode])
    let stackInsetsSpec = ASInsetLayoutSpec(insets: configuration.externalMargin, child: stackLayoutSpec)
    
    let dismissButtonInsetsSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: CGFloat.infinity, bottom: CGFloat.infinity, right: 0), child: dismissButton)
    dismissButton.style.preferredSize = CGSize(width: 30, height: 30)
    
    return ASOverlayLayoutSpec(child: stackInsetsSpec, overlay: dismissButtonInsetsSpec)
  }
  
  private func initializeNode() {
    automaticallyManagesSubnodes = true
    
    dismissButton.addTarget(self, action: #selector(dismissButtonTouchUpInside(_:)), forControlEvents: ASControlNodeEvent.touchUpInside)
    
    dismissButton.setBackgroundImage(#imageLiteral(resourceName: "x"), for: .normal)
  }
  
  func refreshNode() {
    titleText = mode.title
    subtitleText = mode.subtitle
    backgroundColor = mode.color
  }
  
  func dismissButtonTouchUpInside(_ sender: Any) {
    delegate?.introductoryBannerDidTapDismissButton(self)
  }
  
  fileprivate var titleText: String? {
    didSet {
      titleNode.attributedText = AttributedStringBuilder(fontDynamicType: FontDynamicType.callout)
        .append(text: titleText ?? "", color: mode.titleTextColor).applyParagraphStyling(alignment: NSTextAlignment.center).attributedString
      titleNode.setNeedsLayout()
    }
  }
  
  fileprivate var subtitleText: String? {
    didSet {
      subtitleNode.attributedText = AttributedStringBuilder(fontDynamicType: FontDynamicType.caption1).append(text: subtitleText ?? "", color: mode.subtitleTextColor).applyParagraphStyling(alignment: NSTextAlignment.center).attributedString
      subtitleNode.setNeedsLayout()
    }
  }
}

extension IntroductoryBanner {
  enum Mode {
    case welcome
    case discover
    case shop
    
    var title: String {
      switch self {
      case .welcome:
        return Strings.welcome_to_bookwitty()
      case .discover:
        return Strings.see_whats_happening_on_bookwitty()
      case .shop:
        return Strings.shop_for_books()
      }
    }

    var subtitle: String {
      switch self {
      case .welcome:
        return Strings.welcome_banner_message()
      case .discover:
        return Strings.discover_banner_message()
      case .shop:
        return Strings.shop_banner_message()
      }
    }
    
    var color: UIColor {
      let theme = ThemeManager.shared.currentTheme
      
      switch self {
      case .welcome:
        return theme.colorNumber9()
      case .discover:
        return theme.colorNumber7()
      case .shop:
        return theme.colorNumber3()
      }
    }
    
    var titleTextColor: UIColor {
      return ThemeManager.shared.currentTheme.defaultTextColor()
    }
    
    var subtitleTextColor: UIColor {
      return ThemeManager.shared.currentTheme.defaultTextColor()
    }
  }
}

extension IntroductoryBanner {
  struct Configuration {
    var externalMargin = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
  }
}

//MARK: - Localizable implementation
extension IntroductoryBanner: Localizable {
  func applyLocalization() {
    refreshNode()
  }

  fileprivate func observeLanguageChanges() {
    NotificationCenter.default.addObserver(self, selector: #selector(languageValueChanged(notification:)), name: Localization.Notifications.Name.languageValueChanged, object: nil)
  }
  
  @objc
  fileprivate func languageValueChanged(notification: Notification) {
    applyLocalization()
  }
}

