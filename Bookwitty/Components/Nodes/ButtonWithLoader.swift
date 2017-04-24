//
//  ButtonWithLoader.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 4/4/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol ButtonWithLoaderDelegate: class {
  func buttonTouchUpInside(buttonWithLoader: ButtonWithLoader)
}

class ButtonWithLoader: ASDisplayNode {
  fileprivate static let defaultHeight: CGFloat = 36.0
  fileprivate static let defaultMinWidth: CGFloat = 90.0
  fileprivate static let defaultMaxWidth: CGFloat = 130.0

  enum State {
    case normal
    case loading
    case selected
  }

  fileprivate let loaderNode: LoaderNode
  fileprivate let button: ASButtonNode

  fileprivate var buttonHeight: CGFloat
  fileprivate var buttonSizeWidthRange: ASSizeRange

  weak var delegate: ButtonWithLoaderDelegate?
  var isLoading: Bool {
    return state == .loading
  }
  var state: State = .normal {
    didSet {
      updateViewState()
    }
  }
  var isSelected: Bool {
    return button.isSelected
  }
  var isEnabled: Bool = true {
    didSet {
      button.isEnabled = isEnabled
    }
  }
  
  private override init() {
    loaderNode = LoaderNode()
    button = ASButtonNode()
    //Default Height
    buttonHeight = ButtonWithLoader.defaultHeight
    //Default Width Range
    buttonSizeWidthRange = ASSizeRange(min: CGSize(width: ButtonWithLoader.defaultMinWidth, height: 0.0), max: CGSize(width: ButtonWithLoader.defaultMaxWidth, height: 0.0))
    super.init()
    automaticallyManagesSubnodes = true
  }

  convenience init(buttonHeight: CGFloat = ButtonWithLoader.defaultHeight, minWidth: CGFloat = ButtonWithLoader.defaultMinWidth, maxWidth: CGFloat = ButtonWithLoader.defaultMaxWidth) {
    self.init()
    self.buttonHeight = buttonHeight
    self.buttonSizeWidthRange = ASSizeRange(min: CGSize(width: minWidth, height: 0.0), max: CGSize(width: maxWidth, height: 0.0))
    setupNode()
  }

  override func didLoad() {
    super.didLoad()
  }

  private func setupNode() {
    button.titleNode.maximumNumberOfLines = 1
    button.style.height = ASDimensionMake(buttonHeight)
    button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    button.style.flexGrow = 1.0
    button.style.flexShrink = 1.0

    //Set Button Action Listener
    button.addTarget(self, action: #selector(buttonTouchUpInsideButton), forControlEvents: ASControlNodeEvent.touchUpInside)
    setupSelectionButton()

    state = .normal
  }

  fileprivate func updateSizeToFitButton() {
    let buttonLayoutSpec = button.calculateLayoutThatFits(buttonSizeWidthRange)
    style.width = ASDimensionMake(buttonLayoutSpec.size.width)
  }

  private func updateButtonAppearance() {
    let color = button.isSelected ? ThemeManager.shared.currentTheme.defaultBackgroundColor() : ThemeManager.shared.currentTheme.defaultButtonColor()
    button.imageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(color)
  }

  fileprivate func updateViewState() {
    switch state {
    case .normal, .selected:
      button.isHidden = false
      button.isSelected = (state == .selected)
      updateSizeToFitButton()
      updateButtonAppearance()
    case .loading:
      button.isHidden = true
      updateButtonAppearance()
      loaderNode.updateLoaderVisibility(show: true)
    }
    setNeedsLayout()
  }
}

// MARK: - Node Layout
extension ButtonWithLoader {
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    updateSizeToFitButton()

    let spec = ASOverlayLayoutSpec(child: loaderNode, overlay: button)
    spec.style.flexGrow = 1.0
    spec.style.flexShrink = 1.0
    let hSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 0, justifyContent: .center, alignItems: .center, children: [spec])
    return hSpec
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
                            cornerRadius: CGFloat = 2.0) {

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
  @objc
  fileprivate func buttonTouchUpInsideButton(sender: UIButton) {
    delegate?.buttonTouchUpInside(buttonWithLoader: self)
  }
}
