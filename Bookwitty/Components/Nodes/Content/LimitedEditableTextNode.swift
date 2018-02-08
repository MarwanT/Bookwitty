//
//  LimitedEditableTextNode.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/10/09.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

protocol LimitedEditableTextNodeDelegate: class {
  func limitedEditableTextNodeDidFinishEditing(textNode: LimitedEditableTextNode)
}

class LimitedEditableTextNode: ASCellNode {
  let textNode: ASEditableTextNode
  let charactersLeftNode: ASTextNode

  weak var delegate: LimitedEditableTextNodeDelegate?

  var contentText: String? {
    get {
      return textNode.attributedText?.string
    }
    set {
      if let substring = newValue?.suffix(hardCharactersLimit) {
        let value = String(substring)
        textNode.attributedText = AttributedStringBuilder(fontDynamicType: FontDynamicType.body2)
          .append(text: value, color: ThemeManager.shared.currentTheme.defaultTextColor())
          .attributedString
      } else {
        textNode.attributedText = nil
      }
      refreshNumberOfCharactersLeft(for: newValue ?? "")
    }
  }

  var placeholder: String? {
    didSet {
      if let placeholder = placeholder {
        self.textNode.attributedPlaceholderText = AttributedStringBuilder(fontDynamicType: FontDynamicType.body2)
          .append(text: placeholder, color: ThemeManager.shared.currentTheme.defaultGrayedTextColor())
          .attributedString
      } else {
        self.textNode.attributedPlaceholderText = nil
      }
    }
  }

  override init() {
    textNode = ASEditableTextNode()
    charactersLeftNode = ASTextNode()
    super.init()
    setupNode()
  }

  fileprivate func setupNode() {
    automaticallyManagesSubnodes = true
    textNode.style.height = ASDimension(unit: .points, value: 80.0)
    textNode.maximumLinesToDisplay = 3

    textNode.style.flexGrow = 1.0
    textNode.style.flexShrink = 1.0

    charactersLeftNode.style.flexGrow = 1.0
    charactersLeftNode.style.flexShrink = 1.0
    
    textNode.delegate = self
    
    applyTheme()
  }

  var hardCharactersLimit: Int = 200
  var softCharactersLimit: Int = 140

  fileprivate(set) var numberOfCharactersLeft: Int = 200 {
    didSet {
      let characters = String(numberOfCharactersLeft)
      let color = numberOfCharactersLeft > 0 ? ThemeManager.shared.currentTheme.defaultGrayedTextColor() : ThemeManager.shared.currentTheme.colorNumber19()
      charactersLeftNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption2)
        .append(text: characters, color: color)
        .applyParagraphStyling(alignment: .right)
        .attributedString
      charactersLeftNode.setNeedsLayout()
    }
  }
  
  override func resignFirstResponder() -> Bool {
    return textNode.resignFirstResponder()
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let nodesArray: [ASLayoutElement] = [textNode, charactersLeftNode]
    let verticalSpec = ASStackLayoutSpec(direction: .vertical,
                                           spacing: 0.0,
                                           justifyContent: .start,
                                           alignItems: .stretch,
                                           children: nodesArray)

    let insetSpec = ASInsetLayoutSpec(insets: externalEdgeInsets(), child: verticalSpec)
    return insetSpec
  }

  private func externalEdgeInsets() -> UIEdgeInsets {
    return UIEdgeInsets(
      top: ThemeManager.shared.currentTheme.generalExternalMargin(),
      left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: ThemeManager.shared.currentTheme.generalExternalMargin(),
      right: ThemeManager.shared.currentTheme.generalExternalMargin())
  }
  
  // MARK: - Helpers
  fileprivate func refreshNumberOfCharactersLeft(for text: String) {
    self.numberOfCharactersLeft = self.softCharactersLimit - text.count
  }
}

extension LimitedEditableTextNode: Themeable {
  func applyTheme() {
    backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
  }
}

extension LimitedEditableTextNode: ASEditableTextNodeDelegate {
  func editableTextNode(_ editableTextNode: ASEditableTextNode, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    let newLength =  (editableTextNode.attributedText?.string ?? "").count + text.count - range.length
    return newLength <= self.hardCharactersLimit
  }

  func editableTextNodeDidUpdateText(_ editableTextNode: ASEditableTextNode) {
    refreshNumberOfCharactersLeft(for: editableTextNode.attributedText?.string ?? "")
  }

  func editableTextNodeDidFinishEditing(_ editableTextNode: ASEditableTextNode) {
    self.delegate?.limitedEditableTextNodeDidFinishEditing(textNode: self)
  }
}
