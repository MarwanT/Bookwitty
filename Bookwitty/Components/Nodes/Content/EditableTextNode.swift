//
//  EditableTextNode.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/10/09.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

protocol EditableTextNodeDelegate: class {
  func editableTextNodeDidRequestClear(textNode: EditableTextNode)
  func editableTextNodeDidFinishEditing(textNode: EditableTextNode)
}

class EditableTextNode: ASCellNode {
  let textNode: ASEditableTextNode
  let clearButtonNode: ASButtonNode

  weak var delegate: EditableTextNodeDelegate?

  var text: String? {
    didSet {
      if let text = text {
        textNode.attributedText = AttributedStringBuilder(fontDynamicType: .title2)
          .append(text: text)
          .attributedString
      } else {
        textNode.attributedText = nil
      }
      textNode.setNeedsLayout()
    }
  }

  var contentText: String? {
    return textNode.textView.text
  }

  override init() {
    textNode = ASEditableTextNode()
    clearButtonNode = ASButtonNode()
    super.init()
    setupNode()
  }

  fileprivate func setupNode() {
    automaticallyManagesSubnodes = true
    let insets = externalEdgeInsets()
    let defaultTextFieldHeight: CGFloat = 30.0
    textNode.style.maxHeight = ASDimension(unit: .points, value: defaultTextFieldHeight + insets.top + insets.bottom)
    textNode.maximumLinesToDisplay = 2

    textNode.style.flexGrow = 1.0
    textNode.style.flexShrink = 1.0
    textNode.delegate = self

    clearButtonNode.style.preferredSize = CGSize(width: 12.5, height: 12.5)
    clearButtonNode.cornerRadius = 12.5 / 2.0
    clearButtonNode.imageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(ThemeManager.shared.currentTheme.defaultGrayedTextColor())
    clearButtonNode.imageNode.contentMode = UIViewContentMode.scaleAspectFit
    clearButtonNode.setImage(#imageLiteral(resourceName: "clear"), for: .normal)
    clearButtonNode.clipsToBounds = true

    clearButtonNode.addTarget(self, action: #selector(clearButtonTouchUpInside(_:)), forControlEvents: .touchUpInside)
  }

  override func didLoad() {
    super.didLoad()
    applyTheme()
  }

  override func resignFirstResponder() -> Bool {
    return textNode.resignFirstResponder()
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let nodesArray: [ASLayoutElement] = [textNode, clearButtonNode]
    let horizontalSpec = ASStackLayoutSpec(direction: .horizontal,
                                         spacing: 5.0,
                                         justifyContent: .start,
                                         alignItems: .center,
                                         children: nodesArray)

    let insetSpec = ASInsetLayoutSpec(insets: externalEdgeInsets(), child: horizontalSpec)
    return insetSpec
  }

  private func externalEdgeInsets() -> UIEdgeInsets {
    return UIEdgeInsets(
      top: ThemeManager.shared.currentTheme.generalExternalMargin(),
      left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: ThemeManager.shared.currentTheme.generalExternalMargin(),
      right: ThemeManager.shared.currentTheme.generalExternalMargin())
  }

  @objc fileprivate func clearButtonTouchUpInside(_ sender: ASButtonNode) {
    textNode.resignFirstResponder()
    delegate?.editableTextNodeDidRequestClear(textNode: self)
  }
}

extension EditableTextNode: Themeable {
  func applyTheme() {
    textNode.textView.font = FontDynamicType.title2.font
    textNode.textView.textColor = ThemeManager.shared.currentTheme.defaultTextColor()
    backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
  }
}

//MARK: - ASEditableTextNodeDelegate implementation
extension EditableTextNode: ASEditableTextNodeDelegate {
  func editableTextNodeDidUpdateText(_ editableTextNode: ASEditableTextNode) {
    setNeedsLayout()
  }
  
  func editableTextNodeDidFinishEditing(_ editableTextNode: ASEditableTextNode) {
    self.delegate?.editableTextNodeDidFinishEditing(textNode: self)
  }
}