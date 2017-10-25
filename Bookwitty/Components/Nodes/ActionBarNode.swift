//
//  ActionBarNode.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/10/24.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class ActionBarNode: ASCellNode {
  let actionButton = ButtonWithLoader()
  let editButton = ASButtonNode()
  let moreButton = ASButtonNode()

  var configuration = Configuration() {
    didSet {
      setNeedsLayout()
    }
  }

  override init() {
    super.init()
    initializeComponents()
  }

  fileprivate func initializeComponents() {
    automaticallyManagesSubnodes = true
  }
}

extension ActionBarNode {
  struct Configuration {
    var internalSpacing = ThemeManager.shared.currentTheme.contentSpacing() / 4.0
    var insets: UIEdgeInsets {
      return UIEdgeInsets(top: internalSpacing - 1.0, left: 2 * internalSpacing, bottom: internalSpacing - 1.0, right: 2 * internalSpacing)
    }

    var edgeInsets: UIEdgeInsets {
      return UIEdgeInsets(top: 0.0, left: 2 * internalSpacing, bottom: 0.0, right: 2 * internalSpacing)
    }

    var height: CGFloat = 50.0
    var buttonSize: CGSize = CGSize(width: 36.0, height: 36.0)
    var iconSize: CGSize = CGSize(width: 40.0, height: 40.0)
  }
}
