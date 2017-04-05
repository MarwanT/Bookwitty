//
//  ButtonWithLoader.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 4/4/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol ButtonWithLoaderDelegate {
  func buttonTouchUpInside(buttonWithLoader: ButtonWithLoader)
}

class ButtonWithLoader: ASDisplayNode {
  fileprivate let smallButtonHeight: CGFloat = 36.0
  fileprivate let largeButtonHeight: CGFloat = 44.0

  fileprivate let loaderNode: LoaderNode
  fileprivate let button: ASButtonNode

  override init() {
    loaderNode = LoaderNode()
    button = ASButtonNode()
    super.init()
    automaticallyManagesSubnodes = true
    setupNode()
  }

  func setupNode() {
    style.flexGrow = 1.0
    style.flexShrink = 1.0

    button.titleNode.maximumNumberOfLines = 1
    button.style.height = ASDimensionMake(smallButtonHeight)
    button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

    //Set Button Action Listener
    button.addTarget(self, action: #selector(touchUpInsideButton), forControlEvents: ASControlNodeEvent.touchUpInside)
  }
}

// MARK: - Actions
extension ButtonWithLoader {
  func touchUpInsideButton() {
    //TODO: delegate action
  }
}
