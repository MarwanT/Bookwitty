//
//  ContributorsNode.swift
//  Bookwitty
//
//  Created by charles on 3/2/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ContributorsNode: ASDisplayNode {
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let imageSize: CGSize = CGSize(width: 45.0, height: 45.0)
  fileprivate let imageBorderWidth: CGFloat = 0.0
  fileprivate let imgaeBorderColor: UIColor? = nil

  override init() {
    super.init()
    automaticallyManagesSubnodes = true
    setupNode()
  }
  private func setupNode() {
  }
}

//Helpers
extension ContributorsNode {
  fileprivate func sideInset() -> UIEdgeInsets {
    return UIEdgeInsets(top: 0,
                        left: internalMargin,
                        bottom: 0,
                        right: internalMargin)
  }

  fileprivate func spacer(flexGrow: CGFloat = 0.0, height: CGFloat = 0.0, width: CGFloat = 0.0) -> ASLayoutSpec {
    return ASLayoutSpec().styled { (style) in
      style.height = ASDimensionMake(height)
      style.width = ASDimensionMake(width)
      style.flexGrow = flexGrow
    }
  }

  fileprivate func isValid(_ value: String?) -> Bool {
    return !value.isEmptyOrNil()
  }
}
