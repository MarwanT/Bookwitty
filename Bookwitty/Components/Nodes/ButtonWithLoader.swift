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

  var delegate: ButtonWithLoaderDelegate?

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

// MARK: - Public Setters: Charactristics
extension ButtonWithLoader {
  func setAttributedTitle(title: NSAttributedString, for state: UIControlState) {
    button.setAttributedTitle(title, for: state)
  }

  func setTitle(title: String, with font: UIFont?, with color: UIColor?, for state: UIControlState) {
    button.setTitle(title, with: font, with: color, for: state)
  }

  func setupSelectionButton(defaultBackgroundColor: UIColor =  ThemeManager.shared.currentTheme.defaultBackgroundColor(),
                            selectedBackgroundColor: UIColor = ThemeManager.shared.currentTheme.defaultButtonColor(),
                            defaultImage: UIImage? = nil,
                            selectedImage: UIImage? = nil,
                            borderStroke: Bool = true,
                            borderColor: UIColor = ThemeManager.shared.currentTheme.defaultButtonColor(),
                            borderWidth: CGFloat = 2.0,
                            cornerRadius: CGFloat = 4.0) {

    let buttonWhiteBackgroundColor = UIImage(color: defaultBackgroundColor)
    let buttonBackgroundImage = UIImage(color: selectedBackgroundColor)

    if let selectedImage = selectedImage {
      button.setImage(selectedImage, for: .selected)
    }
    button.setBackgroundImage(buttonBackgroundImage, for: .selected)

    //Default state Button Image, tint and background color
    if let defaultImage = defaultImage {
      button.setImage(defaultImage, for: .normal)
    }
    button.setBackgroundImage(buttonWhiteBackgroundColor, for: .normal)
    button.imageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(ThemeManager.shared.currentTheme.defaultButtonColor())

    if borderStroke {
      self.borderColor = borderColor.cgColor
      self.borderWidth = borderWidth
    }
    self.cornerRadius = cornerRadius
    self.clipsToBounds = true
  }
}

// MARK: - Actions
extension ButtonWithLoader {
  func touchUpInsideButton() {
    delegate?.buttonTouchUpInside(buttonWithLoader: self)
  }
}
