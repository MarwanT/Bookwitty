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
  enum State {
    case normal
    case loading
    case selected
  }
  let loaderNode: LoaderNode
  let button: ASButtonNode

  var delegate: OnBoardingLoadingButtonDelegate?
  var isLoading: Bool {
    return state == .loading
  }
  var state: State = .normal {
    didSet {
      updateViewState()
    }
  }

  override init() {
    loaderNode = LoaderNode()
    button = ASButtonNode()
    super.init()
    automaticallyManagesSubnodes = true
    setupSelectionButton()
  }

  func setupSelectionButton() {
    let plusImage: UIImage = #imageLiteral(resourceName: "plus")
    let tickImage: UIImage = #imageLiteral(resourceName: "largeTick")
    let buttonWhiteBackgroundColor = UIImage(color: ThemeManager.shared.currentTheme.defaultBackgroundColor())
    let buttonBackgroundImage = UIImage(color: ThemeManager.shared.currentTheme.defaultButtonColor())

    button.setImage(tickImage, for: .selected)
    button.setBackgroundImage(buttonBackgroundImage, for: .selected)

    //Default state Button Image, tint and background color
    button.setImage(plusImage, for: .normal)
    button.setBackgroundImage(buttonWhiteBackgroundColor, for: .normal)
    button.imageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(ThemeManager.shared.currentTheme.defaultButtonColor())

    cornerRadius = 2.0
    borderColor = ThemeManager.shared.currentTheme.defaultButtonColor().cgColor
    borderWidth = 2
    clipsToBounds = true

    button.addTarget(self, action: #selector(touchUpInsideButton), forControlEvents: ASControlNodeEvent.touchUpInside)
  }

  func touchUpInsideButton() {
    delegate?.loadingButtonTouchUpInside(onBoardingLoadingButton: self)
  }

  func updateViewState() {
    switch state {
    case .normal, .selected:
      button.isHidden = false
      button.isSelected = (state == .selected)
      updateButtonAppearance()
    case .loading:
      button.isHidden = true
      updateButtonAppearance()
      loaderNode.updateLoaderVisibility(show: true)
    }
    setNeedsLayout()
  }

  func updateButtonAppearance() {
      let color = button.isSelected ? ThemeManager.shared.currentTheme.defaultBackgroundColor() : ThemeManager.shared.currentTheme.defaultButtonColor()
      button.imageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(color)
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    return ASOverlayLayoutSpec(child: loaderNode, overlay: button)
  }
}
