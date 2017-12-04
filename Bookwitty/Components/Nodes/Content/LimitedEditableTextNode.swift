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
    get { return textNode.textView.text }
    set { textNode.textView.text = newValue }
  }

  var placeholder: String? {
    didSet {
      if let placeholder = placeholder {
        self.textNode.attributedPlaceholderText = AttributedStringBuilder(fontDynamicType: FontDynamicType.body)
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
  }

  var hardCharactersLimit: Int = 200
  var softCharactersLimit: Int = 140

  fileprivate(set) var numberOfCharactersLeft: Int = 200 {
    didSet {
      let characters = String(numberOfCharactersLeft)
      let color = numberOfCharactersLeft > 0 ? ThemeManager.shared.currentTheme.defaultGrayedTextColor() : ThemeManager.shared.currentTheme.colorNumber19()
      charactersLeftNode.attributedText = AttributedStringBuilder(fontDynamicType: .label)
        .append(text: characters, color: color)
        .applyParagraphStyling(alignment: .right)
        .attributedString
      charactersLeftNode.setNeedsLayout()
    }
  }

  override func didLoad() {
    super.didLoad()
    applyTheme()
    textNode.delegate = self
    numberOfCharactersLeft = hardCharactersLimit
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
}

extension LimitedEditableTextNode: Themeable {
  func applyTheme() {
    textNode.textView.font = FontDynamicType.body.font
    textNode.textView.textColor = ThemeManager.shared.currentTheme.defaultTextColor()
    backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
  }
}

extension LimitedEditableTextNode: ASEditableTextNodeDelegate {
  func editableTextNode(_ editableTextNode: ASEditableTextNode, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    let newLength =  editableTextNode.textView.text.characters.count + text.characters.count - range.length
    return newLength <= self.hardCharactersLimit
  }

  func editableTextNodeDidUpdateText(_ editableTextNode: ASEditableTextNode) {
    self.numberOfCharactersLeft = self.softCharactersLimit - editableTextNode.textView.text.characters.count
  }

  func editableTextNodeDidFinishEditing(_ editableTextNode: ASEditableTextNode) {
    self.delegate?.limitedEditableTextNodeDidFinishEditing(textNode: self)
  }
}
