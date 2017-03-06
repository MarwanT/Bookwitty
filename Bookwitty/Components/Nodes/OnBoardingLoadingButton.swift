//
//  OnBoardingLoadingButton.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/6/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol OnBoardingLoadingButtonDelegate {
  func loadingButtonTouchUpInside(onBoardingLoadingButton: OnBoardingLoadingButton)
}

class OnBoardingLoadingButton: ASDisplayNode {
  let loaderNode: LoaderNode
  let button: ASButtonNode

  override init() {
    loaderNode = LoaderNode()
    button = ASButtonNode()
    super.init()
    automaticallyManagesSubnodes = true
    setupSelectionButton()
  }

  func setupSelectionButton() {
    let plusImage: UIImage = #imageLiteral(resourceName: "plus")
    let tickImage: UIImage = #imageLiteral(resourceName: "tick")
    let buttonWhiteBackgroundColor = UIImage(color: ThemeManager.shared.currentTheme.defaultBackgroundColor())
    let buttonBackgroundImage = UIImage(color: ThemeManager.shared.currentTheme.defaultButtonColor())

    button.setImage(tickImage, for: .selected)
    button.setBackgroundImage(buttonBackgroundImage, for: .selected)

    //Default state Button Image, tint and background color
    button.setImage(plusImage, for: .normal)
    button.setBackgroundImage(buttonWhiteBackgroundColor, for: .normal)
    button.imageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(ThemeManager.shared.currentTheme.defaultButtonColor())

    cornerRadius = 4
    borderColor = ThemeManager.shared.currentTheme.defaultButtonColor().cgColor
    borderWidth = 2
    clipsToBounds = true

    button.addTarget(self, action: #selector(touchUpInsideButton), forControlEvents: ASControlNodeEvent.touchUpInside)
  }

  func touchUpInsideButton() {
  }
}
