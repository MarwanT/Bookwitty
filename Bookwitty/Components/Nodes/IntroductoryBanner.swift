//
//  IntroductoryBanner.swift
//  Bookwitty
//
//  Created by Marwan  on 5/19/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class IntroductoryBanner: ASCellNode {
  fileprivate let titleNode: ASTextNode
  fileprivate let subtitleNode: ASTextNode
  fileprivate let dismissButton: ASButtonNode
  
  var mode: Mode! = nil 
  
  var configuration = Configuration()
  
  init(mode: Mode) {
    self.mode = mode
    titleNode = ASTextNode()
    subtitleNode = ASTextNode()
    dismissButton = ASButtonNode()
    super.init()
    initializeNode()
  }
  
  private func initializeNode() {
    automaticallyManagesSubnodes = true
    
    dismissButton.addTarget(self, action: #selector(dismissButtonTouchUpInside(_:)), forControlEvents: ASControlNodeEvent.touchUpInside)
    
    dismissButton.setBackgroundImage(#imageLiteral(resourceName: "x"), for: .normal)
    dismissButton.contentEdgeInsets = UIEdgeInsets(top: 15, left: -15, bottom: 15, right: 15)
    dismissButton.contentMode = UIViewContentMode.scaleAspectFit
  }
  
  func dismissButtonTouchUpInside(_ sender: Any) {
    // TODO: call delegate for dismissal
    print("Dismiss button taapped")
  }
  
  fileprivate var titleText: String? {
    didSet {
      titleNode.attributedText = AttributedStringBuilder(fontDynamicType: FontDynamicType.callout)
        .append(text: titleText ?? "", color: mode.titleTextColor).applyParagraphStyling(alignment: NSTextAlignment.center).attributedString
      setNeedsLayout()
    }
  }
  
  fileprivate var subtitleText: String? {
    didSet {
      subtitleNode.attributedText = AttributedStringBuilder(fontDynamicType: FontDynamicType.caption1).append(text: subtitleText ?? "", color: mode.subtitleTextColor).applyParagraphStyling(alignment: NSTextAlignment.center).attributedString
      setNeedsLayout()
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
        return "Welcome to Bookwitty"
      case .discover:
        return "See what's happening on Bookwitty"
      case .shop:
        return "Shop For Books"
      }
    }

    var subtitle: String {
      switch self {
      case .welcome:
        return "Your feed displays the stories from topics or people you follow."
      case .discover:
        return "Check back here anytime to find the best stories from the community."
      case .shop:
        return "All the best books, the best prices and shipping is free."
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

