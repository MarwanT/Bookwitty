//
//  SectionTitleHeaderNode.swift
//  Bookwitty
//
//  Created by Marwan  on 3/5/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class SectionTitleHeaderNode: ASCellNode {
  fileprivate let verticalBarNode: ASDisplayNode
  fileprivate let horizontalBarNode: ASDisplayNode
  fileprivate let titleNode: ASTextNode
  
  var configuration = Configuration() {
    didSet {
      setNeedsLayout()
    }
  }
  
  init(externalInsets: UIEdgeInsets = UIEdgeInsets.zero) {
    configuration.externalEdgeInsets = externalInsets
    verticalBarNode = ASDisplayNode()
    horizontalBarNode = ASDisplayNode()
    titleNode = ASTextNode()
    super.init()
    initializeComponents()
  }
  
  func initializeComponents() {
    automaticallyManagesSubnodes = true
    verticalBarColor = configuration.verticalBarColor
    horizontalBarColor = configuration.horizontalBarColor
    style.minHeight = ASDimensionMake(configuration.minimumHeight)
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    style.width = ASDimensionMake(constrainedSize.max.width)
    
    // Although these sizes will change, they are required for avoiding an
    // Async warining over unability to calculate the size of the nodes
    verticalBarNode.style.preferredSize = CGSize(width: 0, height: 0)
    horizontalBarNode.style.preferredSize = CGSize(width: 0, height: 0)
    
    verticalBarNode.style.width = ASDimensionMake(configuration.verticalBarWidth)
    
    // Layout Background Nodes
    let verticalBarInsetsSpec = ASInsetLayoutSpec(
      insets: configuration.verticalBarEdgeInsets,
      child: verticalBarNode)
    let horizontalBarInsetsSpec = ASInsetLayoutSpec(
      insets: configuration.horizontalBarEdgeInsets,
      child: horizontalBarNode)
    horizontalBarInsetsSpec.style.flexGrow = 1.0
    horizontalBarInsetsSpec.style.flexShrink = 1.0
    let backgroundSpec = ASStackLayoutSpec(
      direction: .horizontal,
      spacing: 0,
      justifyContent: .start,
      alignItems: .stretch,
      children: [verticalBarInsetsSpec, horizontalBarInsetsSpec])
    backgroundSpec.style.flexGrow = 1.0
    backgroundSpec.style.flexShrink = 1.0
    
    // Layout Forground/Title Node
    let titleInsetsSpec = ASInsetLayoutSpec(
      insets: configuration.titleEdgeInsets,
      child: titleNode)
    let centerTitleVertically = ASCenterLayoutSpec(
      horizontalPosition:
      ASRelativeLayoutSpecPosition.start,
      verticalPosition: ASRelativeLayoutSpecPosition.center,
      sizingOption: ASRelativeLayoutSpecSizingOption.minimumHeight,
      child: titleInsetsSpec)
    
    // Join Background and Foreground nodes
    let nodeLayoutSpec = ASBackgroundLayoutSpec(child: centerTitleVertically, background: backgroundSpec)
    let externalInsets = ASInsetLayoutSpec(
      insets: configuration.externalEdgeInsets, child: nodeLayoutSpec)
    return externalInsets
  }
  
  func setTitle(title: String?, verticalBarColor: UIColor? = nil, horizontalBarColor: UIColor? = nil) {
    self.title = title
    self.verticalBarColor = verticalBarColor ?? configuration.verticalBarColor
    self.horizontalBarColor = horizontalBarColor ?? configuration.horizontalBarColor
  }

  func setTitle(title: String?, colorSet: ColorSet? = nil) {
    self.title = title
    self.verticalBarColor = colorSet?.shades.dark ?? configuration.verticalBarColor
    self.horizontalBarColor = colorSet?.shades.light ?? configuration.horizontalBarColor
  }

  private var title: String?  {
    didSet {
      titleNode.attributedText = AttributedStringBuilder(fontDynamicType: .callout)
        .append(text: title ?? "", color: configuration.defaultTextColor).attributedString
      setNeedsLayout()
    }
  }
  
  private var verticalBarColor: UIColor? {
    didSet {
      verticalBarNode.backgroundColor = verticalBarColor
      setNeedsLayout()
    }
  }
  
  private var horizontalBarColor: UIColor? {
    didSet {
      horizontalBarNode.backgroundColor = horizontalBarColor
      setNeedsLayout()
    }
  }
}

extension SectionTitleHeaderNode {
  struct Configuration {
    var verticalBarColor = ThemeManager.shared.currentTheme.colorNumber6()
    var horizontalBarColor = ThemeManager.shared.currentTheme.colorNumber5()
    var externalEdgeInsets = UIEdgeInsets.zero
    fileprivate var defaultTextColor = ThemeManager.shared.currentTheme.defaultTextColor()
    fileprivate var verticalBarWidth: CGFloat = 8
    fileprivate var minimumHeight: CGFloat {
      return 60.0 + externalEdgeInsets.bottom + externalEdgeInsets.top
    }
    fileprivate var verticalBarEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    fileprivate var horizontalBarEdgeInsets = UIEdgeInsets(top: 0, left: 80 - 8, bottom: 0, right: 0)
    fileprivate var titleEdgeInsets = UIEdgeInsets(top: 10, left: 25, bottom: 10, right: 0)
  }

  enum ColorSet {
    case yellow
    case blue
    case orange
    case purple
    case green

    var shades: (dark: UIColor, light: UIColor) {
      let theme = ThemeManager.shared.currentTheme
      switch self {
      case .blue:
        return (theme.colorNumber10(), theme.colorNumber9())
      case .orange:
        return (theme.colorNumber4(), theme.colorNumber3())
      case .yellow:
        return (theme.colorNumber6(), theme.colorNumber5())
      case .purple:
        return (theme.colorNumber12(), theme.colorNumber11())
      case .green:
        return (theme.colorNumber8(), theme.colorNumber7())
      }
    }
  }
}
